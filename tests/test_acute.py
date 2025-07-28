import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np
import pandas as pd
import pytest

from nwau_py.utils import sas_ref_dir

spec = importlib.util.spec_from_file_location(
    "acute",
    Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "acute.py",
)
acute = importlib.util.module_from_spec(spec)
spec.loader.exec_module(acute)

YEARS = [str(y) for y in range(2013, 2026)]

DATA = pd.DataFrame(
    {
        "DRG": ["801A", "801A", "801A"],
        "LOS": [5, 10, 80],
        "ICU_HOURS": [0, 0, 0],
        "ICU_OTHER": [0, 0, 0],
        "PAT_SAMEDAY_FLAG": [0, 0, 0],
        "PAT_PRIVATE_FLAG": [0, 0, 0],
        "PAT_COVID_FLAG": [0, 0, 0],
    }
)

EXPECTED = np.array([6.8772, 9.2472, 11.3272])


@pytest.mark.parametrize("year", YEARS)
def test_calculate_acute_matches_sas_weights(monkeypatch, year):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_aa_price_weights.csv")
        df["DRG"] = df["DRG"].str.strip("b'")
        return df

    monkeypatch.setattr(acute, "_load_price_weights", _load_csv)

    ref_dir = Path("tests/data")
    result = acute.calculate_acute(
        DATA.copy(),
        acute.AcuteParams(),
        year=year,
        ref_dir=ref_dir,
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED)


def _mock_load(
    path: Path,
    cache: bool = True,
    cache_format: str | None = None,
    cache_dir: Path | None = None,
) -> pd.DataFrame:
    name = path.name
    if "aa_price_weights" in name:
        df = pd.read_csv("tests/data/nep25_aa_price_weights.csv")
        df["DRG"] = df["DRG"].str.strip("b'")
        return df
    if "aa_adj_covid" in name:
        return pd.DataFrame({"_pat_covid_treat_flag": [0, 1], "adj_covid": [0.0, 0.23]})
    return pd.DataFrame()


def test_covid_flags_from_diagnosis(monkeypatch):
    monkeypatch.setattr(
        acute,
        "_load_price_weights",
        lambda r, year="2025": pd.read_csv(
            "tests/data/nep25_aa_price_weights.csv"
        ).assign(DRG=lambda x: x["DRG"].str.strip("b'")),
    )
    monkeypatch.setattr(acute, "load_sas_table", _mock_load)

    df = pd.DataFrame(
        {
            "DRG": ["T63A", "801A", "T63B"],
            "LOS": [5, 5, 5],
            "ICU_HOURS": [0, 0, 0],
            "ICU_OTHER": [0, 0, 0],
            "PAT_SAMEDAY_FLAG": [0, 0, 0],
            "PAT_PRIVATE_FLAG": [0, 0, 0],
            "DX1": ["U0712", "U0711", "A000"],
        }
    )

    params = acute.AcuteParams(
        icu_paed_option=2,
        radiotherapy_option=1,
        dialysis_option=1,
        est_remoteness_option=2,
        covid_option=1,
        covid_adj_option=1,
        debug_mode=True,
    )

    result = acute.calculate_acute(
        df, params, year="2025", ref_dir=Path("tests/data/2025")
    )
    assert result["_pat_covid_flag"].tolist() == [1, 1, 0]
    assert result["_pat_covid_treat_flag"].tolist() == [1, 0, 0]
    assert result["adj_covid"].iloc[0] == 0.23


def test_covid_flags_provided(monkeypatch):
    monkeypatch.setattr(
        acute,
        "_load_price_weights",
        lambda r, year="2025": pd.read_csv(
            "tests/data/nep25_aa_price_weights.csv"
        ).assign(DRG=lambda x: x["DRG"].str.strip("b'")),
    )
    monkeypatch.setattr(acute, "load_sas_table", _mock_load)

    df = pd.DataFrame(
        {
            "DRG": ["T63A"],
            "LOS": [5],
            "ICU_HOURS": [0],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [0],
            "PAT_COVID_FLAG": [1],
            "COVID_ADJ_FLAG": [1],
        }
    )

    params = acute.AcuteParams(
        icu_paed_option=2,
        radiotherapy_option=1,
        dialysis_option=1,
        est_remoteness_option=2,
        covid_option=2,
        covid_adj_option=2,
        debug_mode=True,
    )

    result = acute.calculate_acute(
        df, params, year="2025", ref_dir=Path("tests/data/2025")
    )
    assert result["_pat_covid_flag"].iloc[0] == 1
    assert result["_pat_covid_treat_flag"].iloc[0] == 1
    assert result["adj_covid"].iloc[0] == 0.23

    assert any(col.startswith("_") for col in result.columns)

    debug = acute.calculate_acute(
        DATA.copy(),
        acute.AcuteParams(debug_mode=True),
        year="2025",
        ref_dir=Path("tests/data/2025"),
    )
    assert any(col.startswith("_") for col in debug.columns)


def test_calculate_acute_option_paths(monkeypatch):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_aa_price_weights.csv")
        df["DRG"] = df["DRG"].str.strip("b'")
        return df

    monkeypatch.setattr(acute, "_load_price_weights", _load_csv)

    data = DATA.copy()
    data["PAT_RADIOTHERAPY_FLAG"] = 0
    data["PAT_DIALYSIS_FLAG"] = 0
    data["EST_ELIGIBLE_ICU_FLAG"] = 0
    data["EST_ELIGIBLE_PAED_FLAG"] = 0
    data["EST_REMOTENESS"] = 0

    params = acute.AcuteParams(
        icu_paed_option=2,
        radiotherapy_option=2,
        dialysis_option=2,
        est_remoteness_option=2,
    )

    result = acute.calculate_acute(
        data,
        params,
        year="2025",
        ref_dir=Path("tests/data/2025"),
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED)


def test_calculate_acute_2018_runs(monkeypatch):
    """Ensure the calculator runs for a pre-2021 year."""
    dir_path = sas_ref_dir("2018")
    assert Path(dir_path).exists()

    monkeypatch.setattr(
        acute,
        "_load_price_weights",
        lambda *_args, **_kwargs: pd.read_csv(
            "tests/data/2018/nep18_aa_price_weights.csv"
        ),
    )

    df = DATA.iloc[:1].copy()
    res = acute.calculate_acute(
        df,
        acute.AcuteParams(),
        year="2018",
        ref_dir=Path(dir_path),
    )
    assert res["NWAU25"].iloc[0] > 0


# ---------------------------------------------------------------------------
# Additional helpers for adjustment testing
# ---------------------------------------------------------------------------


def _make_weights(*_, **overrides) -> pd.DataFrame:
    data = {
        "DRG": ["AAA"],
        "drg_inlier_lb": [2],
        "drg_inlier_ub": [10],
        "drg_adj_paed": [1.2],
        "drg_samedaylist_flag": [0],
        "drg_bundled_icu_flag": [0],
        "drg_pw_sd": [0.5],
        "drg_pw_sso_base": [0.6],
        "drg_pw_sso_perdiem": [0.1],
        "drg_pw_inlier": [1.0],
        "drg_pw_lso_perdiem": [0.2],
        "drg_adj_privpat_serv": [0.1],
        "state_adj_privpat_accomm_sd": [0.02],
        "state_adj_privpat_accomm_on": [0.01],
        "icu_rate": [0.05],
        "adj_radiotherapy": [0.0],
        "adj_dialysis": [0.0],
        "adj_remoteness": [0.0],
        "adj_treat_remoteness": [0.0],
    }
    for k, v in overrides.items():
        data[k] = [v]
    return pd.DataFrame(data)


def _fake_load(path: Path, *_, **__):
    name = path.name
    if "radio_codes" in name:
        return pd.DataFrame({"code_ID": [11111]})
    if "dialysis_codes" in name:
        return pd.DataFrame({"code_ID": [22222]})
    if "icu_paed_eligibility_list" in name:
        return pd.DataFrame(
            {
                "APCID": ["HOSP"],
                "_est_eligible_icu_flag": [1],
                "_est_eligible_paed_flag": [1],
            }
        )
    if "postcode_to_ra2021" in name:
        return pd.DataFrame({"POSTCODE": ["PC1"], "ra2021": [2]})
    if "sa2_to_ra2021" in name:
        return pd.DataFrame({"ASGS": [123], "ra2021": [3]})
    if "hospital_ra2021" in name:
        return pd.DataFrame({"APCID": ["HOSP"], "_hosp_ra_2021": [4]})
    if "aa_sa_adj_rt" in name:
        return pd.DataFrame()
    if "aa_sa_adj_ds" in name:
        return pd.DataFrame()
    return pd.DataFrame()


def test_proc_adjustments(monkeypatch):
    monkeypatch.setattr(
        acute,
        "_load_price_weights",
        lambda *_: _make_weights(adj_radiotherapy=0.1, adj_dialysis=0.2),
    )
    monkeypatch.setattr(acute, "load_sas_table", _fake_load)

    df = pd.DataFrame(
        {
            "DRG": ["AAA"],
            "LOS": [3],
            "ICU_HOURS": [0],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [0],
            "PROC1": [11111],
            "PROC2": [22222],
        }
    )

    res = acute.calculate_acute(
        df, acute.AcuteParams(icu_paed_option=2), year="2025", ref_dir=Path("unused")
    )
    assert res["adj_radiotherapy"].iloc[0] == 0.1
    assert res["adj_dialysis"].iloc[0] == 0.2
    assert res["NWAU25"].iloc[0] == pytest.approx(1.3, rel=1e-4)


def test_icu_and_paediatric(monkeypatch):
    monkeypatch.setattr(acute, "_load_price_weights", _make_weights)
    monkeypatch.setattr(acute, "load_sas_table", _fake_load)

    df = pd.DataFrame(
        {
            "DRG": ["AAA"],
            "LOS": [5],
            "ICU_HOURS": [48],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [0],
            "APCID": ["HOSP"],
        }
    )

    res = acute.calculate_acute(
        df, acute.AcuteParams(debug_mode=True), year="2025", ref_dir=Path("unused")
    )
    assert res["_est_eligible_icu_flag"].iloc[0] == 1
    assert res["_est_eligible_paed_flag"].iloc[0] == 1
    assert res["NWAU25"].iloc[0] == pytest.approx(3.4, rel=1e-4)


def test_private_patient_deductions(monkeypatch):
    monkeypatch.setattr(acute, "_load_price_weights", _make_weights)
    monkeypatch.setattr(acute, "load_sas_table", _fake_load)

    base = pd.DataFrame(
        {
            "DRG": ["AAA"],
            "LOS": [4],
            "ICU_HOURS": [0],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [1],
            "STATE": [1],
        }
    )

    res1 = acute.calculate_acute(
        base.copy(), acute.AcuteParams(ppservadj=1), year="2025", ref_dir=Path("unused")
    )
    assert res1["NWAU25"].iloc[0] == pytest.approx(0.86, rel=1e-4)

    res2 = acute.calculate_acute(
        base.copy(), acute.AcuteParams(ppservadj=2), year="2025", ref_dir=Path("unused")
    )
    assert res2["NWAU25"].iloc[0] == pytest.approx(0.86, rel=1e-4)


def test_remoteness_adjustments(monkeypatch):
    monkeypatch.setattr(
        acute,
        "_load_price_weights",
        lambda *_: _make_weights(adj_remoteness=0.2, adj_treat_remoteness=0.05),
    )
    monkeypatch.setattr(acute, "load_sas_table", _fake_load)

    df = pd.DataFrame(
        {
            "DRG": ["AAA"],
            "LOS": [3],
            "ICU_HOURS": [0],
            "ICU_OTHER": [0],
            "PAT_SAMEDAY_FLAG": [0],
            "PAT_PRIVATE_FLAG": [0],
            "APCID": ["HOSP"],
            "PAT_POSTCODE": ["PC1"],
            "PAT_SA2": [123],
        }
    )

    res = acute.calculate_acute(
        df, acute.AcuteParams(debug_mode=True), year="2025", ref_dir=Path("unused")
    )
    assert res["_pat_remoteness"].iloc[0] == 3
    assert res["_treat_remoteness"].iloc[0] == 4
    assert res["NWAU25"].iloc[0] == pytest.approx(1.26, rel=1e-4)
