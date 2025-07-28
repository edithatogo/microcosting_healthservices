"""Tools for reproducing IHACPA National Weighted Activity Units."""

import sys
from pathlib import Path
import importlib.util

_SRC_PATH = Path(__file__).resolve().parents[1] / "src"
if _SRC_PATH.exists():
    sys.path.insert(0, str(_SRC_PATH))
    __path__.append(str(_SRC_PATH / "nwau_py"))

from nwau_py.scoring.scorer import score_readmission  # noqa: E402
_SCORER_PATH = _SRC_PATH / "nwau_py" / "scoring" / "scorer.py"
if _SCORER_PATH.exists():
    spec = importlib.util.spec_from_file_location(
        "nwau_py.scoring.scorer", _SCORER_PATH
    )
    assert spec is not None
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    score_readmission = module.score_readmission
else:
    from nwau_py.scoring.score import score_readmission

__all__ = ["groupers", "score_readmission"]
