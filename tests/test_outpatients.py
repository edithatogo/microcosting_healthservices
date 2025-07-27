import importlib.util
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "outpatients",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "outpatients.py",
)
outpatients = importlib.util.module_from_spec(spec)
spec.loader.exec_module(outpatients)

WEIGHTS = pd.DataFrame({
    "TIER2_CLINIC": [10.01],
    "clinic_pw": [0.0868],
    "tier2_adj_paed": [1.0],
})

IND_ADJ = pd.DataFrame({"_pat_ind_flag": [0, 1], "adj_indigenous": [0.0, 0.03]})
REM_ADJ = pd.DataFrame({
    "_pat_remoteness": [0, 1, 2, 3],
    "adj_remoteness": [0.0, 0.0, 0.09, 0.2],
})
TREAT_ADJ = pd.DataFrame({
    "_treat_remoteness": [0, 1, 2, 3],
    "adj_treat_remoteness": [0.0, 0.0, 0.0, 0.02],
})


@pytest.fixture(autouse=True)
def _patch_loaders(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda r, y: WEIGHTS)
    monkeypatch.setattr(outpatients, "_load_multi_prov_adj", lambda r, y: 0.52)
    monkeypatch.setattr(
        outpatients,
        "_load_hospital_ra",
        lambda r, y: pd.DataFrame({"APCID": ["H1"], "_hosp_ra_2021": [3]}),
    )
    monkeypatch.setattr(
        outpatients,
        "_load_postcode_ra",
        lambda r: pd.DataFrame({"POSTCODE": [2000], "ra2021": [3]}),
    )
    monkeypatch.setattr(
        outpatients,
        "_load_sa2_ra",
        lambda r: pd.DataFrame({"ASGS": ["S1"], "ra2021": [2]}),
    )
    monkeypatch.setattr(
        outpatients,
        "_load_icu_list",
        lambda r, y: pd.DataFrame({"APCID": ["H1"], "_est_eligible_paed_flag": [1]}),
    )
    monkeypatch.setattr(outpatients, "_load_ind_adj", lambda r, y: IND_ADJ)
    monkeypatch.setattr(outpatients, "_load_pat_rem_adj", lambda r, y: REM_ADJ)
    monkeypatch.setattr(outpatients, "_load_treat_rem_adj", lambda r, y: TREAT_ADJ)


def test_patient_level_flow():
    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "PAT_POSTCODE": [2000],
            "PAT_SA2": ["S1"],
            "APCID": ["H1"],
            "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2015-01-01")],
            "PAT_MULTIPROV_FLAG": [1],
            "INDSTAT": [1],
            "FUNDSC": [1],
        }
    )
    result = outpatients.calculate_outpatients(df, outpatients.OutpatientParams(), year="2025", ref_dir=Path("unused"))
    expected = 0.0868 * (1 + 0.03 + 0.09 + 0.52) * 1.02
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0


def test_clinic_level_flow():
    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "APCID": ["H1"],
            "GROUP_EVENT_COUNT": [1],
            "INDIV_EVENT_COUNT": [1],
            "MULTI_DISP_CONF_COUNT": [2],
            "PAT_MULTIPROV_FLAG": [1],
            "FUNDSC": [1],
        }
    )
    params = outpatients.OutpatientParams(data_type=2)
    result = outpatients.calculate_outpatients(df, params, year="2025", ref_dir=Path("unused"))
    expected = 0.0868 * (1 + 0.52) * 1.02 * 4
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0


def test_error_missing_weight(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda r, y: WEIGHTS.iloc[0:0])
    df = pd.DataFrame({"TIER2_CLINIC": [10.99], "FUNDSC": [1]})
    params = outpatients.OutpatientParams(data_type=2)
    result = outpatients.calculate_outpatients(df, params, year="2025", ref_dir=Path("unused"))
    assert result["Error_Code"].iloc[0] == 3
    assert result["NWAU25"].iloc[0] == 0

