import importlib.util
from pathlib import Path
import sys

import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

spec = importlib.util.spec_from_file_location(
    "mh",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "mh.py",
)
mh = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mh)

DATA = pd.DataFrame({"AMHCC": ["111A"], "PAT_PRIVATE_FLAG": [0], "PAT_SAMEDAY_FLAG": [0], "LOS": [10]})

EXPECTED = 7.0317


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_mh_matches_sas_weights(monkeypatch, year):
    weights = pd.DataFrame({"AMHCC": ["111A"], "amhcc_pw_inlier": [EXPECTED]})

    def _load(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        return weights

    monkeypatch.setattr(mh, "_load_weights", _load)

    result = mh.calculate_mh(
        DATA.copy(),
        mh.MHParams(),
        year=year,
        ref_dir=Path("unused"),
    )
    assert result["NWAU25"].iloc[0] == pytest.approx(EXPECTED, rel=1e-4)

