from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import nwau_py.fixtures as fixtures


FIXTURE_MANIFEST = (
    Path(__file__).resolve().parent / "fixtures" / "golden" / "acute_2025" / "manifest.json"
)


def test_fixture_manifest_loads_the_acute_pack():
    manifest = fixtures.load_fixture_manifest(FIXTURE_MANIFEST)

    assert manifest.schema_version == "1.0"
    assert manifest.fixture_id == "acute_2025"
    assert manifest.calculator == "acute"
    assert manifest.pricing_year == "2025"
    assert manifest.service_stream == "admitted acute"
    assert manifest.cross_language_ready is True
    assert manifest.privacy_classification == "synthetic"
    assert manifest.source_basis.kind == "synthetic_sample"
    assert manifest.precision.tolerance.absolute == pytest.approx(0.0001)
    assert manifest.precision.tolerance.relative == pytest.approx(0.0001)
    assert manifest.payloads["input"].columns == (
        "DRG",
        "LOS",
        "ICU_HOURS",
        "ICU_OTHER",
        "PAT_SAMEDAY_FLAG",
        "PAT_PRIVATE_FLAG",
        "PAT_COVID_FLAG",
    )
    assert manifest.payloads["expected_output"].columns == ("NWAU25",)


@pytest.mark.parametrize(
    "field",
    [
        "provenance",
        "cross_language_ready",
        "privacy_classification",
        "precision",
        "payloads",
    ],
)
def test_fixture_manifest_rejects_missing_required_metadata(tmp_path, field):
    payload = json.loads(FIXTURE_MANIFEST.read_text(encoding="utf-8"))
    payload.pop(field)
    manifest_path = tmp_path / "broken-manifest.json"
    manifest_path.write_text(json.dumps(payload), encoding="utf-8")

    with pytest.raises(fixtures.FixtureManifestError):
        fixtures.load_fixture_manifest(manifest_path)


def test_fixture_manifest_rejects_unexpected_privacy_classification(tmp_path):
    payload = json.loads(FIXTURE_MANIFEST.read_text(encoding="utf-8"))
    payload["privacy_classification"] = "restricted"
    manifest_path = tmp_path / "broken-manifest.json"
    manifest_path.write_text(json.dumps(payload), encoding="utf-8")

    with pytest.raises(fixtures.FixtureManifestError):
        fixtures.load_fixture_manifest(manifest_path)
