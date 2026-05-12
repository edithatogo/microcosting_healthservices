"""Static AR-DRG mapping registry rows.

Used by :mod:`nwau_py.ar_drg_mapping_registry`.
"""

from __future__ import annotations

from typing import Final, cast

from .coding_set_registry_data import CODING_SET_FAMILY_ROWS

_OFFICIAL_SOURCE_URLS: Final[dict[str, str]] = {
    "2025": "https://www.ihacpa.gov.au/resources/national-efficient-price-determination-2025-26",
    "2026": "https://www.ihacpa.gov.au/resources/national-efficient-price-determination-2026-27",
}


def _family_row(system: str) -> dict[str, object]:
    for row in CODING_SET_FAMILY_ROWS:
        if row["system"] == system:
            return row
    raise KeyError(system)


def _version_for(system: str, year: str) -> str | None:
    row = _family_row(system)
    versions = cast(tuple[tuple[str, str | None], ...], row["versions"])
    for version_year, version in versions:
        if version_year == year:
            return version
    raise KeyError((system, year))


def _required_version_for(system: str, year: str) -> str:
    version = _version_for(system, year)
    if version is None:
        raise KeyError((system, year))
    return version


def _public_metadata_assets(year: str) -> tuple[dict[str, object], ...]:
    source_url = _OFFICIAL_SOURCE_URLS[year]
    ar_drg_slug = _required_version_for("ar_drg", year).lstrip("v").replace(".", "_")
    return (
        {
            "kind": "public-metadata",
            "source_refs": (
                source_url,
                f"reference-data/{year}/manifest.yaml",
                "nwau_py/coding_set_registry_data.py",
                "nwau_py/docs/calculators.md",
            ),
            "local_path_hint": None,
            "restricted": False,
            "notes": (
                "Public metadata only; this registry does not redistribute "
                "licensed tables.",
                "The pricing-year and version bindings are sourced from the "
                "committed manifest and registry metadata.",
            ),
        },
        {
            "kind": "user-supplied-licensed-file",
            "source_refs": (
                source_url,
                f"reference-data/{year}/manifest.yaml",
            ),
            "local_path_hint": (
                f"archive/ihacpa/raw/{year}/licensed/ar_drg/v{ar_drg_slug}/"
            ),
            "restricted": True,
            "notes": (
                "Licensed AR-DRG mapping tables are intentionally not committed.",
                "Users must supply the restricted tables locally if they want "
                "table-level lookup behavior.",
            ),
        },
        {
            "kind": "derived-validation-fixture",
            "source_refs": (
                "conductor/tracks/ar_drg_icd_mapping_registry_20260512/spec.md",
                source_url,
            ),
            "local_path_hint": (
                f"tests/fixtures/derived/ar_drg_mapping/{year}/manifest.json"
            ),
            "restricted": False,
            "notes": (
                "Derived validation fixtures may be created locally from "
                "public metadata plus user-supplied licensed tables.",
                "No derived fixture payloads are committed in this registry layer.",
            ),
        },
    )


AR_DRG_MAPPING_REGISTRY_ROWS: Final[tuple[dict[str, object], ...]] = (
    {
        "pricing_year": "2025",
        "financial_year": "2025-26",
        "effective_years": ("2025",),
        "ar_drg_version": _version_for("ar_drg", "2025"),
        "icd_10_am_version": _version_for("icd_10_am", "2025"),
        "achi_version": _version_for("achi", "2025"),
        "acs_version": _version_for("acs", "2025"),
        "assets": _public_metadata_assets("2025"),
        "notes": (
            "AR-DRG v11.0 is the admitted-acute version recorded in the 2025 "
            "reference-data manifest.",
            "ICD-10-AM, ACHI, and ACS are recorded as 12th edition in the "
            "current coding-set registry.",
            "This entry is provenance-only and does not encode any grouping "
            "or scoring logic.",
        ),
    },
    {
        "pricing_year": "2026",
        "financial_year": "2026-27",
        "effective_years": ("2026",),
        "ar_drg_version": _version_for("ar_drg", "2026"),
        "icd_10_am_version": _version_for("icd_10_am", "2026"),
        "achi_version": _version_for("achi", "2026"),
        "acs_version": _version_for("acs", "2026"),
        "assets": _public_metadata_assets("2026"),
        "notes": (
            "AR-DRG v12.0 is the admitted-acute version recorded in the 2026 "
            "reference-data manifest.",
            "ICD-10-AM, ACHI, and ACS are recorded as 12th edition in the "
            "current coding-set registry.",
            "This entry is provenance-only and does not encode any grouping "
            "or scoring logic.",
        ),
    },
)
