"""Metadata-only emergency classification parity fixture helpers.

The helpers in this module define a conservative fixture surface for UDG and
AECC parity checks. They describe fixture metadata, not raw encounter payloads,
and they validate compatibility against the emergency transition registry, the
emergency code mapping pipeline, and the emergency grouper boundaries.
"""

from __future__ import annotations

import re
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Final, Literal, cast

from .emergency_classification_parity_fixtures_data import (
    EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ROWS,
)
from .emergency_code_mapping_pipeline import (
    get_emergency_code_mapping_bundle_record,
    validate_emergency_code_mapping_bundle_compatibility,
)
from .emergency_grouper import (
    EmergencyGrouperReference,
    EmergencyGrouperVersionWindow,
    build_emergency_external_reference,
    validate_emergency_grouper_compatibility,
)
from .emergency_transition_registry import (
    EMERGENCY_STREAMS,
    get_emergency_classification_name,
    normalize_emergency_classification_system,
    validate_emergency_classification_compatibility,
)

__all__ = [
    "EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ASSERTION_MODES",
    "EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ROWS",
    "EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_TYPES",
    "EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_VERSION_MATRIX",
    "EmergencyClassificationParityFixtureCompatibilityResult",
    "EmergencyClassificationParityFixtureError",
    "EmergencyClassificationParityFixtureRecord",
    "build_emergency_classification_parity_fixture_reference",
    "ensure_emergency_classification_parity_fixture_scope",
    "get_emergency_classification_parity_fixture_record",
    "list_emergency_classification_parity_fixture_records",
    "register_emergency_local_official_classification_parity_fixture_reference",
    "register_emergency_synthetic_classification_parity_fixture",
    "validate_emergency_classification_parity_fixture_scope",
]

EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ASSERTION_MODES: Final[tuple[str, ...]] = (
    "precomputed",
    "derived",
)
EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_TYPES: Final[tuple[str, ...]] = (
    "synthetic",
    "local_official",
)
_YEAR_RE = re.compile(r"^(?:201[3-9]|202[0-6])$")
_VERSION_RE = re.compile(r"^[A-Za-z0-9_. -]+$")
_FIXTURE_ID_RE = re.compile(r"^[a-z][a-z0-9_]*$")


class EmergencyClassificationParityFixtureError(ValueError):
    """Raised when a parity fixture reference is incomplete or incompatible."""


def _normalize_non_blank(value: Any, *, field: str) -> str:
    if not isinstance(value, str):
        raise EmergencyClassificationParityFixtureError(f"{field} must be a string")
    if not value:
        raise EmergencyClassificationParityFixtureError(f"{field} must not be blank")
    if value.strip() != value:
        raise EmergencyClassificationParityFixtureError(
            f"{field} must not contain leading or trailing whitespace"
        )
    return value


def _normalize_year(year: str) -> str:
    normalized = _normalize_non_blank(year, field="pricing_year")
    if not _YEAR_RE.fullmatch(normalized):
        raise EmergencyClassificationParityFixtureError(
            "pricing_year must be a supported four-digit label between 2013 and 2026"
        )
    return normalized


def _normalize_version(version: str, *, field: str) -> str:
    normalized = _normalize_non_blank(version, field=field)
    if not _VERSION_RE.fullmatch(normalized):
        raise EmergencyClassificationParityFixtureError(
            f"{field} must be a deterministic version label"
        )
    return normalized


def _normalize_stream(stream: str) -> str:
    normalized = _normalize_non_blank(stream, field="stream")
    if normalized not in EMERGENCY_STREAMS:
        raise EmergencyClassificationParityFixtureError(
            "stream must be one of the emergency transition registry streams"
        )
    return normalized


def _normalize_str_tuple(
    value: Any,
    *,
    field: str,
    allow_empty: bool = False,
) -> tuple[str, ...]:
    if isinstance(value, (str, bytes)) or not isinstance(value, Iterable):
        raise EmergencyClassificationParityFixtureError(
            f"{field} must be a tuple or list of non-empty strings"
        )
    normalized: list[str] = []
    seen: set[str] = set()
    for item in value:
        text = _normalize_non_blank(item, field=field)
        if text in seen:
            raise EmergencyClassificationParityFixtureError(
                f"{field} must not contain duplicates"
            )
        seen.add(text)
        normalized.append(text)
    if not normalized and not allow_empty:
        raise EmergencyClassificationParityFixtureError(f"{field} must not be empty")
    return tuple(normalized)


def _normalize_relative_path(path: str | Path, *, field: str) -> str:
    candidate = path if isinstance(path, Path) else Path(path)
    raw = candidate.as_posix()
    if not raw or raw == ".":
        raise EmergencyClassificationParityFixtureError(f"{field} must not be blank")
    if candidate.is_absolute():
        raise EmergencyClassificationParityFixtureError(
            f"{field} must be a relative path"
        )
    if any(part == ".." for part in candidate.parts):
        raise EmergencyClassificationParityFixtureError(
            f"{field} must not contain parent traversal"
        )
    return raw


def _normalize_fixture_type(value: str) -> str:
    normalized = _normalize_non_blank(value, field="fixture_type")
    if normalized not in EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_TYPES:
        raise EmergencyClassificationParityFixtureError(
            f"unsupported fixture_type {normalized!r}"
        )
    return normalized


def _normalize_assertion_mode(value: str) -> str:
    normalized = _normalize_non_blank(value, field="assertion_mode")
    if normalized not in EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ASSERTION_MODES:
        raise EmergencyClassificationParityFixtureError(
            f"unsupported assertion_mode {normalized!r}"
        )
    return normalized


def _expected_nwau_columns(pricing_year: str) -> tuple[str, ...]:
    suffix = pricing_year[-2:]
    return ("Error_Code", f"GWAU{suffix}", f"NWAU{suffix}")


@dataclass(frozen=True, slots=True)
class EmergencyClassificationParityFixtureRecord:
    """Metadata-only reference for a safe emergency parity fixture."""

    fixture_id: str
    fixture_type: Literal["synthetic", "local_official"]
    assertion_mode: Literal["precomputed", "derived"]
    classifier_family: str
    classifier_version: str
    mapping_table_version: str
    pricing_year: str
    stream: str
    raw_source_fields: tuple[str, ...]
    expected_classification: str
    expected_nwau_outputs: tuple[str, ...]
    source_refs: tuple[str, ...]
    local_path_hint: str
    notes: tuple[str, ...]

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "fixture_id",
            _normalize_non_blank(self.fixture_id, field="fixture_id"),
        )
        if not _FIXTURE_ID_RE.fullmatch(self.fixture_id):
            raise EmergencyClassificationParityFixtureError(
                "fixture_id must be lowercase snake_case and deterministic"
            )
        object.__setattr__(
            self, "fixture_type", _normalize_fixture_type(self.fixture_type)
        )
        object.__setattr__(
            self, "assertion_mode", _normalize_assertion_mode(self.assertion_mode)
        )
        canonical_system = normalize_emergency_classification_system(
            self.classifier_family
        )
        object.__setattr__(
            self,
            "classifier_family",
            get_emergency_classification_name(canonical_system),
        )
        object.__setattr__(
            self,
            "classifier_version",
            _normalize_version(self.classifier_version, field="classifier_version"),
        )
        object.__setattr__(
            self,
            "mapping_table_version",
            _normalize_version(
                self.mapping_table_version, field="mapping_table_version"
            ),
        )
        object.__setattr__(self, "pricing_year", _normalize_year(self.pricing_year))
        object.__setattr__(self, "stream", _normalize_stream(self.stream))
        object.__setattr__(
            self,
            "raw_source_fields",
            _normalize_str_tuple(self.raw_source_fields, field="raw_source_fields"),
        )
        object.__setattr__(
            self,
            "expected_classification",
            _normalize_non_blank(
                self.expected_classification, field="expected_classification"
            ),
        )
        if self.expected_classification != self.classifier_family:
            raise EmergencyClassificationParityFixtureError(
                "expected_classification must match the classifier_family label"
            )
        object.__setattr__(
            self,
            "expected_nwau_outputs",
            _normalize_str_tuple(
                self.expected_nwau_outputs, field="expected_nwau_outputs"
            ),
        )
        object.__setattr__(
            self,
            "source_refs",
            _normalize_str_tuple(self.source_refs, field="source_refs"),
        )
        object.__setattr__(
            self,
            "local_path_hint",
            _normalize_relative_path(self.local_path_hint, field="local_path_hint"),
        )
        object.__setattr__(
            self,
            "notes",
            _normalize_str_tuple(self.notes, field="notes", allow_empty=True),
        )
        required_outputs = set(_expected_nwau_columns(self.pricing_year))
        if not required_outputs.issubset(self.expected_nwau_outputs):
            raise EmergencyClassificationParityFixtureError(
                "expected_nwau_outputs must include the edition-specific Error_Code, "
                "GWAU, and NWAU columns"
            )
        if self.fixture_type == "synthetic" and self.assertion_mode != "precomputed":
            raise EmergencyClassificationParityFixtureError(
                "synthetic parity fixtures must use precomputed assertion mode"
            )
        if self.fixture_type == "local_official" and self.assertion_mode != "derived":
            raise EmergencyClassificationParityFixtureError(
                "local_official parity fixtures must use derived assertion mode"
            )

    @property
    def classifier_system(self) -> str:
        return normalize_emergency_classification_system(self.classifier_family)

    @property
    def nwau_edition(self) -> str:
        return f"NWAU{self.pricing_year[-2:]}"

    @property
    def version_scope(self) -> dict[str, str]:
        return {
            "classifier_version": self.classifier_version,
            "mapping_table_version": self.mapping_table_version,
        }

    @property
    def expected_output_scope(self) -> dict[str, object]:
        return {
            "expected_classification": self.expected_classification,
            "expected_nwau_outputs": self.expected_nwau_outputs,
        }

    def to_dict(self) -> dict[str, object]:
        return {
            "fixture_id": self.fixture_id,
            "fixture_type": self.fixture_type,
            "assertion_mode": self.assertion_mode,
            "classifier_family": self.classifier_family,
            "classifier_version": self.classifier_version,
            "mapping_table_version": self.mapping_table_version,
            "pricing_year": self.pricing_year,
            "stream": self.stream,
            "raw_source_fields": list(self.raw_source_fields),
            "expected_classification": self.expected_classification,
            "expected_nwau_outputs": list(self.expected_nwau_outputs),
            "source_refs": list(self.source_refs),
            "local_path_hint": self.local_path_hint,
            "notes": list(self.notes),
        }


@dataclass(frozen=True, slots=True)
class EmergencyClassificationParityFixtureCompatibilityResult:
    """Outcome from a parity-fixture version scope validation."""

    fixture_id: str
    pricing_year: str
    fixture_type: Literal["synthetic", "local_official"]
    assertion_mode: Literal["precomputed", "derived"]
    classifier_family: str
    declared_versions: dict[str, str | None]
    expected_versions: dict[str, str | None]
    declared_outputs: dict[str, object]
    expected_outputs: dict[str, object]
    compatible: bool
    reason: str | None
    record: EmergencyClassificationParityFixtureRecord | None = None

    def to_dict(self) -> dict[str, object]:
        return {
            "fixture_id": self.fixture_id,
            "pricing_year": self.pricing_year,
            "fixture_type": self.fixture_type,
            "assertion_mode": self.assertion_mode,
            "classifier_family": self.classifier_family,
            "declared_versions": dict(self.declared_versions),
            "expected_versions": dict(self.expected_versions),
            "declared_outputs": dict(self.declared_outputs),
            "expected_outputs": dict(self.expected_outputs),
            "compatible": self.compatible,
            "reason": self.reason,
            "record": None if self.record is None else self.record.to_dict(),
        }


def build_emergency_classification_parity_fixture_reference(
    *,
    fixture_id: str,
    fixture_type: Literal["synthetic", "local_official"],
    assertion_mode: Literal["precomputed", "derived"],
    classifier_family: str,
    classifier_version: str,
    mapping_table_version: str,
    pricing_year: str,
    stream: str,
    raw_source_fields: Iterable[str],
    expected_classification: str,
    expected_nwau_outputs: Iterable[str],
    source_refs: Iterable[str],
    local_path_hint: str | Path,
    notes: Iterable[str] = (),
) -> EmergencyClassificationParityFixtureRecord:
    """Build a metadata-only parity fixture reference."""
    return EmergencyClassificationParityFixtureRecord(
        fixture_id=fixture_id,
        fixture_type=fixture_type,
        assertion_mode=assertion_mode,
        classifier_family=classifier_family,
        classifier_version=classifier_version,
        mapping_table_version=mapping_table_version,
        pricing_year=pricing_year,
        stream=stream,
        raw_source_fields=tuple(raw_source_fields),
        expected_classification=expected_classification,
        expected_nwau_outputs=tuple(expected_nwau_outputs),
        source_refs=tuple(source_refs),
        local_path_hint=local_path_hint.as_posix()
        if isinstance(local_path_hint, Path)
        else local_path_hint,
        notes=tuple(notes),
    )


def register_emergency_synthetic_classification_parity_fixture(
    *,
    fixture_id: str,
    classifier_family: str,
    classifier_version: str,
    mapping_table_version: str,
    pricing_year: str,
    stream: str,
    raw_source_fields: Iterable[str],
    expected_classification: str,
    expected_nwau_outputs: Iterable[str],
    source_refs: Iterable[str],
    local_path_hint: str | Path,
    notes: Iterable[str] = (),
) -> EmergencyClassificationParityFixtureRecord:
    """Register a synthetic parity fixture after validating its scope."""
    record = build_emergency_classification_parity_fixture_reference(
        fixture_id=fixture_id,
        fixture_type="synthetic",
        assertion_mode="precomputed",
        classifier_family=classifier_family,
        classifier_version=classifier_version,
        mapping_table_version=mapping_table_version,
        pricing_year=pricing_year,
        stream=stream,
        raw_source_fields=raw_source_fields,
        expected_classification=expected_classification,
        expected_nwau_outputs=expected_nwau_outputs,
        source_refs=source_refs,
        local_path_hint=local_path_hint,
        notes=notes,
    )
    ensure_emergency_classification_parity_fixture_scope(record)
    return record


def register_emergency_local_official_classification_parity_fixture_reference(
    *,
    fixture_id: str,
    classifier_family: str,
    classifier_version: str,
    mapping_table_version: str,
    pricing_year: str,
    stream: str,
    raw_source_fields: Iterable[str],
    expected_classification: str,
    expected_nwau_outputs: Iterable[str],
    source_refs: Iterable[str],
    local_path_hint: str | Path,
    notes: Iterable[str] = (),
) -> EmergencyClassificationParityFixtureRecord:
    """Register a local official parity fixture reference."""
    record = build_emergency_classification_parity_fixture_reference(
        fixture_id=fixture_id,
        fixture_type="local_official",
        assertion_mode="derived",
        classifier_family=classifier_family,
        classifier_version=classifier_version,
        mapping_table_version=mapping_table_version,
        pricing_year=pricing_year,
        stream=stream,
        raw_source_fields=raw_source_fields,
        expected_classification=expected_classification,
        expected_nwau_outputs=expected_nwau_outputs,
        source_refs=source_refs,
        local_path_hint=local_path_hint,
        notes=notes,
    )
    ensure_emergency_classification_parity_fixture_scope(record)
    return record


def _build_registry() -> tuple[EmergencyClassificationParityFixtureRecord, ...]:
    records: list[EmergencyClassificationParityFixtureRecord] = []
    for row in EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_ROWS:
        record = build_emergency_classification_parity_fixture_reference(
            fixture_id=str(row["fixture_id"]),
            fixture_type=cast(
                Literal["synthetic", "local_official"], row["fixture_type"]
            ),
            assertion_mode=cast(
                Literal["precomputed", "derived"], row["assertion_mode"]
            ),
            classifier_family=str(row["classifier_family"]),
            classifier_version=str(row["classifier_version"]),
            mapping_table_version=str(row["mapping_table_version"]),
            pricing_year=str(row["pricing_year"]),
            stream=str(row["stream"]),
            raw_source_fields=cast(tuple[str, ...], row["raw_source_fields"]),
            expected_classification=str(row["expected_classification"]),
            expected_nwau_outputs=cast(tuple[str, ...], row["expected_nwau_outputs"]),
            source_refs=cast(tuple[str, ...], row["source_refs"]),
            local_path_hint=str(row["local_path_hint"]),
            notes=cast(tuple[str, ...], row["notes"]),
        )
        records.append(record)
    return tuple(records)


_EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_RECORDS: Final[
    tuple[EmergencyClassificationParityFixtureRecord, ...]
] = _build_registry()
_EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_BY_ID: Final[
    dict[str, EmergencyClassificationParityFixtureRecord]
] = {
    record.fixture_id: record
    for record in _EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_RECORDS
}

EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_VERSION_MATRIX: Final[
    dict[str, dict[str, str]]
] = {
    system: {
        record.pricing_year: record.classifier_version
        for record in sorted(
            (
                record
                for record in _EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_RECORDS
                if record.classifier_system == system
            ),
            key=lambda record: record.pricing_year,
        )
    }
    for system in sorted(
        {
            record.classifier_system
            for record in _EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_RECORDS
        }
    )
}


def list_emergency_classification_parity_fixture_records(
    *,
    pricing_year: str | None = None,
    fixture_type: str | None = None,
    classifier_family: str | None = None,
    assertion_mode: str | None = None,
) -> tuple[EmergencyClassificationParityFixtureRecord, ...]:
    """Return the registered parity-fixture references, optionally filtered."""
    records = _EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_RECORDS
    if pricing_year is not None:
        normalized_year = _normalize_year(pricing_year)
        records = tuple(
            record for record in records if record.pricing_year == normalized_year
        )
    if fixture_type is not None:
        normalized_fixture_type = _normalize_fixture_type(fixture_type)
        records = tuple(
            record
            for record in records
            if record.fixture_type == normalized_fixture_type
        )
    if classifier_family is not None:
        canonical_system = normalize_emergency_classification_system(classifier_family)
        canonical_family = get_emergency_classification_name(canonical_system)
        records = tuple(
            record for record in records if record.classifier_family == canonical_family
        )
    if assertion_mode is not None:
        normalized_assertion_mode = _normalize_assertion_mode(assertion_mode)
        records = tuple(
            record
            for record in records
            if record.assertion_mode == normalized_assertion_mode
        )
    return records


def get_emergency_classification_parity_fixture_record(
    fixture_id: str,
) -> EmergencyClassificationParityFixtureRecord | None:
    """Return a registered parity fixture by identifier, if one exists."""
    normalized_id = _normalize_non_blank(fixture_id, field="fixture_id")
    if not _FIXTURE_ID_RE.fullmatch(normalized_id):
        raise EmergencyClassificationParityFixtureError(
            "fixture_id must be lowercase snake_case and deterministic"
        )
    return _EMERGENCY_CLASSIFICATION_PARITY_FIXTURE_BY_ID.get(normalized_id)


def _build_local_official_reference(
    record: EmergencyClassificationParityFixtureRecord,
) -> EmergencyGrouperReference:
    window = EmergencyGrouperVersionWindow(
        system=record.classifier_system,
        pricing_year=record.pricing_year,
        emergency_classification_version=record.classifier_version,
        stream_compatibility=(record.stream,),
        source_refs=record.source_refs,
        notes=record.notes,
    )
    return build_emergency_external_reference(
        reference_id=f"{record.fixture_id}_reference",
        reference_type="file_exchange",
        access_mode="local_only",
        license_boundary="restricted",
        status="resolved",
        local_path_hint=record.local_path_hint,
        supported_versions=(window,),
        notes=record.notes,
    )


def validate_emergency_classification_parity_fixture_scope(
    record: EmergencyClassificationParityFixtureRecord,
) -> EmergencyClassificationParityFixtureCompatibilityResult:
    """Check whether a parity fixture stays within its declared safe scope."""
    canonical_system = record.classifier_system
    normalized_year = record.pricing_year
    declared_versions: dict[str, str | None] = {
        "classifier_version": record.classifier_version,
        "mapping_table_version": record.mapping_table_version,
    }
    declared_outputs = record.expected_output_scope
    expected_nwau_outputs = _expected_nwau_columns(normalized_year)
    expected_classification = get_emergency_classification_name(canonical_system)

    registry_result = validate_emergency_classification_compatibility(
        canonical_system,
        normalized_year,
        record.classifier_version,
        stream=record.stream,
    )
    if not registry_result.compatible:
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": None,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=registry_result.reason,
            record=record,
        )

    bundle_record = get_emergency_code_mapping_bundle_record(
        canonical_system, normalized_year
    )
    if bundle_record is None:
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": None,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=(
                "no emergency code mapping bundle is registered for the declared "
                "classifier family and pricing year"
            ),
            record=record,
        )

    bundle_validation = validate_emergency_code_mapping_bundle_compatibility(
        bundle_record
    )
    if not bundle_validation.compatible:
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": bundle_record.bundle_version,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=bundle_validation.reason,
            record=record,
        )

    if record.mapping_table_version != bundle_record.bundle_version:
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": bundle_record.bundle_version,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=(
                "mapping_table_version must match the registered emergency "
                "mapping bundle version"
            ),
            record=record,
        )

    if tuple(record.raw_source_fields) != tuple(bundle_record.source_fields):
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": bundle_record.bundle_version,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=(
                "raw_source_fields must match the registered emergency mapping "
                "bundle source fields"
            ),
            record=record,
        )

    if record.expected_classification != bundle_record.output_fields[0]:
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": bundle_record.bundle_version,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=(
                "expected_classification must match the registered emergency "
                "mapping bundle output field"
            ),
            record=record,
        )

    if not set(expected_nwau_outputs).issubset(record.expected_nwau_outputs):
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": bundle_record.bundle_version,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=(
                "expected_nwau_outputs must include the edition-specific Error_Code, "
                "GWAU, and NWAU columns"
            ),
            record=record,
        )

    if record.assertion_mode == "precomputed":
        grouper_result = validate_emergency_grouper_compatibility(
            canonical_system,
            normalized_year,
            record.classifier_version,
            stream=record.stream,
            source_mode="precomputed",
        )
    else:
        reference = _build_local_official_reference(record)
        grouper_result = validate_emergency_grouper_compatibility(
            canonical_system,
            normalized_year,
            record.classifier_version,
            stream=record.stream,
            source_mode="external-reference",
            reference=reference,
        )
    if not grouper_result.compatible:
        return EmergencyClassificationParityFixtureCompatibilityResult(
            fixture_id=record.fixture_id,
            pricing_year=record.pricing_year,
            fixture_type=record.fixture_type,
            assertion_mode=record.assertion_mode,
            classifier_family=record.classifier_family,
            declared_versions=declared_versions,
            expected_versions={
                "classifier_version": registry_result.expected_version,
                "mapping_table_version": bundle_record.bundle_version,
            },
            declared_outputs=declared_outputs,
            expected_outputs={
                "expected_classification": expected_classification,
                "expected_nwau_outputs": expected_nwau_outputs,
            },
            compatible=False,
            reason=grouper_result.reason,
            record=record,
        )

    return EmergencyClassificationParityFixtureCompatibilityResult(
        fixture_id=record.fixture_id,
        pricing_year=record.pricing_year,
        fixture_type=record.fixture_type,
        assertion_mode=record.assertion_mode,
        classifier_family=record.classifier_family,
        declared_versions=declared_versions,
        expected_versions={
            "classifier_version": registry_result.expected_version,
            "mapping_table_version": bundle_record.bundle_version,
        },
        declared_outputs=declared_outputs,
        expected_outputs={
            "expected_classification": expected_classification,
            "expected_nwau_outputs": expected_nwau_outputs,
        },
        compatible=True,
        reason=None,
        record=record,
    )


def ensure_emergency_classification_parity_fixture_scope(
    record: EmergencyClassificationParityFixtureRecord,
) -> EmergencyClassificationParityFixtureCompatibilityResult:
    """Raise when a parity fixture falls outside its declared safe scope."""
    result = validate_emergency_classification_parity_fixture_scope(record)
    if not result.compatible:
        raise EmergencyClassificationParityFixtureError(
            result.reason or "emergency classification parity fixture is incompatible"
        )
    return result
