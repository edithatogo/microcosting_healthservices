from pathlib import Path


def sas_ref_dir(year: str = "2025") -> Path:
    """Return path to SAS calculators for a given year.

    Parameters
    ----------
    year:
        The NEP/NWAU edition year, e.g. "2025".
    """
    suffix = str(year)[-2:]
    return Path("archive") / "sas" / f"NEP{suffix}_SAS_NWAU_calculator" / "calculators"
