from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "release_evidence_automation_20260512"
TRACKS_REGISTRY = ROOT / "conductor" / "tracks.md"

SAMPLE_REPORT: dict[str, Any] = {
    "report_version": "1.0",
    "generated_at": "2026-05-12T12:00:00Z",
    "source": {
        "version": "0.5.0",
        "git_tag": "v0.5.0",
        "commit": "abc1234",
        "repository": "github.com/owner/microcosting_healthservices",
    },
    "registries": [
        {
            "name": "pypi",
            "status": "published",
            "version": "0.5.0",
            "url": "https://pypi.org/project/nwau-py/",
            "checked_at": "2026-05-12T12:00:00Z",
        },
        {
            "name": "conda-forge",
            "status": "future-only",
            "version": None,
            "url": None,
            "checked_at": "2026-05-12T12:00:00Z",
            "notes": "Not yet submitted",
        },
        {
            "name": "github_release",
            "status": "published",
            "version": "0.5.0",
            "url": "https://github.com/owner/microcosting_healthservices/releases/tag/v0.5.0",
            "checked_at": "2026-05-12T12:00:00Z",
        },
        {
            "name": "github_pages",
            "status": "published",
            "url": "https://owner.github.io/microcosting_healthservices/",
            "checked_at": "2026-05-12T12:00:00Z",
        },
        {
            "name": "crates_io",
            "status": "future-only",
            "version": None,
            "url": None,
            "checked_at": "2026-05-12T12:00:00Z",
            "notes": "Rust core not yet stable",
        },
    ],
    "workflows": [
        {
            "name": "release",
            "status": "passing",
            "latest_run": "2026-05-11T10:00:00Z",
        },
        {
            "name": "publish",
            "status": "passing",
            "latest_run": "2026-05-11T10:00:00Z",
        },
        {
            "name": "docs",
            "status": "passing",
            "latest_run": "2026-05-12T08:00:00Z",
        },
        {
            "name": "ci",
            "status": "passing",
            "latest_run": "2026-05-12T09:00:00Z",
        },
        {
            "name": "conda_recipe",
            "status": "future-only",
            "latest_run": None,
        },
    ],
    "consistency_checks": {
        "version_tag_match": True,
        "readme_badges_current": True,
        "homepage_links_valid": True,
        "warnings": [],
    },
}


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_release_evidence_automation_spec_defines_json_schema():
    spec = _read_text(TRACK / "release_evidence_automation_spec.md")
    assert "Evidence Schema" in spec
    assert "JSON Report Schema" in spec
    assert "registries" in spec
    assert "workflows" in spec
    assert "consistency_checks" in spec


def test_release_evidence_automation_spec_defines_markdown_schema():
    spec = _read_text(TRACK / "release_evidence_automation_spec.md")
    assert "Markdown Report Schema" in spec
    assert "Registry Status" in spec
    assert "Workflow Status" in spec
    assert "Consistency Checks" in spec


def test_release_evidence_automation_spec_defines_evidence_states():
    spec = _read_text(TRACK / "release_evidence_automation_spec.md")
    assert "published" in spec
    assert "unpublished" in spec
    assert "future-only" in spec
    assert "published-with-gaps" in spec


def test_sample_report_is_valid_json():
    report_json = json.dumps(SAMPLE_REPORT, indent=2)
    parsed = json.loads(report_json)
    assert parsed["report_version"] == "1.0"
    assert parsed["source"]["version"] == "0.5.0"
    assert len(parsed["registries"]) == 5
    assert len(parsed["workflows"]) == 5


def test_sample_report_schema_is_stable():
    report_json = json.dumps(SAMPLE_REPORT, indent=2, sort_keys=True)
    parsed = json.loads(report_json)
    second_json = json.dumps(parsed, indent=2, sort_keys=True)
    assert report_json == second_json


def test_sample_report_detects_future_only_registries():
    future = [r for r in SAMPLE_REPORT["registries"] if r["status"] == "future-only"]
    assert len(future) == 2
    assert {r["name"] for r in future} == {"conda-forge", "crates_io"}


def test_sample_report_consistency_checks_default_to_passing():
    assert SAMPLE_REPORT["consistency_checks"]["version_tag_match"] is True
    assert SAMPLE_REPORT["consistency_checks"]["warnings"] == []


def test_release_evidence_automation_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "index.md",
        TRACK / "metadata.json",
        TRACK / "release_evidence_automation_spec.md",
    ]:
        assert path.exists(), path


def test_release_evidence_automation_track_metadata():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    assert metadata["track_id"] == "release_evidence_automation_20260512"
    assert metadata["track_class"] == "publication"


def test_release_evidence_automation_in_tracks_registry():
    registry = _read_text(TRACKS_REGISTRY)
    assert "Release Evidence Automation" in registry
    assert "release_evidence_automation_20260512" in registry
