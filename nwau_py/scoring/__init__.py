"""Scoring utilities subpackage."""

from pathlib import Path

# When running from the repository, also search for modules under ``src``
_SRC = Path(__file__).resolve().parents[2] / "src" / "nwau_py" / "scoring"
if _SRC.exists():
    __path__.append(str(_SRC))

from .scorer import score_readmission  # noqa: E402

__all__ = ["score_readmission"]
