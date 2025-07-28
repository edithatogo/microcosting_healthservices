import importlib.util
import sys
from pathlib import Path

import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "outpatients",
    Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "outpatients.py",
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

    expected = 0.1 * (1 + 0.2) * (1 + 0.03) * 2
    assert result["NWAU25"].iloc[0] == pytest.approx(expected, rel=1e-4)
    assert result["Error_Code"].iloc[0] == 0


def test_missing_weight_error():
    df = pd.DataFrame({"TIER2_CLINIC": [99.99], "FUNDSC": [1]})

    params = outpatients.OutpatientParams(data_type=2)
    result = outpatients.calculate_outpatients(
        df,
        params,
        year="2025",
        ref_dir=Path("unused"),
    )

    assert result["Error_Code"].iloc[0] == 3
    assert result["NWAU25"].iloc[0] == 0
