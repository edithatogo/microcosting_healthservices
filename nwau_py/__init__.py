"""Tools for reproducing IHACPA National Weighted Activity Units."""

from pathlib import Path
import sys

# When running from the repository, ensure helpers in ``src`` are importable
_SRC_PATH = Path(__file__).resolve().parents[1] / "src"
if _SRC_PATH.exists():
    sys.path.insert(0, str(_SRC_PATH))
    __path__.append(str(_SRC_PATH / "nwau_py"))

import importlib.util

_SCORER_PATH = _SRC_PATH / "nwau_py" / "scoring" / "scorer.py"
if _SCORER_PATH.exists():
    spec = importlib.util.spec_from_file_location("nwau_py.scoring.scorer", _SCORER_PATH)
    _module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(_module)
    score_readmission = _module.score_readmission
else:
    from nwau_py.scoring.score import score_readmission  # fallback placeholder

__all__ = ["groupers", "score_readmission"]
