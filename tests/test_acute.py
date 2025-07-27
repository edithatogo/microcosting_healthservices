import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np
import pandas as pd

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


def test_calculate_acute_matches_sas_weights():
    result = acute.calculate_acute(DATA.copy(), acute.AcuteParams())
    assert np.allclose(result["NWAU25"].values, EXPECTED)
