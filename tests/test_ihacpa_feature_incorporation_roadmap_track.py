from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "archive" / "ihacpa_feature_incorporation_roadmap_20260511"
TRACKS = ROOT / "conductor" / "tracks.md"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ihacpa_feature_incorporation_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
    ]:
        assert path.exists(), path


def test_ihacpa_feature_incorporation_track_records_feature_matrix_scope():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    track_index = _read_text(TRACK / "index.md")
    registry = _read_text(TRACKS)

    assert metadata["track_id"] == "ihacpa_feature_incorporation_roadmap_20260511"
    assert metadata["status"] in {"complete", "completed"}
    assert "inventory" in metadata["description"].lower()

    for phrase in [
        "acute",
        "subacute",
        "ed",
        "outpatients",
        "mh",
        "adjust",
        "complexity",
        "HAC",
        "AHR",
        "implemented, documented-only, missing, or deferred",
    ]:
        assert phrase in spec

    for phrase in [
        "Archive-to-Code Feature Inventory",
        "Feature Gap Closure",
        "Parity Matrix and Handoff",
        "Conductor - Automated Review and Checkpoint",
    ]:
        assert phrase in plan

    assert "ihacpa_feature_incorporation_roadmap_20260511" in track_index
    assert "IHACPA Feature Incorporation and Calculator Coverage Roadmap" in registry
    assert "complexity/HAC/AHR" in registry
    assert (
        "[x] **Track: IHACPA Feature Incorporation and Calculator Coverage Roadmap**"
        in registry
    )
