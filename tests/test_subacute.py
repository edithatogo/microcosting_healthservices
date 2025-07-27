import importlib.util
from pathlib import Path

import numpy as np
import pandas as pd

spec = importlib.util.spec_from_file_location(
    "subacute",
    Path(__file__).resolve().parents[1] / "nwau_py" / "calculators" / "subacute.py",
)
subacute = importlib.util.module_from_spec(spec)
spec.loader.exec_module(subacute)

DATA = pd.DataFrame(
    {
        "ANSNAP": ["5AZ1"],
        "ADM_DATE": [pd.Timestamp("2024-07-01")],
        "SEP_DATE": [pd.Timestamp("2024-08-10")],
        "LEAVE_DAYS": [0],
        "BIRTH_DATE": [pd.Timestamp("1980-01-01")],
        "PAT_PRIVATE_FLAG": [0],
        "PAT_PUBLIC_FLAG": [1],
        "STATE": [1],
    }
)
EXPECTED = np.array([13.4327])

def test_calculate_subacute_basic(monkeypatch):
    def _load_csv(ref_dir: Path, year: str = "2025") -> pd.DataFrame:
        df = pd.read_csv("tests/data/nep25_sa_snap_price_weights.csv")
        return df.rename(columns={"ansnap": "ANSNAP"})

    monkeypatch.setattr(subacute, "_load_weights", _load_csv)
    result = subacute.calculate_subacute(
        DATA.copy(),
        subacute.SubacuteParams(),
        year="2025",
        ref_dir=Path("."),
    )
    assert np.allclose(result["NWAU25"].values, EXPECTED)
    assert result["Error_Code"].iloc[0] == 0
