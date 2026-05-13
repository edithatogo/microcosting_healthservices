"""Static metadata rows for safe AR-DRG version parity fixtures.

The rows in this module are intentionally metadata-only. They describe
synthetic fixture registration points and local-only licensed references
without embedding any grouped episode outputs, code rows, or licensed tables.
"""

from __future__ import annotations

from typing import Final


def _window(
    *,
    pricing_year: str,
    ar_drg_version: str,
    icd_10_am_version: str,
    achi_version: str,
    acs_version: str,
) -> dict[str, str]:
    return {
        "pricing_year": pricing_year,
        "ar_drg_version": ar_drg_version,
        "icd_10_am_version": icd_10_am_version,
        "achi_version": achi_version,
        "acs_version": acs_version,
    }


AR_DRG_VERSION_PARITY_FIXTURE_ROWS: Final[tuple[dict[str, object], ...]] = (
    {
        "fixture_id": "ar_drg_version_parity_synthetic_2025",
        "fixture_kind": "synthetic",
        "workflow_mode": "precomputed",
        "version_window": _window(
            pricing_year="2025",
            ar_drg_version="v11.0",
            icd_10_am_version="12th edition",
            achi_version="12th edition",
            acs_version="12th edition",
        ),
        "grouper_version": None,
        "source_refs": (
            "conductor/tracks/ar_drg_version_parity_fixtures_20260512/spec.md",
            "reference-data/2025/manifest.yaml",
            "https://www.ihacpa.gov.au/admitted-acute-care/ar-drg-classification-system",
        ),
        "local_path_hint": (
            "tests/fixtures/derived/ar_drg_version_parity/2025/manifest.json"
        ),
        "notes": (
            "Synthetic fixture metadata only; no grouped outputs are embedded.",
            "Use this registry entry to anchor safe parity test packs for 2025.",
        ),
    },
    {
        "fixture_id": "ar_drg_version_parity_synthetic_2026",
        "fixture_kind": "synthetic",
        "workflow_mode": "precomputed",
        "version_window": _window(
            pricing_year="2026",
            ar_drg_version="v12.0",
            icd_10_am_version="12th edition",
            achi_version="12th edition",
            acs_version="12th edition",
        ),
        "grouper_version": None,
        "source_refs": (
            "conductor/tracks/ar_drg_version_parity_fixtures_20260512/spec.md",
            "reference-data/2026/manifest.yaml",
            "https://www.ihacpa.gov.au/resources/ar-drg-version-120",
        ),
        "local_path_hint": (
            "tests/fixtures/derived/ar_drg_version_parity/2026/manifest.json"
        ),
        "notes": (
            "Synthetic fixture metadata only; no proprietary grouping outputs "
            "are stored.",
            "The entry records the 2026 AR-DRG version scope without table content.",
        ),
    },
    {
        "fixture_id": "ar_drg_version_parity_local_licensed_2025",
        "fixture_kind": "local-licensed-reference",
        "workflow_mode": "external-reference",
        "version_window": _window(
            pricing_year="2025",
            ar_drg_version="v11.0",
            icd_10_am_version="12th edition",
            achi_version="12th edition",
            acs_version="12th edition",
        ),
        "grouper_version": "v11.0-local",
        "source_refs": (
            "conductor/tracks/ar_drg_version_parity_fixtures_20260512/spec.md",
            "https://www.ihacpa.gov.au/admitted-acute-care/ar-drg-classification-system",
            "reference-data/2025/manifest.yaml",
        ),
        "local_path_hint": (
            "archive/ihacpa/raw/2025/licensed/ar_drg/parity/manifest.json"
        ),
        "notes": (
            "Local-only reference placeholder for licensed parity fixture packs.",
            "No grouped episode outputs or licensed tables are committed here.",
        ),
    },
    {
        "fixture_id": "ar_drg_version_parity_local_licensed_2026",
        "fixture_kind": "local-licensed-reference",
        "workflow_mode": "external-reference",
        "version_window": _window(
            pricing_year="2026",
            ar_drg_version="v12.0",
            icd_10_am_version="12th edition",
            achi_version="12th edition",
            acs_version="12th edition",
        ),
        "grouper_version": "v12.0-local",
        "source_refs": (
            "conductor/tracks/ar_drg_version_parity_fixtures_20260512/spec.md",
            "https://www.ihacpa.gov.au/admitted-acute-care/ar-drg-classification-system",
            "https://www.ihacpa.gov.au/resources/ar-drg-version-120",
        ),
        "local_path_hint": (
            "archive/ihacpa/raw/2026/licensed/ar_drg/parity/manifest.json"
        ),
        "notes": (
            "Local-only reference placeholder for licensed parity fixture packs.",
            "The repository records the local boundary but never embeds outputs.",
        ),
    },
)
