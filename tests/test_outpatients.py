import importlib.util
import sys
from pathlib import Path

import pandas as pd
import pytest

from nwau_py.utils import ra_suffix

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
spec = importlib.util.spec_from_file_location(
    "outpatients",
    Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "outpatients.py",
)
outpatients = importlib.util.module_from_spec(spec)
spec.loader.exec_module(outpatients)

WEIGHTS = pd.DataFrame(
    {"TIER2_CLINIC": [10.01], "clinic_pw": [0.1], "tier2_adj_paed": [1.0]}
)
IND_ADJ = pd.DataFrame(
    {"_pat_ind_flag": [0, 1], "adj_indigenous": [0.0, 0.03]}
)
PAT_REM_ADJ = pd.DataFrame(
    {"_pat_remoteness": [0, 3], "adj_remoteness": [0.0, 0.09]}
)
TREAT_REM_ADJ = pd.DataFrame(
    {"_treat_remoteness": [0, 1], "adj_treat_remoteness": [0.0, 0.02]}
)
HOSP_RA = pd.DataFrame({"APCID": ["H1"], "_hosp_ra_2021": [1]})
POSTCODE_RA = pd.DataFrame({"POSTCODE": [2000], "ra2021": [2]})
SA2_RA = pd.DataFrame({"SA2": [12345], "ra2021": [3]})
ICU_LIST = pd.DataFrame({"APCID": ["H1"], "_est_eligible_paed_flag": [1]})
MULTI_PROV = 0.5


@pytest.fixture(autouse=True)
def patch_loaders(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda *_: WEIGHTS)
    monkeypatch.setattr(outpatients, "_load_multi_prov_adj", lambda *_: MULTI_PROV)
    monkeypatch.setattr(outpatients, "_load_hospital_ra", lambda *_: HOSP_RA)
    monkeypatch.setattr(outpatients, "_load_postcode_ra", lambda *_: POSTCODE_RA)
    monkeypatch.setattr(outpatients, "_load_sa2_ra", lambda *_: SA2_RA)
    monkeypatch.setattr(outpatients, "_load_icu_list", lambda *_: ICU_LIST)
    monkeypatch.setattr(outpatients, "_load_ind_adj", lambda *_: IND_ADJ)
    monkeypatch.setattr(outpatients, "_load_pat_rem_adj", lambda *_: PAT_REM_ADJ)
    monkeypatch.setattr(outpatients, "_load_treat_rem_adj", lambda *_: TREAT_REM_ADJ)

def test_patient_level_with_adjustments():
@pytest.fixture(autouse=True)
def patch_loaders(monkeypatch):
    def _hospital(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        ra = ra_suffix(year)
        return pd.DataFrame({"APCID": ["APC1"], f"_hosp_ra_{ra[2:]}": [5]})

    def _postcode(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        ra = ra_suffix(year)
        return pd.DataFrame({"POSTCODE": ["PC1"], ra: [4]})

    def _sa2(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        ra = ra_suffix(year)
        return pd.DataFrame({"SA2": [123], ra: [3]})

    def _icu(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame({"APCID": ["APC1"], "_est_eligible_paed_flag": [1]})

    def _ind_adj(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame({"_pat_ind_flag": [0, 1], "adj_indigenous": [0.0, 0.1]})

    def _pat_rem(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame({"_pat_remoteness": [3], "adj_remoteness": [0.2]})

    def _treat_rem(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame({"_treat_remoteness": [5], "adj_treat_remoteness": [0.03]})

    monkeypatch.setattr(outpatients, "_load_hospital_ra", _hospital)
    monkeypatch.setattr(outpatients, "_load_postcode_ra", _postcode)
    monkeypatch.setattr(outpatients, "_load_sa2_ra", _sa2)
    monkeypatch.setattr(outpatients, "_load_icu_list", _icu)
    monkeypatch.setattr(outpatients, "_load_ind_adj", _ind_adj)
    monkeypatch.setattr(outpatients, "_load_pat_rem_adj", _pat_rem)
    monkeypatch.setattr(outpatients, "_load_treat_rem_adj", _treat_rem)
    monkeypatch.setattr(outpatients, "_load_multi_prov_adj", lambda *_: _MultiProv(0.0))


def test_patient_level_with_adjustments(monkeypatch):
    def _weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame(
            {"TIER2_CLINIC": [10.01], "clinic_pw": [0.1], "tier2_adj_paed": [1.0]}
        )

    monkeypatch.setattr(outpatients, "_load_weights", _weights)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2025-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "APCID": ["H1"],
            "PAT_POSTCODE": [2000],
            "PAT_SA2": [12345],
            "PAT_REMOTENESS": [3],
            "INDSTAT": [1],
            "PAT_MULTIPROV_FLAG": [0],
            "FUNDSC": [1],
        }
    )

    result = outpatients.calculate_outpatients(
        df.copy(),
        outpatients.OutpatientParams(debug_mode=True),
        year="2025",
        ref_dir=Path("unused"),
    )

    expected = 0.1 * (1 + 0.03 + 0.09) * 1.02
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0

def test_clinic_level_multiprovider():
def test_clinic_level_multiprovider(monkeypatch):
    def _weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame({"TIER2_CLINIC": [10.01], "clinic_pw": [1.0]})

    monkeypatch.setattr(outpatients, "_load_weights", _weights)
    monkeypatch.setattr(outpatients, "_load_multi_prov_adj", lambda *_: _MultiProv(0.1))
    monkeypatch.setattr(
        outpatients,
        "_load_treat_rem_adj",
        lambda *_: pd.DataFrame(
            {"_treat_remoteness": [0], "adj_treat_remoteness": [0.0]}
        ),
    )

def test_patient_level_flow():
    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "APCID": ["H1"],
            "GROUP_EVENT_COUNT": [10],
            "INDIV_EVENT_COUNT": [5],
            "MULTI_DISP_CONF_COUNT": [2],
            "PAT_MULTIPROV_FLAG": [1],
            "FUNDSC": [1],
            "SERVICE_DATE": [pd.Timestamp("2025-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "PAT_REMOTENESS": [3],
        }
    )

    result = outpatients.calculate_outpatients(
        df.copy(),
            "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2015-01-01")],
            "PAT_MULTIPROV_FLAG": [1],
            "INDSTAT": [1],
            "FUNDSC": [1],
            "GROUP_EVENT_COUNT": [1],
            "INDIV_EVENT_COUNT": [1],
            "MULTI_DISP_CONF_COUNT": [0],
        }
    )
    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(),
        year="2025",
        ref_dir=Path("unused"),
    )
    expected = 0.0868 * (1 + 0.03 + 0.09 + 0.52) * 1.02
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(data_type=2, debug_mode=True),
        year="2025",
        ref_dir=Path("unused"),
    )

    expected = 0.1 * (1 + MULTI_PROV) * 1.02 * 17
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0


def test_error_on_missing_weights(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda *_: WEIGHTS.iloc[0:0])
    def _weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame(
            {"TIER2_CLINIC": [99.99], "clinic_pw": [1.0], "tier2_adj_paed": [1.0]}
        )

    monkeypatch.setattr(outpatients, "_load_weights", _weights)
    df = pd.DataFrame({"TIER2_CLINIC": [99.99], "FUNDSC": [1]})
    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(data_type=2),
        year="2025",
        ref_dir=Path("unused"),
    )

    expected = 0.1 * (1 + 0.2) * (1 + 0.03) * 2
    assert result["NWAU25"].iloc[0] == pytest.approx(expected, rel=1e-4)
    assert result["Error_Code"].iloc[0] == 0

def test_clinic_level_flow():
    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [99.99],
            "FUNDSC": [1],
            "SERVICE_DATE": [pd.Timestamp("2025-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "PAT_REMOTENESS": [0],
        }
    )
        }
    )
    
    params = outpatients.OutpatientParams(data_type=2)
    result = outpatients.calculate_outpatients(
        df,
        params,
        year="2025",
        ref_dir=Path("unused"),
    )
    expected = 0.0868 * (1 + 0.52) * 1.02 * 4
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0


def test_error_missing_weight(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda r, y: WEIGHTS.iloc[0:0])
    df = pd.DataFrame({"TIER2_CLINIC": [10.99], "FUNDSC": [1]})
    params = outpatients.OutpatientParams(data_type=2)
    result = outpatients.calculate_outpatients(
        df,
        params,
        year="2025",
        ref_dir=Path("unused"),
    )
    assert result["Error_Code"].iloc[0] == 3
    assert result["NWAU25"].iloc[0] == 0


def test_missing_weight_error():
    df = pd.DataFrame({"TIER2_CLINIC": [99.99], "FUNDSC": [1]})

    result = outpatients.calculate_outpatients(
        df.copy(),
        outpatients.OutpatientParams(debug_mode=True),
        year="2025",
        ref_dir=Path("unused"),
    )

    assert result["Error_Code"].iloc[0] == 3
    assert result["NWAU25"].iloc[0] == 0
