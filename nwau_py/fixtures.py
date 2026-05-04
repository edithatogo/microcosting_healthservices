"""Shared loaders for self-describing golden fixture packs.

The fixture packs are intentionally runner-neutral: a JSON manifest describes
the calculator contract and points at small tabular payloads that can be read
by Python, C#, or web tooling without embedding harness-specific objects.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pandas as pd

SUPPORTED_MANIFEST_SCHEMA_VERSION = "1.0"
SUPPORTED_PRIVACY_CLASSIFICATIONS = {"synthetic", "deidentified", "public"}
SUPPORTED_PAYLOAD_FORMATS = {"csv", "parquet"}


class FixtureManifestError(ValueError):
    """Raised when a fixture manifest is missing required contract metadata."""


@dataclass(frozen=True, slots=True)
class FixtureTolerance:
    """Tolerance contract for fixture comparisons."""

    absolute: float
    relative: float


@dataclass(frozen=True, slots=True)
class FixtureSourceBasis:
    """Provenance metadata for a fixture pack."""

    kind: str
    description: str
    input_source: str
    expected_output_source: str


@dataclass(frozen=True, slots=True)
class FixturePayload:
    """Metadata for a single payload in the fixture pack."""

    role: str
    path: Path
    format: str
    row_count: int
    columns: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class FixturePrecision:
    """Precision and rounding policy for a fixture pack."""

    rounding_policy: str
    tolerance: FixtureTolerance


@dataclass(frozen=True, slots=True)
class FixtureManifest:
    """Normalized, validated fixture manifest."""

    schema_version: str
    fixture_id: str
    calculator: str
    pricing_year: str
    service_stream: str
    cross_language_ready: bool
    privacy_classification: str
    source_basis: FixtureSourceBasis
    payloads: dict[str, FixturePayload]
    precision: FixturePrecision
    provenance: dict[str, Any]


@dataclass(frozen=True, slots=True)
class FixturePack:
    """Validated fixture pack with manifest and resolved payload paths."""

    manifest_path: Path
    pack_dir: Path
    manifest: FixtureManifest

    @property
    def input_payload(self) -> FixturePayload:
        return self.manifest.payloads["input"]

    @property
    def expected_output_payload(self) -> FixturePayload:
        return self.manifest.payloads["expected_output"]

    def payload_path(self, role: str) -> Path:
        return self.pack_dir / self.manifest.payloads[role].path


def _require_mapping(value: Any, *, field: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise FixtureManifestError(f"{field} must be a mapping")
    return value


def _require_str(value: Any, *, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise FixtureManifestError(f"{field} must be a non-empty string")
    return value


def _require_bool(value: Any, *, field: str) -> bool:
    if not isinstance(value, bool):
        raise FixtureManifestError(f"{field} must be a boolean")
    return value


def _require_int(value: Any, *, field: str) -> int:
    if not isinstance(value, int) or isinstance(value, bool):
        raise FixtureManifestError(f"{field} must be an integer")
    return value


def _require_float(value: Any, *, field: str) -> float:
    if not isinstance(value, (int, float)) or isinstance(value, bool):
        raise FixtureManifestError(f"{field} must be numeric")
    return float(value)


def _parse_payload(role: str, payload: dict[str, Any]) -> FixturePayload:
    path = Path(_require_str(payload.get("path"), field=f"payloads.{role}.path"))
    format_ = _require_str(payload.get("format"), field=f"payloads.{role}.format")
    if format_ not in SUPPORTED_PAYLOAD_FORMATS:
        raise FixtureManifestError(
            f"payloads.{role}.format must be one of {sorted(SUPPORTED_PAYLOAD_FORMATS)}"
        )
    row_count = _require_int(
        payload.get("row_count"), field=f"payloads.{role}.row_count"
    )
    columns_raw = payload.get("columns")
    if not isinstance(columns_raw, list) or not all(
        isinstance(column, str) and column.strip() for column in columns_raw
    ):
        raise FixtureManifestError(f"payloads.{role}.columns must be a list of strings")
    return FixturePayload(
        role=role,
        path=path,
        format=format_,
        row_count=row_count,
        columns=tuple(columns_raw),
    )


def load_fixture_manifest(manifest_path: str | Path) -> FixtureManifest:
    """Load and validate a golden-fixture manifest."""

    path = Path(manifest_path)
    payload = json.loads(path.read_text(encoding="utf-8"))
    manifest = _require_mapping(payload, field="manifest")

    schema_version = _require_str(
        manifest.get("schema_version"), field="schema_version"
    )
    if schema_version != SUPPORTED_MANIFEST_SCHEMA_VERSION:
        raise FixtureManifestError(
            f"unsupported schema_version {schema_version!r}; "
            f"expected {SUPPORTED_MANIFEST_SCHEMA_VERSION!r}"
        )

    fixture_id = _require_str(manifest.get("fixture_id"), field="fixture_id")
    calculator = _require_str(manifest.get("calculator"), field="calculator")
    pricing_year = _require_str(manifest.get("pricing_year"), field="pricing_year")
    service_stream = _require_str(
        manifest.get("service_stream"), field="service_stream"
    )
    cross_language_ready = _require_bool(
        manifest.get("cross_language_ready"), field="cross_language_ready"
    )
    privacy_classification = _require_str(
        manifest.get("privacy_classification"), field="privacy_classification"
    )
    if privacy_classification not in SUPPORTED_PRIVACY_CLASSIFICATIONS:
        raise FixtureManifestError(
            "privacy_classification must be one of "
            f"{sorted(SUPPORTED_PRIVACY_CLASSIFICATIONS)}"
        )

    source_basis_raw = _require_mapping(
        manifest.get("source_basis"), field="source_basis"
    )
    source_basis = FixtureSourceBasis(
        kind=_require_str(source_basis_raw.get("kind"), field="source_basis.kind"),
        description=_require_str(
            source_basis_raw.get("description"), field="source_basis.description"
        ),
        input_source=_require_str(
            source_basis_raw.get("input_source"), field="source_basis.input_source"
        ),
        expected_output_source=_require_str(
            source_basis_raw.get("expected_output_source"),
            field="source_basis.expected_output_source",
        ),
    )

    precision_raw = _require_mapping(manifest.get("precision"), field="precision")
    tolerance_raw = _require_mapping(
        precision_raw.get("tolerance"), field="precision.tolerance"
    )
    tolerance = FixtureTolerance(
        absolute=_require_float(
            tolerance_raw.get("absolute"), field="precision.tolerance.absolute"
        ),
        relative=_require_float(
            tolerance_raw.get("relative"), field="precision.tolerance.relative"
        ),
    )
    if tolerance.absolute < 0 or tolerance.relative < 0:
        raise FixtureManifestError("tolerances must be non-negative")
    precision = FixturePrecision(
        rounding_policy=_require_str(
            precision_raw.get("rounding_policy"),
            field="precision.rounding_policy",
        ),
        tolerance=tolerance,
    )

    payloads_raw = _require_mapping(manifest.get("payloads"), field="payloads")
    payloads = {
        role: _parse_payload(role, _require_mapping(value, field=f"payloads.{role}"))
        for role, value in payloads_raw.items()
    }
    if "input" not in payloads or "expected_output" not in payloads:
        raise FixtureManifestError("payloads must include input and expected_output")

    provenance = _require_mapping(manifest.get("provenance"), field="provenance")

    return FixtureManifest(
        schema_version=schema_version,
        fixture_id=fixture_id,
        calculator=calculator,
        pricing_year=pricing_year,
        service_stream=service_stream,
        cross_language_ready=cross_language_ready,
        privacy_classification=privacy_classification,
        source_basis=source_basis,
        payloads=payloads,
        precision=precision,
        provenance=provenance,
    )


def load_fixture_pack(manifest_path: str | Path) -> FixturePack:
    """Load a fixture pack and resolve its payload paths."""

    manifest_path = Path(manifest_path)
    manifest = load_fixture_manifest(manifest_path)
    return FixturePack(
        manifest_path=manifest_path,
        pack_dir=manifest_path.parent,
        manifest=manifest,
    )


def read_payload_frame(pack: FixturePack, role: str) -> pd.DataFrame:
    """Read a payload frame from a validated fixture pack."""

    payload = pack.manifest.payloads[role]
    path = pack.payload_path(role)
    if not path.exists():
        raise FixtureManifestError(f"missing payload file: {path}")
    if payload.format == "csv":
        frame = pd.read_csv(path)
    elif payload.format == "parquet":
        frame = pd.read_parquet(path)
    else:  # pragma: no cover - guarded by validation
        raise FixtureManifestError(f"unsupported payload format: {payload.format}")
    if list(frame.columns) != list(payload.columns):
        raise FixtureManifestError(
            f"{role} columns do not match manifest: {list(frame.columns)!r}"
        )
    if len(frame) != payload.row_count:
        raise FixtureManifestError(
            f"{role} row count {len(frame)} does not match manifest "
            f"{payload.row_count}"
        )
    return frame
