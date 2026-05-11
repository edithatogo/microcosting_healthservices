from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import nwau_py.fixtures as fixtures

FIXTURE_MANIFEST = (
    Path(__file__).resolve().parent
    / "fixtures"
    / "golden"
    / "acute_2025"
    / "manifest.json"
)


def test_fixture_manifest_uses_runner_neutral_metadata():
    manifest = fixtures.load_fixture_manifest(FIXTURE_MANIFEST)
    manifest_dict = {
        "schema_version": manifest.schema_version,
        "fixture_id": manifest.fixture_id,
        "calculator": manifest.calculator,
        "pricing_year": manifest.pricing_year,
        "service_stream": manifest.service_stream,
        "cross_language_ready": manifest.cross_language_ready,
        "privacy_classification": manifest.privacy_classification,
        "source_basis": {
            "kind": manifest.source_basis.kind,
            "description": manifest.source_basis.description,
            "input_source": manifest.source_basis.input_source,
            "expected_output_source": manifest.source_basis.expected_output_source,
        },
        "payloads": {
            role: {
                "path": str(payload.path),
                "format": payload.format,
                "row_count": payload.row_count,
                "columns": list(payload.columns),
            }
            for role, payload in manifest.payloads.items()
        },
        "precision": {
            "rounding_policy": manifest.precision.rounding_policy,
            "tolerance": {
                "absolute": manifest.precision.tolerance.absolute,
                "relative": manifest.precision.tolerance.relative,
            },
        },
        "provenance": manifest.provenance,
    }

    encoded = json.dumps(manifest_dict)
    decoded = json.loads(encoded)

    assert decoded["cross_language_ready"] is True
    assert decoded["privacy_classification"] == "synthetic"
    assert decoded["payloads"]["input"]["path"] == "input.csv"
    assert not Path(decoded["payloads"]["input"]["path"]).is_absolute()
    assert decoded["precision"]["tolerance"]["absolute"] == 0.0001
    assert decoded["precision"]["tolerance"]["relative"] == 0.0001


def test_fixture_manifest_fields_are_plain_strings_and_numbers():
    manifest = fixtures.load_fixture_manifest(FIXTURE_MANIFEST)
    assert isinstance(manifest.fixture_id, str)
    assert isinstance(manifest.cross_language_ready, bool)
    assert isinstance(manifest.precision.rounding_policy, str)
    assert isinstance(manifest.precision.tolerance.absolute, float)
    assert isinstance(manifest.precision.tolerance.relative, float)
