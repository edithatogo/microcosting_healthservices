from pathlib import Path

# Mapping from NEP/NWAU pricing year to the corresponding
# remoteness area (RA) classification year.  The mapping is
# derived from the directory names of the archived SAS
# calculators under ``archive/sas``.
RA_VERSION = {
    "2025": "2021",
    "2024": "2021",
    "2023": "2016",
    "2022": "2016",
    "2021": "2016",
    "2020": "2016",
    "2019": "2011",
    "2018": "2011",
    "2017": "2011",
    "2016": "2011",
    "2015": "2011",
    "2014": "2011",
    "2013": "2006",
}


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


def ra_suffix(year: str) -> str:
    """Return the remoteness area suffix for ``year``.

    Parameters
    ----------
    year:
        Pricing year used by the calculators, e.g. ``"2025"``.

    Returns
    -------
    str
        The suffix such as ``"ra2021"`` or ``"ra2011"``.
    """

    ra_year = RA_VERSION[str(year)]
    return f"ra{ra_year}"
