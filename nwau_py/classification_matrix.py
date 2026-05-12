"""Year-by-year classification compatibility matrix for IHACPA NWAU calculators."""

from __future__ import annotations

__all__ = [
    "AECC_VERSIONS",
    "AMHCC_VERSIONS",
    "AN_SNAP_VERSIONS",
    "AR_DRG_VERSIONS",
    "CLASSIFICATION_SYSTEMS",
    "LICENSED_CLASSIFICATIONS",
    "TIER_2_VERSIONS",
    "UDG_VERSIONS",
    "get_classification_name",
    "get_classification_version",
    "get_supported_years",
    "get_transition_years",
    "is_classification_licensed",
]

CLASSIFICATION_SYSTEMS: dict[str, str] = {
    "ar_drg": "AR-DRG",
    "aecc": "AECC",
    "udg": "UDG",
    "tier_2": "Tier 2",
    "amhcc": "AMHCC",
    "an_snap": "AN-SNAP",
}

LICENSED_CLASSIFICATIONS: frozenset[str] = frozenset({
    "ar_drg",
    "aecc",
    "udg",
    "tier_2",
    "amhcc",
    "an_snap",
})

AR_DRG_VERSIONS: dict[str, str] = {
    "2013": "v7.0",
    "2014": "v7.0",
    "2015": "v7.0",
    "2016": "v8.0",
    "2017": "v8.0",
    "2018": "v9.0",
    "2019": "v9.0",
    "2020": "v10.0",
    "2021": "v10.0",
    "2022": "v10.0",
    "2023": "v11.0",
    "2024": "v11.0",
    "2025": "v11.0",
}

AECC_VERSIONS: dict[str, str | None] = {
    "2013": None,
    "2014": None,
    "2015": None,
    "2016": None,
    "2017": None,
    "2018": None,
    "2019": None,
    "2020": "v1.0_shadow",
    "2021": "v1.0",
    "2022": "v1.1",
    "2023": "v1.1",
    "2024": "v1.1",
    "2025": "v1.1",
}

UDG_VERSIONS: dict[str, str] = {
    "2013": "URG_v1.4",
    "2014": "URG_v1.4",
    "2015": "URG_v1.4",
    "2016": "URG_v1.4",
    "2017": "URG_v1.4",
    "2018": "URG_v1.4",
    "2019": "URG_v1.4",
    "2020": "URG_v1.4",
    "2021": "UDG_v1.3",
    "2022": "UDG_v1.3",
    "2023": "UDG_v1.3",
    "2024": "UDG_v1.3",
    "2025": "UDG_v1.3",
}

TIER_2_VERSIONS: dict[str, str | None] = {
    "2013": None,
    "2014": None,
    "2015": None,
    "2016": None,
    "2017": None,
    "2018": None,
    "2019": None,
    "2020": None,
    "2021": None,
    "2022": "v7",
    "2023": "v7",
    "2024": "v7",
    "2025": "v7",
}

AMHCC_VERSIONS: dict[str, str | None] = {
    "2013": None,
    "2014": None,
    "2015": None,
    "2016": None,
    "2017": None,
    "2018": None,
    "2019": None,
    "2020": None,
    "2021": "v1",
    "2022": "v1",
    "2023": "v1",
    "2024": "v1",
    "2025": "v1",
}

AN_SNAP_VERSIONS: dict[str, str | None] = {
    "2013": "v3",
    "2014": "v3",
    "2015": "v3",
    "2016": "v4",
    "2017": "v4",
    "2018": "v4",
    "2019": "v4",
    "2020": "v4",
    "2021": "v4",
    "2022": "v4.01",
    "2023": "v5",
    "2024": "v5",
    "2025": "v5",
}

_VERSION_MAP: dict[str, dict[str, str | None]] = {
    "ar_drg": AR_DRG_VERSIONS,
    "aecc": AECC_VERSIONS,
    "udg": UDG_VERSIONS,
    "tier_2": TIER_2_VERSIONS,
    "amhcc": AMHCC_VERSIONS,
    "an_snap": AN_SNAP_VERSIONS,
}


def get_classification_version(year: str, system: str) -> str | None:
    return _VERSION_MAP.get(system, {}).get(year)


def get_supported_years(system: str) -> list[str]:
    versions = _VERSION_MAP.get(system)
    if versions is None:
        return []
    return sorted(year for year, version in versions.items() if version is not None)


def is_classification_licensed(system: str) -> bool:
    return system in LICENSED_CLASSIFICATIONS


def get_classification_name(system: str) -> str:
    return CLASSIFICATION_SYSTEMS.get(system, system)


def get_transition_years(system: str) -> list[str]:
    versions = _VERSION_MAP.get(system)
    if versions is None:
        return []
    sorted_years = sorted(versions)
    transitions: list[str] = []
    for i in range(1, len(sorted_years)):
        prev = sorted_years[i - 1]
        curr = sorted_years[i]
        if versions[curr] != versions[prev]:
            transitions.append(curr)
    return transitions
