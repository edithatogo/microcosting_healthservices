import importlib.util
from pathlib import Path
import sys

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

DATA = pd.DataFrame({
    "TIER2_CLINIC": [10.01],
    "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
    "BIRTH_DATE": [pd.Timestamp("1990-01-01")],
    "PAT_MULTIPROV_FLAG": [0],
    "EST_ELIGIBLE_PAED_FLAG": [1],
})
EXPECTED = 0.0868


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_outpatients_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({"TIER2_CLINIC": [10.01], "clinic_pw": [EXPECTED], "tier2_adj_paed": [1.0]})

    def _load(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return weights

    monkeypatch.setattr(outpatients, "_load_weights", _load)

    result = outpatients.calculate_outpatients(
        DATA.copy(),
        outpatients.OutpatientParams(),
        year=year,
        ref_dir=Path("unused"),
    )
    assert result["NWAU25"].iloc[0] == pytest.approx(EXPECTED, rel=1e-4)

DATA = pd.DataFrame(
    {
        "TIER2_CLINIC": [10.01],
        "SERVICE_DATE": [pd.Timestamp("2024-07-01")],
        "BIRTH_DATE": [pd.Timestamp("1990-01-01")],
        "PAT_MULTIPROV_FLAG": [0],
        "EST_ELIGIBLE_PAED_FLAG": [1],
    }
)
EXPECTED = np.array([0.0868])

def test_calculate_outpatients_basic(monkeypatch):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_op_price_weights.csv")
        return df.rename(columns={"tier2_clinic": "TIER2_CLINIC"})

    monkeypatch.setattr(outpatients, "_load_weights", _load_csv)
    result = outpatients.calculate_outpatients(
        DATA.copy(),
        outpatients.OutpatientParams(),
        year="2025",
        ref_dir=Path("."),
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED)
    assert result["Error_Code"].iloc[0] == 0


def test_calculate_outpatients_option_paths(monkeypatch):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_op_price_weights.csv")
        return df.rename(columns={"tier2_clinic": "TIER2_CLINIC"})

    monkeypatch.setattr(outpatients, "_load_weights", _load_csv)

    data = DATA.copy()
    data["PAT_REMOTENESS"] = 0

    params = outpatients.OutpatientParams(
        paed_option=2,
        est_remoteness_option=2,
    )

    result = outpatients.calculate_outpatients(
        data,
        params,
        year="2025",
        ref_dir=Path("."),
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED)
    assert result["Error_Code"].iloc[0] == 0
