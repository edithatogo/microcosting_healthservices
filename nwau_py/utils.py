from pathlib import Path


_DIRECTORY_MAP = {
    "13": "NEP13 SAS NWAU Calculator/calculator",
    "14": "NEP14 SAS NWAU Calculator/calculator",
    "15": "NEP15 SAS NWAU Calculator/Calculators",
    "16": "NEP16 SAS NWAU Calculator/SAS Calculators",
    "17": "NEP17 SAS NWAU Calculator/01 Calculators",
    "18": "NEP18 SAS NWAU Calculator/Calculator",
    "19": "NEP19 SAS NWAU Calculator/Calculators",
    "20": "NEP20 SAS NWAU Calculator/Calculators",
    "21": "NEP21 SAS NWAU Calculator/Calculators",
    "22": "NEP22 SAS NWAU Calculator/calculators",
    "23": "NEP23_SAS_NWAU_calculator/calculators",
    "24": "NWAU24_SAS_Calculator/calculators",
    "25": "NEP25_SAS_NWAU_calculator/calculators",
}


def sas_ref_dir(year: str = "2025") -> Path:
    """Return path to SAS calculators for ``year``.

    Parameters
    ----------
    year:
        The NEP/NWAU edition year, e.g. ``"2025"``.
    """
    suffix = str(year)[-2:]
    base = Path("archive") / "sas"

    if suffix in _DIRECTORY_MAP:
        return base / _DIRECTORY_MAP[suffix]

    # Fallback heuristic matching known directory patterns
    patterns = [
        f"NEP{suffix} SAS NWAU Calculator/calculator",
        f"NEP{suffix}_SAS_NWAU_calculator/calculators",
        f"NWAU{suffix}_SAS_Calculator/calculators",
    ]

    for pattern in patterns:
        candidate = base / pattern
        if candidate.exists():
            return candidate

    raise FileNotFoundError(f"SAS reference directory for {year} not found")
