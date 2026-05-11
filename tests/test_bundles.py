from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any, cast

import pytest

from nwau_py.bundles import (
    BUNDLE_SCHEMA_VERSION,
    BundleContractError,
    DataBundle,
    load_bundle,
    load_bundle_manifest,
    read_bundle_frame,
    read_bundle_frame_polars,
)

BUNDLE_ROOT = Path(__file__).resolve().parent / "fixtures" / "bundles" / "acute_2025"
MANIFEST = BUNDLE_ROOT / "manifest.json"


def _manifest_payload() -> dict[str, object]:
    return cast(dict[str, object], json.loads(MANIFEST.read_text(encoding="utf-8")))


def test_bundle_manifest_loads_the_acute_pilot_bundle():
    manifest = load_bundle_manifest(MANIFEST)

    assert manifest.schema_version == BUNDLE_SCHEMA_VERSION
    assert manifest.bundle_id == "acute_2025"
    assert manifest.calculator == "acute"
    assert manifest.pricing_year == "2025"
    assert manifest.backend_neutral is True
    assert manifest.payloads["input"].format == "parquet"
    assert manifest.payloads["expected_output"].row_count == 3
    assert manifest.payloads["input"].columns == (
        "DRG",
        "LOS",
        "ICU_HOURS",
        "ICU_OTHER",
        "PAT_SAMEDAY_FLAG",
        "PAT_PRIVATE_FLAG",
        "PAT_COVID_FLAG",
    )


def test_bundle_loader_reads_pandas_and_polars_payloads():
    bundle = load_bundle(MANIFEST)
    pandas_input = read_bundle_frame(bundle, "input")

    assert isinstance(bundle, DataBundle)
    assert list(pandas_input.columns) == [
        "DRG",
        "LOS",
        "ICU_HOURS",
        "ICU_OTHER",
        "PAT_SAMEDAY_FLAG",
        "PAT_PRIVATE_FLAG",
        "PAT_COVID_FLAG",
    ]
    assert len(pandas_input) == 3

    polars_input = read_bundle_frame_polars(bundle, "input")
    assert getattr(polars_input, "shape", None) == (3, 7)


@pytest.mark.parametrize(
    "field,value,match",
    [
        ("backend_neutral", False, "backend_neutral must be true"),
        ("checksum", "not-a-checksum", "checksum must be a lowercase sha256"),
    ],
)
def test_bundle_manifest_rejects_invalid_metadata(tmp_path, field, value, match):
    payload = _manifest_payload()
    payload[field] = value
    manifest_path = tmp_path / "manifest.json"
    manifest_path.write_text(json.dumps(payload), encoding="utf-8")

    with pytest.raises(BundleContractError, match=match):
        load_bundle_manifest(manifest_path)


def test_bundle_manifest_checksum_matches_payload_bytes():
    manifest = cast(dict[str, Any], _manifest_payload())
    expected = hashlib.sha256(
        (BUNDLE_ROOT / "input.parquet").read_bytes()
        + (BUNDLE_ROOT / "expected_output.parquet").read_bytes()
    ).hexdigest()
    assert manifest["checksum"] == expected


def test_bundle_reader_reports_missing_payload_files(tmp_path):
    bundle_dir = tmp_path / "acute_2025"
    bundle_dir.mkdir()
    manifest = cast(dict[str, Any], _manifest_payload())
    payloads = cast(dict[str, Any], manifest["payloads"])
    payloads["input"]["path"] = "missing.parquet"
    manifest_path = bundle_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
    bundle = load_bundle(manifest_path)

    with pytest.raises(
        BundleContractError, match=r"payloads\.input\.path does not exist"
    ):
        read_bundle_frame(bundle, "input")
