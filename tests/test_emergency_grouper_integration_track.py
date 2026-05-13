from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

import nwau_py
from nwau_py import emergency_grouper
from nwau_py.emergency_grouper import (
    EmergencyGrouperError,
    build_emergency_external_reference,
    build_emergency_output_record_from_reference,
    build_emergency_precomputed_output_record,
    ensure_emergency_grouper_compatibility,
    validate_emergency_grouper_compatibility,
)

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "emergency_grouper_integration_20260512"
CONTRACT = ROOT / "contracts" / "emergency-grouper-integration"
SHA = "0" * 64


def _read_json(path: Path) -> dict[str, object]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(payload, dict)
    return payload


def _as_mapping(value: object) -> dict[str, Any]:
    assert isinstance(value, dict)
    return cast(dict[str, Any], value)


def _reference() -> emergency_grouper.EmergencyGrouperReference:
    return build_emergency_external_reference(
        reference_id="local_aecc_service",
        reference_type="local_service",
        status="resolved",
        reference_uri="http://localhost:8765/aecc",
        supported_versions=(
            {
                "system": "aecc",
                "pricing_year": "2026",
                "emergency_classification_version": "v1.1",
                "stream_compatibility": ("emergency_department",),
                "source_refs": (
                    "contracts/emergency-grouper-integration/examples/"
                    "external-local-grouper-service-reference.json",
                ),
            },
        ),
        notes=("local-only service reference",),
    )


def test_track_and_contract_target_the_emergency_grouper_surface() -> None:
    metadata = _read_json(TRACK / "metadata.json")
    contract = _read_json(CONTRACT / "emergency-grouper-integration.contract.json")
    spec = (TRACK / "spec.md").read_text(encoding="utf-8")

    assert metadata["track_id"] == "emergency_grouper_integration_20260512"
    assert metadata["current_state"] in {
        "roadmap-only",
        "implemented-metadata-integration",
    }
    primary_contract = metadata["primary_contract"]
    assert isinstance(primary_contract, str)
    assert "nwau_py.emergency_grouper" in primary_contract
    assert _as_mapping(contract["tool"])["name"] == "nwau_py.emergency_grouper"
    assert _as_mapping(contract["privacy"])["contains_phi"] is False
    assert "precomputed UDG/AECC outputs" in spec
    assert "external command integration" in spec
    assert "service integration" in spec
    assert "file-exchange integration" in spec
    assert "Never silently convert between UDG and AECC" in spec


def test_precomputed_outputs_validate_strictly_and_record_provenance() -> None:
    record = build_emergency_precomputed_output_record(
        "AECC-01",
        system="aecc",
        year="2026",
        stream="emergency_department",
        emergency_classification_version="v1.1",
        input_sha256=SHA,
        episode_id="synthetic-episode-1",
        mapping_bundle_id="emergency_code_mapping_aecc_2026",
        mapping_bundle_version="v1.1",
    )

    assert record.classification_code == "AECC-01"
    assert record.episode_id == "synthetic-episode-1"
    assert record.provenance.system == "aecc"
    assert record.provenance.source_mode == "precomputed"
    assert record.provenance.mapping_stage == "pre-mapping"
    assert record.provenance.input_sha256 == SHA

    compatibility = validate_emergency_grouper_compatibility(
        "aecc",
        "2026",
        "v1.1",
        stream="emergency_department",
    )
    assert compatibility.compatible is True
    assert compatibility.compatibility_state == "valid"


def test_external_reference_outputs_validate_local_only_reference_scope() -> None:
    reference = _reference()

    compatibility = ensure_emergency_grouper_compatibility(
        "aecc",
        "2026",
        None,
        stream="emergency_department",
        source_mode="external-reference",
        reference=reference,
    )
    assert compatibility.compatible is True
    assert compatibility.reference_id == "local_aecc_service"
    assert compatibility.declared_version == "v1.1"

    record = build_emergency_output_record_from_reference(
        "AECC-99",
        system="aecc",
        year="2026",
        stream="emergency_department",
        reference=reference,
        input_sha256=SHA,
        tool_id="local-aecc-service",
        tool_version="1.0",
        mapping_bundle_id="emergency_code_mapping_aecc_2026",
        mapping_bundle_version="v1.1",
    )
    assert record.provenance.source_mode == "external-reference"
    assert record.provenance.external_reference_id == "local_aecc_service"
    assert record.provenance.tool_id == "local-aecc-service"
    assert record.provenance.mapping_stage == "post-mapping"


def test_invalid_year_reference_and_remote_service_fail_closed() -> None:
    reference = _reference()

    result = validate_emergency_grouper_compatibility(
        "aecc",
        "2025",
        None,
        stream="emergency_department",
        source_mode="external-reference",
        reference=reference,
    )
    assert result.compatible is False
    assert "does not support" in (result.reason or "")

    with pytest.raises(EmergencyGrouperError, match="local host"):
        build_emergency_external_reference(
            reference_id="remote_service",
            reference_type="local_service",
            status="resolved",
            reference_uri="https://example.com/aecc",
            supported_versions=reference.supported_versions,
        )

    with pytest.raises(EmergencyGrouperError, match="requires a local reference"):
        ensure_emergency_grouper_compatibility(
            "aecc",
            "2026",
            None,
            stream="emergency_department",
            source_mode="external-reference",
            reference=None,
        )


def test_trusted_precomputed_mode_is_explicit_and_noop_only() -> None:
    result = validate_emergency_grouper_compatibility(
        "aecc",
        "2026",
        None,
        stream="emergency_department",
        trust_precomputed=True,
    )
    assert result.compatible is True
    assert result.validation_mode == "trusted-precomputed"
    assert result.compatibility_state == "trusted-precomputed"
    assert result.reason is None


def test_public_exports_include_emergency_grouper_surface() -> None:
    expected = {
        "EMERGENCY_GROUPER_COMPATIBILITY_STATES",
        "EMERGENCY_GROUPER_MAPPING_STAGES",
        "EMERGENCY_GROUPER_REFERENCE_TYPES",
        "EMERGENCY_GROUPER_SOURCE_MODES",
        "EMERGENCY_GROUPER_VERSION_MATRIX",
        "EmergencyGrouperCompatibilityResult",
        "EmergencyGrouperError",
        "EmergencyGrouperOutputRecord",
        "EmergencyGrouperProvenance",
        "EmergencyGrouperReference",
        "EmergencyGrouperVersionWindow",
        "build_emergency_external_reference",
        "build_emergency_output_record_from_reference",
        "build_emergency_precomputed_output_record",
        "build_emergency_provenance",
        "emergency_grouper",
        "ensure_emergency_grouper_compatibility",
        "validate_emergency_grouper_compatibility",
    }
    assert expected.issubset(set(nwau_py.__all__))
    module_exports = set(emergency_grouper.__all__) | {"emergency_grouper"}
    assert expected.issubset(module_exports)

    for name in expected:
        assert getattr(nwau_py, name) is not None
