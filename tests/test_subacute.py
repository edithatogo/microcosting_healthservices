import importlib.util
import sys
import numpy as np
import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "subacute",
    Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "subacute.py",
)
subacute = importlib.util.module_from_spec(spec)
spec.loader.exec_module(subacute)

WEIGHTS = pd.DataFrame({"ANSNAP": ["5AZ1"], "ansnap_pw_inlier": [13.4327]})
DATA = pd.DataFrame({"ANSNAP": ["5AZ1"], "adj_indigenous": [0.0], "adj_remoteness": [0.0]})
EXPECTED = 13.4327

@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_subacute_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({
        "ANSNAP": ["5AZ1"],
        "snap_pw": [EXPECTED],
        "ansnap_samedaylist_flag": [1],
        "ansnap_inlier_lb": [1],
        "ansnap_inlier_ub": [10],
        "caretype_adj_privpat_serv_nat": [0],
        "state_adj_privpat_accomm_sd": [0],
        "state_adj_privpat_accomm_on": [0],
        "ansnap_pw_sd": [1.0],
        "ansnap_pw_sso_perdiem": [0.0],
        "ansnap_pw_inlier": [1.0],
        "ansnap_pw_lso_perdiem": [0.0],
    })

    def _load(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_sa_snap_price_weights.csv")
        df = df.rename(columns={"ansnap": "ANSNAP"})
        return df[df["ANSNAP"] == "5AZ1"].reset_index(drop=True)

    monkeypatch.setattr(subacute, "_load_weights", _load_csv)

    df = pd.DataFrame(
        {
            "ANSNAP": ["5AZ1"],
            "ADM_DATE": [pd.Timestamp("2024-07-01")],
            "SEP_DATE": [pd.Timestamp("2024-08-10")],
            "LEAVE_DAYS": [0],
            "BIRTH_DATE": [pd.Timestamp("1980-01-01")],
            "PAT_PRIVATE_FLAG": [0],
            "PAT_PUBLIC_FLAG": [1],
            "STATE": [1],
        }
    )

    result = subacute.calculate_subacute(
        DATA2.copy(),
        df,
        subacute.SubacuteParams(),
        year=year,
        ref_dir=Path("unused"),
    )
    assert not any(c.startswith("_") for c in result.columns)

    debug = subacute.calculate_subacute(
        DATA2.copy(),
        subacute.SubacuteParams(debug_mode=True),
        year=year,
        ref_dir=Path("unused"),
    )
    assert any(c.startswith("_") for c in debug.columns)

DATA2 = pd.DataFrame(

    assert result["NWAU25"].iloc[0] == pytest.approx(13.4327, rel=1e-4)


DATA = pd.DataFrame(

DATA_WEIGHTS = pd.DataFrame(
    {
        "ANSNAP": ["5AZ1"],
        "ADM_DATE": [pd.Timestamp("2024-07-01")],
        "SEP_DATE": [pd.Timestamp("2024-08-10")],
        "LEAVE_DAYS": [0],
        "BIRTH_DATE": [pd.Timestamp("1980-01-01")],
        "PAT_PRIVATE_FLAG": [0],
        "PAT_PUBLIC_FLAG": [1],
        "STATE": [1],
        "adj_indigenous": [0.0],
        "adj_remoteness": [0.0],
    }
)
EXPECTED2 = np.array([13.4327])
EXPECTED = 13.4327


BASE_DATA = pd.DataFrame(
    {
        "ANSNAP": ["5AZ1"],
        "ADM_DATE": [pd.Timestamp("2024-07-01")],
        "SEP_DATE": [pd.Timestamp("2024-08-10")],
        "LEAVE_DAYS": [0],
        "BIRTH_DATE": [pd.Timestamp("1980-01-01")],
        "PAT_PRIVATE_FLAG": [0],
        "PAT_PUBLIC_FLAG": [1],
        "STATE": [1],
    }
)

EXPECTED_ARRAY = np.array([13.4327])

def _basic_weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
    df = pd.read_csv("tests/data/nep25_sa_snap_price_weights.csv")
    df = df.rename(columns={"ansnap": "ANSNAP"})
    df["caretype_adj_privpat_serv_nat"] = 0.1
    df["caretype_adj_privpat_serv_state"] = 0.2
    return df

def test_calculate_subacute_basic(monkeypatch):
    monkeypatch.setattr(subacute, "_load_weights", _basic_weights)
    result = subacute.calculate_subacute(
        BASE_DATA.copy(),
        subacute.SubacuteParams(),
        year="2025",
        ref_dir=Path("."),
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED_ARRAY)
    assert result["Error_Code"].iloc[0] == 0

def test_calculate_subacute_option_paths(monkeypatch):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_sa_snap_price_weights.csv")
        return df.rename(columns={"ansnap": "ANSNAP"})

    monkeypatch.setattr(subacute, "_load_weights", _load_csv)

    data = DATA.copy()
    data["EST_REMOTENESS"] = 0

    params = subacute.SubacuteParams(
        radiotherapy_option=2,
        dialysis_option=2,
        est_remoteness_option=2,
    )

    result = subacute.calculate_subacute(
        DATA2.copy(),
        subacute.SubacuteParams(),
        year="2025",
        ref_dir=Path("."),
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED2)
        data,
        params,
        year="2025",
        ref_dir=Path("."),
    )

    assert np.allclose(result["NWAU25"].values, EXPECTED)
    assert result["Error_Code"].iloc[0] == 0

def test_ppsa_option(monkeypatch):
    monkeypatch.setattr(subacute, "_load_weights", _basic_weights)
    data = BASE_DATA.copy()
    data["PAT_PRIVATE_FLAG"] = 1
    data["PAT_PUBLIC_FLAG"] = 0
    params = subacute.SubacuteParams(ppsa_option=1)
    res1 = subacute.calculate_subacute(
        data.copy(),
        params,
        year="2025",
        ref_dir=Path("."),
    )
    expected1 = 13.4327 * (1 - 0.1)
    assert res1["NWAU25"].iloc[0] == pytest.approx(expected1, rel=1e-4)

    params2 = subacute.SubacuteParams(ppsa_option=2)
    res2 = subacute.calculate_subacute(
        data.copy(),
        params2,
        year="2025",
        ref_dir=Path("."),
    )
    expected2 = 13.4327 * (1 - 0.2)
    assert res2["NWAU25"].iloc[0] == pytest.approx(expected2, rel=1e-4)


def test_procedure_flags(monkeypatch):
    monkeypatch.setattr(subacute, "_load_weights", _basic_weights)

    radio_codes = pd.DataFrame({"code_ID": [12345]})
    dialysis_codes = pd.DataFrame({"code_ID": [22222]})
    adj_rt = pd.DataFrame(
        {"_pat_radiotherapy_flag": [0, 1], "adj_radiotherapy": [0.0, 0.1]}
    )
    adj_ds = pd.DataFrame({"_pat_dialysis_flag": [0, 1], "adj_dialysis": [0.0, 0.2]})

    def fake_load(path: Path, *_, **__):
        p = str(path)
        if "radio_codes" in p:
            return radio_codes
        if "dialysis_codes" in p:
            return dialysis_codes
        if "adj_rt" in p:
            return adj_rt
        if "adj_ds" in p:
            return adj_ds
        raise FileNotFoundError(p)

    monkeypatch.setattr(subacute, "load_sas_table", fake_load)

    data = BASE_DATA.copy()
    data["PROC1"] = 12345
    data["PROC2"] = 22222
    params = subacute.SubacuteParams()
    res = subacute.calculate_subacute(data, params, year="2025", ref_dir=Path("unused"))
    assert res["_pat_radiotherapy_flag"].iloc[0] == 1
    assert res["_pat_dialysis_flag"].iloc[0] == 1
    expected = 13.4327 * (1 + 0.1 + 0.2)
    assert res["NWAU25"].iloc[0] == pytest.approx(expected, rel=1e-4)

    params2 = subacute.SubacuteParams(radiotherapy_option=2, dialysis_option=2)
    data2 = BASE_DATA.copy()
    data2["PAT_RADIOTHERAPY_FLAG"] = 0
    data2["PAT_DIALYSIS_FLAG"] = 0
    res2 = subacute.calculate_subacute(
        data2,
        params2,
        year="2025",
        ref_dir=Path("unused"),
    )
    assert res2["_pat_radiotherapy_flag"].iloc[0] == 0
    assert res2["_pat_dialysis_flag"].iloc[0] == 0
    assert res2["NWAU25"].iloc[0] == pytest.approx(13.4327, rel=1e-4)
