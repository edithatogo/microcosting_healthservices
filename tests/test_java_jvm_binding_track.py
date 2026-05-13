from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "java_jvm_binding_20260512"
TRACKS_REGISTRY = ROOT / "conductor" / "tracks.md"
PACKAGING_MATRIX = ROOT / "docs" / "roadmaps" / "polyglot-packaging-release-matrix.md"
RUST_CORE_ROADMAP = ROOT / "docs" / "roadmaps" / "polyglot-rust-core.md"
FIXTURE_ROOT = Path(__file__).resolve().parent / "fixtures" / "java_jvm_binding"
CONTRACT_BUNDLE = FIXTURE_ROOT / "contract_bundle.json"
PASS_EXAMPLE = FIXTURE_ROOT / "validation.pass.json"
FAIL_EXAMPLE = FIXTURE_ROOT / "validation.fail.json"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _load_json(path: Path) -> dict[str, object]:
    payload = json.loads(_read_text(path))
    assert isinstance(payload, dict)
    return payload


def _as_mapping(value: object) -> dict[str, Any]:
    assert isinstance(value, dict)
    return cast(dict[str, Any], value)


def _squash(text: str) -> str:
    return " ".join(text.split())


def test_java_jvm_binding_track_metadata_docs_and_contract_bundle_are_conservative():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "index.md",
        TRACK / "metadata.json",
        TRACKS_REGISTRY,
        PACKAGING_MATRIX,
        RUST_CORE_ROADMAP,
        CONTRACT_BUNDLE,
        PASS_EXAMPLE,
        FAIL_EXAMPLE,
    ]:
        assert path.exists(), path

    metadata = _load_json(TRACK / "metadata.json")
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    index = _read_text(TRACK / "index.md")
    tracks = _read_text(TRACKS_REGISTRY)
    packaging = _read_text(PACKAGING_MATRIX)
    roadmap = _read_text(RUST_CORE_ROADMAP)
    bundle = _load_json(CONTRACT_BUNDLE)
    pass_example = _load_json(PASS_EXAMPLE)
    fail_example = _load_json(FAIL_EXAMPLE)

    assert metadata["track_id"] == "java_jvm_binding_20260512"
    assert metadata["type"] == "feature"
    assert metadata["status"] == "in-progress"
    assert metadata["track_class"] == "binding"
    assert metadata["current_state"] == "kotlin-jvm-binding-roadmap-complete"
    assert metadata["primary_contract"] == (
        "contracts/java-jvm-binding/java-jvm-binding.contract.json"
    )
    assert metadata["publication_status"] == "not-applicable"
    assert metadata["completion_evidence"] == ["docs", "workflows", "tests"]
    assert "Kotlin/JVM binding roadmap" in str(metadata["description"])

    for phrase in [
        "Kotlin-first JVM integration roadmap",
        "shared Rust core",
        "service, JNI/JNA, C ABI, or Arrow/Parquet file interop",
        "must not duplicate formula logic",
        "Kotlin data classes with Java-compatible JVM bytecode boundaries",
        "shared golden fixtures and schema conformance tests",
        "Gradle/Maven publication only after stability gates are met",
        "JVM integration strategy is selected and documented.",
        "JVM examples validate against shared fixtures.",
        "Formula logic remains single-sourced.",
    ]:
        assert phrase in spec

    for phrase in [
        "Compare service, JNI/JNA, and Arrow/Parquet file interop for JVM users.",
        "Select an initial strategy that minimizes binary packaging risk.",
        "Define Kotlin API and Java interop considerations.",
        "Add Kotlin/JVM prototype or service client and shared-fixture tests.",
        "Validate outputs against golden fixtures.",
        "Document enterprise deployment patterns.",
    ]:
        assert phrase in plan

    assert "Track java_jvm_binding_20260512 Context" in index
    assert "Kotlin/JVM Binding" in tracks
    assert (
        "support enterprise jvm consumers through service, jni/jna, c abi, or "
        "arrow/parquet interop with shared fixture validation."
        in tracks.lower()
    )

    assert "jvm" in packaging.lower()
    assert (
        "jar/maven artifact, with jni/jna or service bridge as needed"
        in packaging.lower()
    )
    assert "release when the jvm adapter is thin" in packaging.lower()
    assert "ci covers the supported java runtime range" in packaging.lower()
    assert "packaging path is reproducible" in packaging.lower()
    assert "java/jvm" in roadmap.lower()
    assert "single source of formula logic" in roadmap.lower()

    bundle_map = _as_mapping(bundle)
    diagnostics = _as_mapping(bundle_map["diagnostics"])
    provenance = _as_mapping(bundle_map["provenance"])
    package = _as_mapping(bundle_map["package"])
    maven = _as_mapping(package["maven"])
    gradle = _as_mapping(package["gradle"])

    assert bundle_map["schema_version"] == "1.0"
    assert bundle_map["binding_id"] == "java_jvm_binding_20260512"
    assert bundle_map["surface"] == "jvm"
    assert bundle_map["initial_strategy"] == "arrow/parquet file interop"
    assert bundle_map["fallback_strategy"] == "service boundary"
    assert bundle_map["formula_logic_location"] == "rust core"
    assert diagnostics["format"] == "json"
    assert diagnostics["includes"] == [
        "contract_id",
        "fixture_id",
        "validation_status",
        "strategy",
        "fallback",
    ]
    assert provenance["checksum_algorithm"] == "sha256"
    assert provenance["preserve_fields"] == [
        "source_basis",
        "fixture_id",
        "notes",
    ]
    assert maven["status"] == "private"
    assert maven["release_gate"] == "adapter thin and parity stable"
    assert gradle["status"] == "private"
    assert gradle["release_gate"] == "adapter thin and parity stable"

    assert pass_example["result"] == "pass"
    assert pass_example["strategy"] == "arrow/parquet file interop"
    assert pass_example["fallback"] == "service boundary"
    assert _as_mapping(pass_example["diagnostics"])["format"] == "json"
    assert _as_mapping(pass_example["provenance"])["checksum_algorithm"] == "sha256"

    assert fail_example["result"] == "fail"
    assert "formula logic" in str(fail_example["reason"]).lower()
    assert "maven" in str(fail_example["reason"]).lower()
    assert "gradle" in str(fail_example["reason"]).lower()
    assert "overclaim" in str(fail_example["reason"]).lower()


def test_java_jvm_binding_preserves_provenance_and_refuses_publication_overclaiming():
    bundle = _load_json(CONTRACT_BUNDLE)
    pass_example = _load_json(PASS_EXAMPLE)
    fail_example = _load_json(FAIL_EXAMPLE)

    bundle_diagnostics = _as_mapping(bundle["diagnostics"])
    bundle_provenance = _as_mapping(bundle["provenance"])
    pass_diagnostics = _as_mapping(pass_example["diagnostics"])
    pass_provenance = _as_mapping(pass_example["provenance"])

    assert bundle_diagnostics["format"] == pass_diagnostics["format"] == "json"
    assert bundle_provenance["checksum_algorithm"] == pass_provenance[
        "checksum_algorithm"
    ] == "sha256"
    assert bundle_provenance["preserve_fields"] == pass_provenance[
        "preserve_fields"
    ]
    assert bundle["formula_logic_location"] == "rust core"
    assert pass_example["formula_logic_location"] == "rust core"
    assert "java" not in str(bundle["formula_logic_location"]).lower()
    assert "java" not in str(pass_example["formula_logic_location"]).lower()
    assert "maven" in str(fail_example["reason"]).lower()
    assert "gradle" in str(fail_example["reason"]).lower()
    assert "publication" in str(fail_example["reason"]).lower()


def test_java_jvm_binding_if_a_scaffold_exists_it_stays_thin_and_non_formula():
    candidate_roots = [
        ROOT / "java-jvm-binding",
        ROOT / "jvm-binding",
        ROOT / "bindings" / "java",
        ROOT / "bindings" / "jvm",
        ROOT / "java",
        ROOT / "jvm",
        ROOT / "src" / "java",
        ROOT / "src" / "jvm",
    ]
    scaffold_root = next((path for path in candidate_roots if path.exists()), None)

    if scaffold_root is None:
        return

    scaffold_text = _squash(
        " ".join(
            _read_text(path)
            for path in scaffold_root.rglob("*")
            if path.is_file()
            and "bin" not in path.parts
            and "build" not in path.parts
            and "target" not in path.parts
            and path.suffix in {
                ".md",
                ".txt",
                ".json",
                ".java",
                ".kt",
                ".kts",
                ".xml",
                ".gradle",
            }
        )
    ).lower()

    for forbidden in [
        "private_service_adjustment",
        "long_stay_per_diem",
        "same_day_base_weight",
        "icu_rate",
        "nwau25 =",
        "nwau25 <-",
    ]:
        assert forbidden not in scaffold_text

    for forbidden in [
        "maven central publication",
        "gradle publication",
        "publication ready",
        "release publishing",
        "embedded formula implementation",
    ]:
        assert forbidden not in scaffold_text
