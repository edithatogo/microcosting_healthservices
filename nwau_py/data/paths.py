from __future__ import annotations

from pathlib import Path

from nwau_py.utils import ra_suffix, sas_ref_dir


def data_dir(year: str = "2025") -> Path:
    """Return the directory containing weights/formula files for ``year``."""
    base = Path("excel_calculator/data")
    return base if year == "2025" else base / year


def weights_csv(year: str = "2025") -> Path:
    """Return path to ``weights.csv`` for ``year``."""
    return data_dir(year) / "weights.csv"


def formula_json(year: str = "2025") -> Path:
    """Return path to ``formula.json`` for ``year``."""
    return data_dir(year) / "formula.json"


def sas_table(
    pattern: str,
    *,
    year: str = "2025",
    base_dir: Path | None = None,
) -> Path:
    """Return the path to a SAS table.

    ``pattern`` may contain ``{suffix}``, ``{ra}``, ``{ra_year}`` and ``{year}``
    placeholders which will be substituted based on ``year``.
    """
    suffix = str(year)[-2:]
    ra = ra_suffix(year)
    base = Path(base_dir) if base_dir is not None else sas_ref_dir(year)
    return base / pattern.format(year=year, suffix=suffix, ra=ra, ra_year=ra[2:])

