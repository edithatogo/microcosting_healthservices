from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import nwau_py.fixtures as fixtures  # noqa: E402

FIXTURE_MANIFEST = (
    Path(__file__).resolve().parent
    / "fixtures"
    / "golden"
    / "acute_2025"
    / "manifest.json"
)


def _manifest_payload() -> dict:
    return json.loads(FIXTURE_MANIFEST.read_text(encoding="utf-8"))


def _write_manifest(tmp_path: Path, payload: dict) -> Path:
    manifest_path = tmp_path / "manifest.json"
    manifest_path.write_text(json.dumps(payload), encoding="utf-8")
    return manifest_path


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
    payload = _manifest_payload()
    payload["privacy_classification"] = "restricted"
    manifest_path = tmp_path / "broken-manifest.json"
    manifest_path.write_text(json.dumps(payload), encoding="utf-8")

    with pytest.raises(fixtures.FixtureManifestError):
        fixtures.load_fixture_manifest(manifest_path)


@pytest.mark.parametrize(
    "field_path,value,reason",
    [
        (
            ("calculator",),
            "mystery-engine",
            "calculator identifier should be constrained",
        ),
        (
            ("pricing_year",),
            "2025-26",
            "pricing_year should remain a simple year label",
        ),
        (("service_stream",), "unclassified", "service_stream should be constrained"),
        (
            ("source_basis", "kind"),
            "manual_spreadsheet",
            "source_basis.kind should be constrained",
        ),
        (
            ("precision", "rounding_policy"),
            "bankers_rounding",
            "rounding_policy should be constrained",
        ),
    ],
)
def test_fixture_manifest_rejects_unapproved_contract_values(
    tmp_path, field_path, value, reason
):
    payload = _manifest_payload()
    target = payload
    for key in field_path[:-1]:
        target = target[key]
    target[field_path[-1]] = value

    manifest_path = _write_manifest(tmp_path, payload)

    with pytest.raises(fixtures.FixtureManifestError, match=reason):
        fixtures.load_fixture_manifest(manifest_path)


def test_fixture_manifest_requires_cross_language_readiness_flag_true(tmp_path):
    payload = _manifest_payload()
    payload["cross_language_ready"] = False
    manifest_path = _write_manifest(tmp_path, payload)

    with pytest.raises(fixtures.FixtureManifestError, match="cross_language_ready"):
        fixtures.load_fixture_manifest(manifest_path)


@pytest.mark.parametrize("field", ["created_from", "notes"])
def test_fixture_manifest_rejects_missing_provenance_metadata(tmp_path, field):
    payload = _manifest_payload()
    payload["provenance"].pop(field)
    manifest_path = _write_manifest(tmp_path, payload)

    with pytest.raises(fixtures.FixtureManifestError, match="provenance"):
        fixtures.load_fixture_manifest(manifest_path)
