from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

import nwau_py
from nwau_py import abstraction_doctrine as doctrine
from nwau_py.abstraction_doctrine import (
    AbstractionBoundaryError,
    AbstractionDependency,
    describe_abstraction_doctrine,
    get_abstraction_boundary,
    get_allowed_target_surfaces,
    validate_abstraction_boundary,
    validate_abstraction_dependencies,
    validate_abstraction_dependency,
)

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "abstraction_doctrine_enforcement_20260512"
CONTRACT = ROOT / "contracts" / "abstraction-doctrine-enforcement"


def _read_json(path: Path) -> dict[str, object]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(payload, dict)
    return payload


def _as_mapping(value: object) -> dict[str, Any]:
    assert isinstance(value, dict)
    return cast(dict[str, Any], value)


def test_track_contract_and_doctrine_registry_are_explicit() -> None:
    metadata = _read_json(TRACK / "metadata.json")
    contract = _read_json(CONTRACT / "abstraction-doctrine-enforcement.contract.json")
    spec = (TRACK / "spec.md").read_text(encoding="utf-8")

    assert metadata["track_id"] == "abstraction_doctrine_enforcement_20260512"
    assert metadata["current_state"] in {
        "scaffold-only",
        "implemented-metadata-guardrails",
    }
    primary_contract = metadata["primary_contract"]
    assert isinstance(primary_contract, str)
    assert "nwau_py.abstraction_doctrine" in primary_contract
    assert _as_mapping(contract["tool"])["name"] == "nwau_py.abstraction_doctrine"
    assert _as_mapping(contract["privacy"])["contains_phi"] is False
    assert "formula" in spec
    assert "crosswalk" in spec.lower()

    description = describe_abstraction_doctrine()
    assert description["surfaces"] == list(doctrine.ABSTRACTION_SURFACES)
    assert "direct-dependency" in description["forbidden_shortcuts"]
    assert "crosswalk-assumption" in description["forbidden_shortcuts"]


def test_allowed_boundary_registry_is_metadata_only_and_fail_closed() -> None:
    boundary = validate_abstraction_boundary("binding", "formula")
    assert boundary.source_surface == "binding"
    assert boundary.target_surface == "formula"
    assert boundary.dependency_kind == "metadata-only"

    assert "formula" in get_allowed_target_surfaces("binding")
    assert "app" not in get_allowed_target_surfaces("formula")

    with pytest.raises(AbstractionBoundaryError, match="no abstraction boundary"):
        get_abstraction_boundary("formula", "app")

    with pytest.raises(AbstractionBoundaryError, match="direct dependencies"):
        validate_abstraction_boundary(
            "binding",
            "formula",
            dependency_kind="direct",
        )

    with pytest.raises(AbstractionBoundaryError, match="crosswalk assumptions"):
        validate_abstraction_boundary(
            "classifier",
            "fixture",
            dependency_kind="crosswalk",
        )


def test_dependency_objects_and_mappings_validate_against_doctrine() -> None:
    dependency = AbstractionDependency(
        source_surface="docs",
        target_surface="release",
        dependency_kind="metadata-only",
        declared_in="docs-site/src/content/docs/governance/index.mdx",
        notes=("docs can reference release metadata",),
    )
    assert validate_abstraction_dependency(dependency).target_surface == "release"

    boundaries = validate_abstraction_dependencies(
        (
            {
                "source_surface": "app",
                "target_surface": "binding",
                "dependency_kind": "metadata-only",
                "declared_in": "power-platform/solution/app-surface.md",
            },
            {
                "source_surface": "fixture",
                "target_surface": "classifier",
                "dependency_kind": "metadata",
                "notes": ["fixture cites classifier metadata only"],
            },
        )
    )
    assert [boundary.target_surface for boundary in boundaries] == [
        "binding",
        "classifier",
    ]

    with pytest.raises(AbstractionBoundaryError, match="source_surface"):
        validate_abstraction_dependency({"target_surface": "formula"})

    with pytest.raises(AbstractionBoundaryError, match="trimmed lowercase"):
        validate_abstraction_dependency(
            {
                "source_surface": "Binding",
                "target_surface": "formula",
            }
        )


def test_contract_examples_cover_pass_fail_crosswalk_docs_app_and_release() -> None:
    expected_examples = {
        "boundary-registry.manifest.json",
        "validation.pass.json",
        "validation.fail.json",
        "no-crosswalk-assumption.diagnostic.json",
        "docs-surface.example.json",
        "app-surface.example.json",
        "release-surface.example.json",
    }
    for name in expected_examples:
        payload = _read_json(CONTRACT / "examples" / name)
        assert payload

    fail_payload = _read_json(CONTRACT / "examples" / "validation.fail.json")
    assert "direct" in json.dumps(fail_payload).lower()

    crosswalk_payload = _read_json(
        CONTRACT / "examples" / "no-crosswalk-assumption.diagnostic.json"
    )
    assert "crosswalk" in json.dumps(crosswalk_payload).lower()


def test_public_exports_include_abstraction_doctrine_surface() -> None:
    expected = {
        "ABSTRACTION_BOUNDARIES",
        "ABSTRACTION_BOUNDARY_INDEX",
        "ABSTRACTION_BOUNDARY_MATRIX",
        "ABSTRACTION_BOUNDARY_REGISTRY",
        "ABSTRACTION_DOCTRINE",
        "ABSTRACTION_DOCTRINE_BOUNDARIES",
        "ABSTRACTION_DOCTRINE_FORBIDDEN_SHORTCUTS",
        "ABSTRACTION_SURFACES",
        "AbstractionBoundary",
        "AbstractionBoundaryError",
        "AbstractionDependency",
        "AbstractionDoctrine",
        "AbstractionSurface",
        "DependencyKind",
        "abstraction_doctrine",
        "describe_abstraction_doctrine",
        "get_abstraction_boundary",
        "get_allowed_target_surfaces",
        "validate_abstraction_boundary",
        "validate_abstraction_dependencies",
        "validate_abstraction_dependency",
    }
    assert expected.issubset(set(nwau_py.__all__))
    module_exports = set(doctrine.__all__) | {"abstraction_doctrine"}
    assert expected.issubset(module_exports)

    for name in expected:
        assert getattr(nwau_py, name) is not None
