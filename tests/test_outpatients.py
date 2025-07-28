import importlib.util
import sys
from pathlib import Path

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

WEIGHTS = pd.DataFrame(
    {
        "TIER2_CLINIC": [10.01],
        "clinic_pw": [0.1],
        "tier2_adj_paed": [1.0],
        "adj_indigenous": [0.1],
        "adj_remoteness": [0.2],
        "adj_treat_remoteness": [0.03],
        "adj_multiprov": [0.2],
    }
)


@pytest.fixture(autouse=True)
def _patch(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda *_: WEIGHTS)
    monkeypatch.setattr(
        outpatients,
        "_load_hospital_ra",
        lambda *_: pd.DataFrame({"APCID": ["AP1"], "_hosp_ra_2021": [1]}),
    )
    monkeypatch.setattr(
        outpatients,
        "_load_postcode_ra",
        lambda *_: pd.DataFrame({"POSTCODE": ["PC1"], "ra2021": [2]}),
    )
    monkeypatch.setattr(
        outpatients,
        "_load_sa2_ra",
        lambda *_: pd.DataFrame({"SA2": [12345], "ra2021": [3]}),
    )
    monkeypatch.setattr(
        outpatients,
        "_load_icu_list",
        lambda *_: pd.DataFrame({"APCID": ["AP1"], "_est_eligible_paed_flag": [1]}),
    )


def test_patient_level_with_adjustments():
    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "APCID": ["AP1"],
            "PAT_POSTCODE": ["PC1"],
            "PAT_SA2": [12345],
            "PAT_REMOTENESS": [1],
            "INDSTAT": [1],
            "PAT_MULTIPROV_FLAG": [0],
            "FUNDSC": [1],
        }
    )

    params = outpatients.OutpatientParams(debug_mode=True)
    result = outpatients.calculate_outpatients(
        df,
        params,
        year="2025",
        ref_dir=Path("unused"),
    )


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

    expected = 0.1 * (1 + 0.1 + 0.2) * (1 + 0.03)
    assert result["NWAU25"].iloc[0] == pytest.approx(expected, rel=1e-4)
    assert result["_pat_eligible_paed_flag"].iloc[0] == 1
    assert result["Error_Code"].iloc[0] == 0


def test_clinic_level_multiprovider():
    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "GROUP_EVENT_COUNT": [1],
            "INDIV_EVENT_COUNT": [1],
            "MULTI_DISP_CONF_COUNT": [0],
            "PAT_MULTIPROV_FLAG": [1],
            "FUNDSC": [1],
        }
    )

    params = outpatients.OutpatientParams(data_type=2)
    result = outpatients.calculate_outpatients(
        df,
        params,
        year="2025",
        ref_dir=Path("unused"),
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

    assert result["Error_Code"].iloc[0] == 3
    assert result["NWAU25"].iloc[0] == 0
