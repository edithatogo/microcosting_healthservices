"""Abstract interfaces for grouping algorithms."""

from __future__ import annotations

from abc import ABC, abstractmethod

import pandas as pd


class BaseGrouper(ABC):
    """Base class for activity groupers."""

    @abstractmethod
    def group(self, df: pd.DataFrame) -> pd.DataFrame:
        """Return grouped or annotated ``df`` data."""


__all__ = ["BaseGrouper"]
