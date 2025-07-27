"""Abstract interfaces for funding calculators."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass

import pandas as pd


@dataclass
class CalculatorParams:
    """Common options for calculator implementations."""


class BaseCalculator(ABC):
    """Base class for NWAU calculators."""

    params: CalculatorParams

    def __init__(self, params: CalculatorParams) -> None:
        self.params = params

    @abstractmethod
    def calculate(self, df: pd.DataFrame) -> pd.DataFrame:
        """Return ``df`` augmented with calculator specific columns."""


__all__ = ["CalculatorParams", "BaseCalculator"]
