from __future__ import annotations

from copy import deepcopy
from pathlib import Path
from typing import Any

import pytest
import yaml

from nwau_py.reference_manifest import (
    PINNED_EXAMPLE_YEARS,
    SUPPORTED_MANIFEST_SCHEMA_VERSION,
    SUPPORTED_VALIDATION_STATUSES,
    ReferenceManifestError,
    load_reference_manifest,
    parse_reference_manifest,
)

ROOT = Path(__file__).resolve().parents[1]
MANIFEST_2026_CANONICAL = "reference-data/2026/manifest.yaml"
TRACK = ROOT / "conductor" / "tracks" / "reference_data_manifest_schema_20260512"
MANIFEST_2026 = ROOT / "reference-data" / "2026" / "manifest.yaml"
MANIFEST_2025 = ROOT / "reference-data" / "2025" / "manifest.yaml"
DOCS_PAGE = (
    ROOT
    / "docs-site"
    / "src"
    / "content"
    / "docs"
    / "governance"
    / "reference-data-manifests.mdx"
)


def _load_yaml(path: Path) -> dict[str, Any]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    assert isinstance(data, dict)
    return data


def test_reference_manifest_track_files_and_pinned_examples_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "strategy.md",
        TRACK / "ci_notes.md",
        TRACK / "index.md",
        TRACK / "metadata.json",
        MANIFEST_2026,
        MANIFEST_2025,
        DOCS_PAGE,
    ]:
        assert path.exists(), path

    assert PINNED_EXAMPLE_YEARS == ("2025", "2026")
    spec = (TRACK / "spec.md").read_text(encoding="utf-8")
    plan = (TRACK / "plan.md").read_text(encoding="utf-8")
    assert "pinned years `2026` and `2025`" in spec
    assert "pinned example manifests for pricing years `2026` and `2025`" in plan


def test_committed_current_and_historical_examples_load_strictly():
    manifest_2026 = load_reference_manifest(MANIFEST_2026)
    manifest_2025 = load_reference_manifest(MANIFEST_2025)

    assert manifest_2026.schema_version == SUPPORTED_MANIFEST_SCHEMA_VERSION
    assert manifest_2026.pricing_year == "2026"
    assert manifest_2026.financial_year == "2026-27"
    assert manifest_2026.current_pricing_year is True
    assert manifest_2026.validation_status == "source-only"
    assert manifest_2026.unresolved_gaps()

    assert manifest_2025.pricing_year == "2025"
    assert manifest_2025.financial_year == "2025-26"
    assert manifest_2025.current_pricing_year is False
    assert manifest_2025.validation_status == "source-only"
    assert {gap.gap_id for gap in manifest_2025.gaps} >= {
        "2025-nec-constant-not-modeled",
        "2025-tier-2-version-reconciliation",
    }


def test_validation_status_taxonomy_is_explicit_and_ordered():
    assert SUPPORTED_VALIDATION_STATUSES == (
        "source-discovered",
        "source-only",
        "schema-complete",
        "gap-explicit",
        "partially-validated",
        "validated",
        "deprecated",
    )
    assert SUPPORTED_VALIDATION_STATUSES.index("source-discovered") < (
        SUPPORTED_VALIDATION_STATUSES.index("validated")
    )


@pytest.mark.parametrize(
    ("mutator", "expected_message"),
    [
        (
            lambda data: data.__setitem__("schema_version", "2.0"),
            "unsupported schema_version",
        ),
        (
            lambda data: data.__setitem__("validation_status", "ready"),
            "validation_status",
        ),
        (
            lambda data: data.pop("source_artifacts"),
            "source_artifacts",
        ),
        (
            lambda data: data.__setitem__("source_artifacts", []),
            "source_artifacts must not be empty",
        ),
    ],
)
def test_invalid_manifests_fail_with_actionable_diagnostics(
    mutator: Any,
    expected_message: str,
):
    data = _load_yaml(MANIFEST_2026)
    mutator(data)

    with pytest.raises(ReferenceManifestError, match=expected_message):
        parse_reference_manifest(data, canonical_path=MANIFEST_2026_CANONICAL)


def test_gap_records_are_structured_and_required_for_known_missing_items():
    data = _load_yaml(MANIFEST_2025)
    gap = data["gaps"][0]

    assert set(gap) == {
        "gap_id",
        "kind",
        "scope",
        "reason",
        "expected_resolution",
        "introduced_at",
        "status",
    }

    missing_reason = data["constants"]["nec"]["note"]
    assert any(gap_record["scope"] == "constants.nec" for gap_record in data["gaps"])
    assert "do not infer" in missing_reason.lower()

    data_without_gaps = deepcopy(data)
    data_without_gaps["gaps"] = []
    manifest = parse_reference_manifest(
        data_without_gaps,
        canonical_path="reference-data/2025/manifest.yaml",
    )
    assert manifest.gaps == ()
    assert manifest.validation_status == "source-only"


def test_validated_manifests_cannot_have_unresolved_gaps():
    data = _load_yaml(MANIFEST_2026)
    data["validation_status"] = "validated"
    data["validation"]["status"] = "validated"
    data["validation"]["parity_claim"] = True
    data["validation"]["source_only"] = False

    with pytest.raises(ReferenceManifestError, match="unresolved gaps"):
        parse_reference_manifest(data, canonical_path=MANIFEST_2026_CANONICAL)


def test_duplicate_artifacts_and_gap_ids_are_rejected():
    data = _load_yaml(MANIFEST_2026)
    data["source_artifacts"].append(deepcopy(data["source_artifacts"][0]))

    with pytest.raises(ReferenceManifestError, match="duplicate artifact_id"):
        parse_reference_manifest(data, canonical_path=MANIFEST_2026_CANONICAL)

    data = _load_yaml(MANIFEST_2026)
    data["gaps"].append(deepcopy(data["gaps"][0]))

    with pytest.raises(ReferenceManifestError, match="duplicate gap_id"):
        parse_reference_manifest(data, canonical_path=MANIFEST_2026_CANONICAL)


def test_canonical_path_is_machine_checked():
    data = _load_yaml(MANIFEST_2026)

    with pytest.raises(ReferenceManifestError, match="canonical_path"):
        parse_reference_manifest(
            data,
            canonical_path="reference-data/current/manifest.yaml",
        )


def test_docs_explain_required_fields_statuses_gaps_and_support_matrix_links():
    docs = DOCS_PAGE.read_text(encoding="utf-8").lower()
    ci_notes = (TRACK / "ci_notes.md").read_text(encoding="utf-8").lower()

    for phrase in [
        "authoring lifecycle",
        "required fields",
        "source provenance",
        "gap records",
        "schema evolution",
        "calculator coverage matrix",
    ]:
        assert phrase in docs

    assert "reference-data/2026/manifest.yaml" in ci_notes
    assert "reference-data/2025/manifest.yaml" in ci_notes
    assert "missing upstream artifacts as explicit gap records" in ci_notes
