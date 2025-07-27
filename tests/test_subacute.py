import importlib.util
from pathlib import Path
import sys

import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "subacute",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "subacute.py",
)
subacute = importlib.util.module_from_spec(spec)
spec.loader.exec_module(subacute)

DATA = pd.DataFrame({"SNAP": ["5AZ1"], "adj_indigenous": [0.0], "adj_remoteness": [0.0]})

EXPECTED = 13.4327


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_subacute_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({"SNAP": ["5AZ1"], "snap_pw": [EXPECTED]})

    def _load(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return weights

    monkeypatch.setattr(subacute, "_load_weights", _load)

    result = subacute.calculate_subacute(
        DATA.copy(),
        subacute.SubacuteParams(),
        year=year,
        ref_dir=Path("unused"),
    )
    assert result["NWAU25"].iloc[0] == pytest.approx(EXPECTED, rel=1e-4)

