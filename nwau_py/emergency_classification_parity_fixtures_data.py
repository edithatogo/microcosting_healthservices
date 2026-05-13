"""Static metadata rows for safe emergency classification parity fixtures.

The rows in this module are intentionally metadata-only. They describe
synthetic fixture registration points and local-only official references
without embedding any raw encounter payloads, mapping payloads, or grouped
outputs.
"""

from __future__ import annotations

from typing import Final


def _nwau_outputs(pricing_year: str) -> tuple[str, ...]:
    suffix = pricing_year[-2:]
    return ("Error_Code", f"GWAU{suffix}", f"NWAU{suffix}")


def _row(
    *,
    fixture_id: str,
    fixture_type: str,
    assertion_mode: str,
    classifier_family: str,
    classifier_version: str,
    mapping_table_version: str,
    pricing_year: str,
    stream: str,
    raw_source_fields: tuple[str, ...],
    expected_classification: str,
    source_refs: tuple[str, ...],
    local_path_hint: str,
    notes: tuple[str, ...],
) -> dict[str, object]:
    return {
        "fixture_id": fixture_id,
        "fixture_type": fixture_type,
        "assertion_mode": assertion_mode,
        "classifier_family": classifier_family,
        "classifier_version": classifier_version,
        "mapping_table_version": mapping_table_version,
        "pricing_year": pricing_year,
        "stream": stream,
        "raw_source_fields": raw_source_fields,
        "expected_classification": expected_classification,
        "expected_nwau_outputs": _nwau_outputs(pricing_year),
        "source_refs": source_refs,
        "local_path_hint": local_path_hint,
        "notes": notes,
    }


EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ROWS: Final[tuple[dict[str, object], ...]] = (
    _row(
        fixture_id="emergency_classification_parity_synthetic_2025_udg",
        fixture_type="synthetic",
        assertion_mode="precomputed",
        classifier_family="UDG",
        classifier_version="UDG_v1.3",
        mapping_table_version="UDG_v1.3",
        pricing_year="2025",
        stream="emergency_department",
        raw_source_fields=("COMPENSABLE_STATUS", "DVA_STATUS"),
        expected_classification="UDG",
        source_refs=(
            "conductor/tracks/emergency_classification_parity_fixtures_20260512/spec.md",
            "conductor/tracks/emergency_code_mapping_pipeline_20260512/spec.md",
            "nwau_py/emergency_transition_registry.py",
            "nwau_py/emergency_code_mapping_pipeline.py",
            "nwau_py/emergency_grouper.py",
            "https://www.ihacpa.gov.au/health-care/classification/emergency-care/udg",
            "https://www.ihacpa.gov.au/health-care/classification/emergency-care",
        ),
        local_path_hint=(
            "tests/fixtures/derived/emergency_classification_parity/2025/udg/"
            "manifest.json"
        ),
        notes=(
            "Synthetic metadata only; no raw encounter payloads are embedded.",
            "2025 UDG remains the authoritative side for the transition-year "
            "comparison.",
        ),
    ),
    _row(
        fixture_id="emergency_classification_parity_local_official_2025_udg",
        fixture_type="local_official",
        assertion_mode="derived",
        classifier_family="UDG",
        classifier_version="UDG_v1.3",
        mapping_table_version="UDG_v1.3",
        pricing_year="2025",
        stream="emergency_department",
        raw_source_fields=("COMPENSABLE_STATUS", "DVA_STATUS"),
        expected_classification="UDG",
        source_refs=(
            "conductor/tracks/emergency_classification_parity_fixtures_20260512/spec.md",
            "reference-data/2025/emergency/udg/parity/manifest.yaml",
            "archive/ihacpa/raw/2025/emergency/udg/parity/manifest.json",
            "https://www.ihacpa.gov.au/health-care/classification/emergency-care/udg",
        ),
        local_path_hint="archive/ihacpa/raw/2025/emergency/udg/parity/manifest.json",
        notes=(
            "Local-only reference placeholder for licensed parity fixture packs.",
            "No proprietary mapping payloads or grouped outputs are committed.",
        ),
    ),
    _row(
        fixture_id="emergency_classification_parity_synthetic_2026_aecc",
        fixture_type="synthetic",
        assertion_mode="precomputed",
        classifier_family="AECC",
        classifier_version="v1.1",
        mapping_table_version="v1.1",
        pricing_year="2026",
        stream="emergency_department",
        raw_source_fields=("COMPENSABLE_STATUS", "DVA_STATUS"),
        expected_classification="AECC",
        source_refs=(
            "conductor/tracks/emergency_classification_parity_fixtures_20260512/spec.md",
            "conductor/tracks/emergency_code_mapping_pipeline_20260512/spec.md",
            "nwau_py/emergency_transition_registry.py",
            "nwau_py/emergency_code_mapping_pipeline.py",
            "nwau_py/emergency_grouper.py",
            "https://www.ihacpa.gov.au/health-care/classification/emergency-care/aecc",
            "https://www.ihacpa.gov.au/health-care/classification/emergency-care",
        ),
        local_path_hint=(
            "tests/fixtures/derived/emergency_classification_parity/2026/aecc/"
            "manifest.json"
        ),
        notes=(
            "Synthetic metadata only; no proprietary AECC tables are embedded.",
            "2026 AECC is the active classification side for the pricing year.",
        ),
    ),
    _row(
        fixture_id="emergency_classification_parity_local_official_2026_aecc",
        fixture_type="local_official",
        assertion_mode="derived",
        classifier_family="AECC",
        classifier_version="v1.1",
        mapping_table_version="v1.1",
        pricing_year="2026",
        stream="emergency_department",
        raw_source_fields=("COMPENSABLE_STATUS", "DVA_STATUS"),
        expected_classification="AECC",
        source_refs=(
            "conductor/tracks/emergency_classification_parity_fixtures_20260512/spec.md",
            "reference-data/2026/emergency/aecc/parity/manifest.yaml",
            "archive/ihacpa/raw/2026/emergency/aecc/parity/manifest.json",
            "https://www.ihacpa.gov.au/health-care/classification/emergency-care/aecc",
        ),
        local_path_hint="archive/ihacpa/raw/2026/emergency/aecc/parity/manifest.json",
        notes=(
            "Local-only reference placeholder for licensed parity fixture packs.",
            "The repository records the local boundary but never embeds outputs.",
        ),
    ),
)
