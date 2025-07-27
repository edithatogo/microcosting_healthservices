from pathlib import Path


def sas_ref_dir(year: str = "2025") -> Path:
    """Return path to SAS calculators for a given year.

    Parameters
    ----------
    year:
        The NEP/NWAU edition year, e.g. ``"2025"``.

    The folder structure of archived SAS releases has changed over the years.
    ``sas_ref_dir`` therefore searches for possible directory patterns and
    returns the first match.
    """
    suffix = str(year)[-2:]
    base = Path("archive") / "sas"

    patterns = [
        f"NEP{suffix}_SAS_NWAU_calculator",
        f"NWAU{suffix}_SAS_Calculator",
        f"NEP{suffix} SAS NWAU Calculator",
    ]

    for pattern in patterns:
        candidate = base / pattern
        if candidate.exists():
            # Look for a subdirectory containing the calculator tables.  The
            # name has varied between releases (e.g. ``calculators``,
            # ``Calculator``, ``01 Calculators``).
            for sub in candidate.iterdir():
                if sub.is_dir() and "calculator" in sub.name.lower():
                    return sub
            return candidate

    raise FileNotFoundError(f"No SAS reference directory found for year {year}")
