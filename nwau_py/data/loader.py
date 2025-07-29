"""Data loading utilities for NWAU project"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import pandas as pd
import pyreadstat

_HAS_PARQUET = importlib.util.find_spec("pyarrow") is not None


def load_sas_table(
    path: str | Path,
    cache: bool = True,
    cache_format: str = "parquet",
    cache_dir: str | Path = ".cache",
    force: bool = False,
) -> pd.DataFrame:
    """Load a SAS ``.sas7bdat`` table.

    Parameters
    ----------
    path:
        Path to the ``.sas7bdat`` file.
    cache:
        Whether to cache the loaded table.
    cache_format:
        ``"parquet"`` or ``"csv"``. Falls back to ``"csv"`` when
        ``pyarrow`` is not available.
    cache_dir:
        Directory where cache files are stored.
    force:
        If ``True`` the SAS file will be read even if a cached version exists.
    """
    path = Path(path)
    cache_dir = Path(cache_dir)
    ext_map = {"parquet": ".parquet", "csv": ".csv"}
    if cache_format not in ext_map:
        raise ValueError("cache_format must be 'parquet' or 'csv'")
    if cache_format == "parquet" and not _HAS_PARQUET:
        cache_format = "csv"
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_path = cache_dir / f"{path.stem}{ext_map[cache_format]}"

    if cache and cache_path.exists() and not force:
        if cache_format == "parquet":
            return pd.read_parquet(cache_path)
        else:
            return pd.read_csv(cache_path)

    df, _ = pyreadstat.read_sas7bdat(str(path))

    if cache:
        if cache_format == "parquet":
            df.to_parquet(cache_path, index=False)
        else:
            df.to_csv(cache_path, index=False)
    return df
