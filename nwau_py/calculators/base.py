"""Shared helpers for calculator modules."""

from __future__ import annotations

from pathlib import Path

import pandas as pd
import pyreadstat


_DATA_DIR = (
    Path(__file__).resolve().parents[2]
    / "archive/sas/NEP25_SAS_NWAU_calculator/calculators"
)


def load_sas_table(name: str) -> pd.DataFrame:
    """Load ``name`` from the bundled SAS tables."""
    path = _DATA_DIR / name
    df, _ = pyreadstat.read_sas7bdat(str(path))
    for col in df.select_dtypes(object).columns:
        df[col] = df[col].astype(str).str.strip()
    return df


class BaseCalculator:
    """Base class providing access to SAS reference tables."""

    ref_dir: Path

    def __init__(self, ref_dir: Path | None = None) -> None:
        self.ref_dir = ref_dir or _DATA_DIR

    def table(self, filename: str) -> pd.DataFrame:
        """Return a SAS table from ``self.ref_dir``."""
        return load_sas_table(str(self.ref_dir / filename))
