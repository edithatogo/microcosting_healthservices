import importlib.util
from pathlib import Path
import sys

import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "ed",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "ed.py",
)
ed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ed)

DATA = pd.DataFrame(
    {
        "AECC": ["E0110A"],
        "Error_Code": [0],
        "adj_indigenous": [0.0],
        "adj_remoteness": [0.0],
        "adj_treat_remoteness": [0.0],
    }
)

EXPECTED = 0.2837


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_ed_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({"AECC": ["E0110A"], "aecc_pw": [EXPECTED]})

    def _load(ref_dir: Path, classification_option: int, year: str = "2025") -> pd.DataFrame:
        return weights

    monkeypatch.setattr(ed, "_load_weights", _load)

    result = ed.calculate_ed(
        DATA.copy(),
        ed.EDParams(classification_option=3),
        year=year,
        ref_dir=Path("unused"),
    )
    assert result["NWAU25"].iloc[0] == pytest.approx(EXPECTED, rel=1e-4)

