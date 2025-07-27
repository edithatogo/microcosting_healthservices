"""Shared helpers for grouper logic."""

from __future__ import annotations

from pathlib import Path

import pandas as pd
import pyreadstat


_DATA_DIR = (
    Path(__file__).resolve().parents[2]
    / "archive/sas/NEP25_SAS_NWAU_calculator/calculators"
)


def load_mapping(name: str) -> pd.DataFrame:
    """Load a mapping table distributed with the SAS calculator."""
    path = _DATA_DIR / name
    df, _ = pyreadstat.read_sas7bdat(str(path))
    df.columns = df.columns.str.strip()
    return df
