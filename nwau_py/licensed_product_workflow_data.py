"""Static metadata rows for the licensed-product workflow.

The rows in this module are intentionally metadata-only. They describe safe
local path conventions and manifest boundaries for ICD-10-AM, ACHI, ACS, and
AR-DRG related licensed products without embedding any restricted tables,
manuals, code rows, or grouper payloads.
"""

from __future__ import annotations

from typing import Final

_SOURCE_PAGE_URL = (
    "https://www.ihacpa.gov.au/health-care/classification/admitted-acute-care"
)


def _asset(
    *,
    asset_id: str,
    kind: str,
    source_refs: tuple[str, ...],
    local_path_hint: str | None,
    restricted: bool,
    asset_role: str,
    product_family: str,
    pricing_year: str,
    expected_version: str,
    notes: tuple[str, ...],
) -> dict[str, object]:
    return {
        "asset_id": asset_id,
        "kind": kind,
        "source_refs": source_refs,
        "local_path_hint": local_path_hint,
        "restricted": restricted,
        "metadata": {
            "asset_role": asset_role,
            "product_family": product_family,
            "pricing_year": pricing_year,
            "expected_version": expected_version,
        },
        "notes": notes,
    }


def _year_rows(
    year: str,
    financial_year: str,
    ar_drg_version: str,
) -> tuple[dict[str, object], ...]:
    source_refs = (
        _SOURCE_PAGE_URL,
        f"reference-data/{year}/manifest.yaml",
        "conductor/tracks/icd_achi_acs_license_workflow_20260512/spec.md",
    )
    return (
        {
            "pricing_year": year,
            "financial_year": financial_year,
            "system": "ar_drg",
            "display_name": "AR-DRG",
            "expected_version": ar_drg_version,
            "source_page_url": _SOURCE_PAGE_URL,
            "assets": (
                _asset(
                    asset_id="public-metadata",
                    kind="public-metadata",
                    source_refs=source_refs,
                    local_path_hint=None,
                    restricted=False,
                    asset_role="manifest-boundary",
                    product_family="AR-DRG",
                    pricing_year=year,
                    expected_version=ar_drg_version,
                    notes=(
                        "Public metadata only; no grouping tables or code "
                        "rows are committed.",
                        "The manifest boundary documents local-only licensed use.",
                    ),
                ),
                _asset(
                    asset_id="licensed-table-manifest",
                    kind="user-supplied-licensed-file",
                    source_refs=(
                        _SOURCE_PAGE_URL,
                        f"reference-data/{year}/manifest.yaml",
                    ),
                    local_path_hint=f"archive/ihacpa/raw/{year}/licensed/ar_drg/tables/",
                    restricted=True,
                    asset_role="licensed-table-manifest",
                    product_family="AR-DRG",
                    pricing_year=year,
                    expected_version=ar_drg_version,
                    notes=(
                        "Licensed AR-DRG tables stay outside version control.",
                        "Users supply the local files under ignored raw "
                        "archive storage.",
                    ),
                ),
                _asset(
                    asset_id="licensed-grouper-manifest",
                    kind="user-supplied-licensed-file",
                    source_refs=(
                        _SOURCE_PAGE_URL,
                        "conductor/tracks/ar_drg_grouper_integration_20260512/spec.md",
                    ),
                    local_path_hint=f"archive/ihacpa/raw/{year}/licensed/ar_drg/grouper/",
                    restricted=True,
                    asset_role="licensed-grouper-manifest",
                    product_family="AR-DRG",
                    pricing_year=year,
                    expected_version=ar_drg_version,
                    notes=(
                        "Licensed grouper software remains user-supplied and "
                        "local-only.",
                        "The repository records only the manifest boundary, "
                        "not the binary.",
                    ),
                ),
            ),
            "notes": (
                "AR-DRG is tracked here because admitted-acute workflows depend on it.",
                "The workflow stays metadata-only and does not redistribute "
                "grouping logic.",
            ),
        },
        {
            "pricing_year": year,
            "financial_year": financial_year,
            "system": "icd_10_am",
            "display_name": "ICD-10-AM",
            "expected_version": "12th edition",
            "source_page_url": _SOURCE_PAGE_URL,
            "assets": (
                _asset(
                    asset_id="public-metadata",
                    kind="public-metadata",
                    source_refs=source_refs,
                    local_path_hint=None,
                    restricted=False,
                    asset_role="manifest-boundary",
                    product_family="ICD-10-AM",
                    pricing_year=year,
                    expected_version="12th edition",
                    notes=(
                        "Public metadata only; no ICD-10-AM code rows are committed.",
                        "The repo only stores the local-use manifest boundary.",
                    ),
                ),
                _asset(
                    asset_id="licensed-table-manifest",
                    kind="user-supplied-licensed-file",
                    source_refs=(
                        _SOURCE_PAGE_URL,
                        f"reference-data/{year}/manifest.yaml",
                    ),
                    local_path_hint=f"archive/ihacpa/raw/{year}/licensed/icd_10_am/",
                    restricted=True,
                    asset_role="licensed-table-manifest",
                    product_family="ICD-10-AM",
                    pricing_year=year,
                    expected_version="12th edition",
                    notes=(
                        "ICD-10-AM tables are locally supplied by licensed users only.",
                        "The manifest path points at ignored raw archive storage.",
                    ),
                ),
            ),
            "notes": (
                "ICD-10-AM is licensed and should stay local-only in this workflow.",
                "The metadata records safe references without table content.",
            ),
        },
        {
            "pricing_year": year,
            "financial_year": financial_year,
            "system": "achi",
            "display_name": "ACHI",
            "expected_version": "12th edition",
            "source_page_url": _SOURCE_PAGE_URL,
            "assets": (
                _asset(
                    asset_id="public-metadata",
                    kind="public-metadata",
                    source_refs=source_refs,
                    local_path_hint=None,
                    restricted=False,
                    asset_role="manifest-boundary",
                    product_family="ACHI",
                    pricing_year=year,
                    expected_version="12th edition",
                    notes=(
                        "Public metadata only; no ACHI code rows are committed.",
                        "Local use is recorded as a manifest boundary only.",
                    ),
                ),
                _asset(
                    asset_id="licensed-table-manifest",
                    kind="user-supplied-licensed-file",
                    source_refs=(
                        _SOURCE_PAGE_URL,
                        f"reference-data/{year}/manifest.yaml",
                    ),
                    local_path_hint=f"archive/ihacpa/raw/{year}/licensed/achi/",
                    restricted=True,
                    asset_role="licensed-table-manifest",
                    product_family="ACHI",
                    pricing_year=year,
                    expected_version="12th edition",
                    notes=(
                        "ACHI tables are supplied locally by licensed users only.",
                        "The repo keeps the asset reference out of version control.",
                    ),
                ),
            ),
            "notes": (
                "ACHI is licensed and remains a local-only asset in this workflow.",
                "Only allowlisted metadata is retained in the repository.",
            ),
        },
        {
            "pricing_year": year,
            "financial_year": financial_year,
            "system": "acs",
            "display_name": "ACS",
            "expected_version": "12th edition",
            "source_page_url": _SOURCE_PAGE_URL,
            "assets": (
                _asset(
                    asset_id="public-metadata",
                    kind="public-metadata",
                    source_refs=source_refs,
                    local_path_hint=None,
                    restricted=False,
                    asset_role="manifest-boundary",
                    product_family="ACS",
                    pricing_year=year,
                    expected_version="12th edition",
                    notes=(
                        "Public metadata only; no ACS code rows are committed.",
                        "The workflow stores only the local-use boundary reference.",
                    ),
                ),
                _asset(
                    asset_id="licensed-table-manifest",
                    kind="user-supplied-licensed-file",
                    source_refs=(
                        _SOURCE_PAGE_URL,
                        f"reference-data/{year}/manifest.yaml",
                    ),
                    local_path_hint=f"archive/ihacpa/raw/{year}/licensed/acs/",
                    restricted=True,
                    asset_role="licensed-table-manifest",
                    product_family="ACS",
                    pricing_year=year,
                    expected_version="12th edition",
                    notes=(
                        "ACS tables are supplied locally by licensed users only.",
                        "The manifest is commit-safe because the path is "
                        "ignored by Git.",
                    ),
                ),
            ),
            "notes": (
                "ACS is licensed and stays local-only in this workflow.",
                "The record keeps only machine-readable manifest metadata.",
            ),
        },
    )


LICENSED_PRODUCT_WORKFLOW_ROWS: Final[tuple[dict[str, object], ...]] = _year_rows(
    "2025", "2025-26", "v11.0"
) + _year_rows("2026", "2026-27", "v12.0")
