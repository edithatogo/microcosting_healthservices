import importlib
import sys
from pathlib import Path

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
nwau_py = importlib.import_module("nwau_py")  # noqa: E402
importlib.reload(nwau_py)
from nwau_py import score_readmission  # noqa: E402

CALC_DIR = Path(__file__).resolve().parents[1] / "archive" / "sas" / "NEP25_SAS_NWAU_calculator" / "calculators"

_risk_factors = pd.read_csv(CALC_DIR / "models" / "risk_factors.csv", index_col=0)
features = set()
for i in range(1, 13):
    features.update(_risk_factors[str(i)].dropna().tolist())
features.update([
    "an110mdc_ra",
    "agegroup_rm",
    "flag_emergency",
    "pat_remoteness",
    "indstat_flag",
    "count_proc",
    "adm_past_year",
    "drg11_type",
])

example = {col: [0] for col in features}
example["drg11_type"] = ["M"]
example["an110mdc_ra"] = ["1"]


def test_score_readmission_runs():
    df = pd.DataFrame(example)
    result = score_readmission(df)
    assert result.shape[1] == 24
    assert set(result.columns) == {f"risk_category{i}" for i in range(1, 13)} | {f"dampening{i}" for i in range(1, 13)}
    assert not result.isna().all().all()
