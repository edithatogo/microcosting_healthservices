"""Reference bundle resolution for contract-backed calculator inputs.

The module keeps bundle selection narrow and explicit:

- `reference_bundle_root` resolves the on-disk bundle root for a
  calculator/year pair.
- `resolve_reference_bundle` selects exactly one bundle manifest and validates
  its identity and required metadata.
- `ReferenceBundle` is a strict, immutable manifest view that stays free of
  pandas or calculator implementation dependencies.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

from pydantic import BaseModel, ConfigDict, Field, field_validator

__all__ = [
    "ReferenceBundle",
    "reference_bundle_root",
    "resolve_reference_bundle",
]

_YEAR_RE = re.compile(r"^(?:201[3-9]|202[0-6])$")
_HEX_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
_MANIFEST_NAME = "manifest.json"


def _validate_year(year: str) -> str:
    if year.strip() != year:
        raise ValueError("year must not contain leading or trailing whitespace")
    if not _YEAR_RE.fullmatch(year):
        raise ValueError("year must be a supported four-digit IHACPA label")
    return year


def _validate_identifier(value: str, *, field_name: str) -> str:
    if value.strip() != value:
        raise ValueError(
            f"{field_name} must not contain leading or trailing whitespace"
        )
    if not value:
        raise ValueError(f"{field_name} must not be blank")
    return value


class ReferenceBundle(BaseModel):
    """Validated manifest view for a reference-data bundle."""

    model_config = ConfigDict(extra="forbid", frozen=True, str_strip_whitespace=True)

    manifest_path: Path
    bundle_id: str
    calculator: str
    pricing_year: str
    source_artifact_id: str
    source_page_url: str
    checksum: str
    provenance: dict[str, object] = Field(default_factory=dict)

    @field_validator(
        "bundle_id",
        "calculator",
        "source_artifact_id",
        "source_page_url",
    )
    @classmethod
    def _validate_non_blank(cls, value: str) -> str:
        return _validate_identifier(value, field_name="bundle metadata")

    @field_validator("pricing_year")
    @classmethod
    def _validate_pricing_year(cls, value: str) -> str:
        return _validate_year(value)

    @field_validator("checksum")
    @classmethod
    def _validate_checksum(cls, value: str) -> str:
        if not _HEX_SHA256_RE.fullmatch(value):
            raise ValueError("checksum must be a lowercase sha256 hex digest")
        return value


def reference_bundle_root(
    base_dir: Path | str,
    *,
    year: str,
    calculator: str,
) -> Path:
    """Return the canonical root directory for a calculator/year bundle set."""

    year = _validate_year(year)
    calculator = _validate_identifier(calculator, field_name="calculator")
    return Path(base_dir) / year / calculator


def _select_bundle_dir(root: Path, bundle_id: str | None) -> Path:
    bundle_dirs = sorted(
        path
        for path in root.iterdir()
        if path.is_dir() and (path / _MANIFEST_NAME).is_file()
    )
    if bundle_id is not None:
        bundle_dir = root / _validate_identifier(bundle_id, field_name="bundle_id")
        manifest_path = bundle_dir / _MANIFEST_NAME
        if not manifest_path.is_file():
            raise FileNotFoundError(
                f"reference bundle not found for bundle_id={bundle_id!r}"
            )
        return bundle_dir

    if not bundle_dirs:
        raise FileNotFoundError(f"no reference bundle manifests found in {root}")
    if len(bundle_dirs) > 1:
        raise ValueError(
            "ambiguous reference bundle selection; provide bundle_id explicitly"
        )
    return bundle_dirs[0]


def resolve_reference_bundle(
    base_dir: Path | str,
    *,
    year: str,
    calculator: str,
    bundle_id: str | None = None,
) -> ReferenceBundle:
    """Resolve a single validated reference bundle manifest from disk."""

    root = reference_bundle_root(base_dir, year=year, calculator=calculator)
    if not root.is_dir():
        raise FileNotFoundError(
            f"no reference bundles found for year={year!r} calculator={calculator!r}"
        )

    bundle_dir = _select_bundle_dir(root, bundle_id)
    manifest_path = bundle_dir / _MANIFEST_NAME
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("reference bundle manifest must be a JSON object")

    data["manifest_path"] = manifest_path
    bundle = ReferenceBundle.model_validate(data)

    if bundle.pricing_year != _validate_year(year):
        raise ValueError("reference bundle year does not match the requested year")
    if bundle.calculator != _validate_identifier(calculator, field_name="calculator"):
        raise ValueError(
            "reference bundle calculator does not match the requested calculator"
        )
    if bundle_id is not None and bundle.bundle_id != bundle_id:
        raise ValueError("reference bundle id does not match the requested bundle_id")

    if bundle.manifest_path != manifest_path:
        raise ValueError(
            "reference bundle manifest_path does not match the manifest location"
        )

    return bundle
