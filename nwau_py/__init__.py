"""Tools for reproducing IHACPA National Weighted Activity Units.

Keep the package import light so utility modules such as provenance helpers can
be imported without pulling in optional scoring dependencies.
"""

from __future__ import annotations

__all__ = ["score_readmission"]


def __getattr__(name: str):
    """Lazily expose heavyweight public symbols on demand."""
    if name == "score_readmission":
        from .scoring import score_readmission

        return score_readmission
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
