import importlib.util
from pathlib import Path
import sys

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

DATA = pd.DataFrame({"CLINIC_CODE": [10.01], "adj_indigenous": [0.0], "adj_remoteness": [0.0]})

EXPECTED = 0.0868


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_outpatients_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({"CLINIC_CODE": [10.01], "op_pw": [EXPECTED]})

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

