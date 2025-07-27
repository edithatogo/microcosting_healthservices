"""Tools for reproducing IHACPA National Weighted Activity Units."""

from pathlib import Path
import sys

# When running from the repository, ensure helpers in ``src`` are importable
_SRC_PATH = Path(__file__).resolve().parents[1] / "src"
if _SRC_PATH.exists():
    sys.path.insert(0, str(_SRC_PATH))
    __path__.append(str(_SRC_PATH / "nwau_py"))

from nwau_py.scoring.score import score_readmission

__all__ = ["groupers", "score_readmission"]
