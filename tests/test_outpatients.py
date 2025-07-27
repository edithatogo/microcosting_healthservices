import importlib.util
import sys
from pathlib import Path

import numpy as np
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
        "clinic_pw": [0.0868],
        "tier2_adj_paed": [1.0],
    }
)


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_outpatients_matches_sas_weights(monkeypatch, year):
    monkeypatch.setattr(outpatients, "_load_weights", lambda ref_dir, year: WEIGHTS)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "FUNDSC": [1],
        }
    )

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(),
        year=year,
        ref_dir=Path("unused"),
    )

    assert result["NWAU25"].iloc[0] == pytest.approx(0.0868, rel=1e-4)


def test_calculate_outpatients_patient_flow(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda ref_dir, year: WEIGHTS)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2010-01-01")],
            "PAT_MULTIPROV_FLAG": [0],
            "EST_ELIGIBLE_PAED_FLAG": [1],
            "FUNDSC": [1],
        }
    )

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(),
        year="2025",
        ref_dir=Path("unused"),
    )

    assert np.allclose(result["NWAU25"].values, [0.0868])
    assert result["Error_Code"].iloc[0] == 0


def test_paediatric_option_apcid_lookup(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda ref_dir, year: WEIGHTS)

    icu_df = pd.DataFrame({"APCID": ["H1"], "_est_eligible_paed_flag": [1]})
    monkeypatch.setattr(outpatients, "_load_icu_list", lambda ref_dir, year: icu_df)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
            "BIRTH_DATE": [pd.Timestamp("2015-01-01")],
            "APCID": ["H1"],
            "PAT_MULTIPROV_FLAG": [0],
            "FUNDSC": [1],
        }
    )

    result = outpatients.calculate_outpatients(
        df,
        outpatients.OutpatientParams(paed_option=1),
        year="2025",
        ref_dir=Path("unused"),
    )

    assert result["_pat_eligible_paed_flag"].iloc[0] == 1
    assert result["NWAU25"].iloc[0] == pytest.approx(0.0868)


def test_calculate_outpatients_aggregate(monkeypatch):
    monkeypatch.setattr(outpatients, "_load_weights", lambda ref_dir, year: WEIGHTS)

    df = pd.DataFrame(
        {
            "TIER2_CLINIC": [10.01],
            "GROUP_EVENT_COUNT": [1],
            "INDIV_EVENT_COUNT": [2],
            "MULTI_DISP_CONF_COUNT": [3],
            "PAT_MULTIPROV_FLAG": [1],
            "adj_multiprov": [0.1],
            "adj_treat_remoteness": [0.2],
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

    expected = 0.0868 * 1.1 * 1.2 * 6
    assert result["NWAU25"].iloc[0] == pytest.approx(expected)
    assert result["Error_Code"].iloc[0] == 0

