import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pandas as pd
import pytest

from nwau_py.utils import ra_suffix

spec = importlib.util.spec_from_file_location(
    "outpatients",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "outpatients.py",
)
outpatients = importlib.util.module_from_spec(spec)
spec.loader.exec_module(outpatients)


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

    monkeypatch.setattr(outpatients, "_load_hospital_ra", _hospital)
    monkeypatch.setattr(outpatients, "_load_postcode_ra", _postcode)
    monkeypatch.setattr(outpatients, "_load_sa2_ra", _sa2)
    monkeypatch.setattr(outpatients, "_load_icu_list", _icu)


def test_patient_level_with_adjustments(monkeypatch):
    def _weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame(
            {
                "TIER2_CLINIC": [10.01],
                "clinic_pw": [1.0],
                "tier2_adj_paed": [1.5],
            }
        )

    monkeypatch.setattr(outpatients, "_load_weights", _weights)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2025-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "PAT_POSTCODE": ["PC1"],
            "PAT_SA2": [123],
            "APCID": ["APC1"],
            "INDSTAT": [1],
            "adj_indigenous": [0.05],
            "adj_remoteness": [0.1],
            "adj_treat_remoteness": [0.02],
            "FUNDSC": [1],
            "PAT_MULTIPROV_FLAG": [0],
        }
    )

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(debug_mode=True, est_remoteness_option=1),
        year="2025",
        ref_dir=Path("unused"),
    )

    assert result["_treat_remoteness"].iloc[0] == 5
    assert result["_pat_eligible_paed_flag"].iloc[0] == 1
    expected = 1.5 * (1 + 0.05 + 0.1) * (1 + 0.02)
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)


def test_clinic_level_multiprovider(monkeypatch):
    def _weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame(
            {
                "TIER2_CLINIC": [10.01],
                "clinic_pw": [1.0],
                "adj_multiprov": [0.1],
            }
        )

    monkeypatch.setattr(outpatients, "_load_weights", _weights)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "GROUP_EVENT_COUNT": [10],
            "INDIV_EVENT_COUNT": [5],
            "MULTI_DISP_CONF_COUNT": [2],
            "PAT_MULTIPROV_FLAG": [1],
        }
    )

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(data_type=2, debug_mode=True),
        year="2025",
        ref_dir=Path("unused"),
    )

    assert result["NWAU25"].iloc[0] == pytest.approx(18.7)
    assert result["Error_Code"].iloc[0] == 0


def test_error_on_missing_weights(monkeypatch):
    def _weights(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return pd.DataFrame(
            {"TIER2_CLINIC": [99.99], "clinic_pw": [1.0], "tier2_adj_paed": [1.0]}
        )

    monkeypatch.setattr(outpatients, "_load_weights", _weights)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2025-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "FUNDSC": [1],
        }
    )

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(debug_mode=True),
        year="2025",
        ref_dir=Path("unused"),
    )

    assert result["Error_Code"].iloc[0] == 3
    assert result["NWAU25"].iloc[0] == 0
