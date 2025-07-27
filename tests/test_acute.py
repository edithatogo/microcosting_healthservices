import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np
import pandas as pd
import pytest

spec = importlib.util.spec_from_file_location(
    "acute",
    Path(__file__).resolve().parents[1]
    / "nwau_py"
    / "calculators"
    / "acute.py",
)
acute = importlib.util.module_from_spec(spec)
spec.loader.exec_module(acute)

DATA = pd.DataFrame(
    {
        "DRG": ["801A", "801A", "801A"],
        "LOS": [5, 10, 80],
        "ICU_HOURS": [0, 0, 0],
        "ICU_OTHER": [0, 0, 0],
        "PAT_SAMEDAY_FLAG": [0, 0, 0],
        "PAT_PRIVATE_FLAG": [0, 0, 0],
        "PAT_COVID_FLAG": [0, 0, 0],
    }
)

EXPECTED = np.array([6.8772, 9.2472, 11.3272])


@pytest.mark.parametrize("year", ["2024", "2025"])
def test_calculate_acute_matches_sas_weights(monkeypatch, year):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        suffix = str(year)[-2:]
        path = ref_dir / f"nep{suffix}_aa_price_weights.csv"
        df = pd.read_csv(path)
        df["DRG"] = df["DRG"].str.strip("b'")
        return df

    monkeypatch.setattr(acute, "_load_price_weights", _load_csv)

    ref_dir = Path("tests/data") / year
    result = acute.calculate_acute(
        DATA.copy(),
        acute.AcuteParams(),
        year=year,
        ref_dir=ref_dir,
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED)
    assert not any(col.startswith("_") for col in result.columns)

    debug = acute.calculate_acute(
        DATA.copy(),
        acute.AcuteParams(debug_mode=True),
        year=year,
        ref_dir=ref_dir,
    )
    assert any(col.startswith("_") for col in debug.columns)
