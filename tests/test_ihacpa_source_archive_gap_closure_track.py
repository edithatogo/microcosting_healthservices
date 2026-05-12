from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "archive" / "ihacpa_source_archive_gap_closure_20260511"
TRACKS = ROOT / "conductor" / "tracks.md"
MANIFEST = ROOT / "archive" / "ihacpa" / "raw" / "manifest.json"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ihacpa_source_archive_gap_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
    ]:
        assert path.exists(), path


def test_ihacpa_source_archive_gap_track_records_manifest_state():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    track_index = _read_text(TRACK / "index.md")
    registry = _read_text(TRACKS)
    manifest = json.loads(_read_text(MANIFEST))

    assert metadata["track_id"] == "ihacpa_source_archive_gap_closure_20260511"
    assert metadata["status"] in {"complete", "completed"}
    assert "source archive gaps" in metadata["description"].lower()

    assert len(manifest) == 94
    assert sum(1 for item in manifest if item["status"] == "downloaded") == 92
    assert sum(1 for item in manifest if item["status"] == "box-html-only") == 2
    status_ok = all(
        item["status"] in {"downloaded", "box-html-only"} for item in manifest
    )
    assert status_ok, "Unexpected archive status value found"

    spec_lower = spec.lower()

    for phrase in [
        "94 entries",
        "92 entries are `downloaded`",
        "2 entries are `box-html-only`",
        "2021-22",
        "2022-23",
        "restore workflow",
        "manifest",
    ]:
        assert phrase in spec_lower

    for phrase in [
        "Archive Completeness Baseline",
        "Gap Recovery and Recording",
        "Restore Workflow and Documentation",
        "Conductor - Automated Review and Checkpoint",
    ]:
        assert phrase in plan

    assert "ihacpa_source_archive_gap_closure_20260511" in track_index
    assert "IHACPA Source Archive Gap Closure and Restore Validation" in registry
    assert "recover or explicitly gap-record" in registry.lower()
