"""Tools for reproducing IHACPA National Weighted Activity Units."""

import sys
from pathlib import Path

# When running from the repository, ensure helpers in ``src`` are importable
_SRC_PATH = Path(__file__).resolve().parents[1] / "src"
if _SRC_PATH.exists():
    sys.path.insert(0, str(_SRC_PATH))
    __path__.append(str(_SRC_PATH / "nwau_py"))

from nwau_py.scoring.scorer import score_readmission  # noqa: E402

__all__ = ["groupers", "score_readmission"]
