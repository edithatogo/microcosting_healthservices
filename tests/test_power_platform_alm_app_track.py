from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "archive" / "power_platform_alm_app_20260510"
TRACKS = ROOT / "conductor" / "tracks.md"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_power_platform_alm_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
        ROOT / "power-platform" / "solution" / "README.md",
        ROOT / "power-platform" / "solution" / "solution-manifest.md",
        ROOT / "power-platform" / "solution" / "environment-variables.md",
        ROOT / "power-platform" / "solution" / "connection-references.md",
        ROOT / "power-platform" / "solution" / "alm-workflow.md",
        ROOT / "power-platform" / "solution" / "app-surface.md",
        ROOT / "power-platform" / "connectors" / "service-boundary-contract.md",
        ROOT / "power-platform" / "pipelines" / "README.md",
        ROOT / ".github" / "workflows" / "power-platform-alm.yml",
    ]:
        assert path.exists(), path


def test_power_platform_alm_track_records_scope_and_requirements():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    track_index = _read_text(TRACK / "index.md")
    registry = _read_text(TRACKS)

    assert metadata["track_id"] == "power_platform_alm_app_20260510"
    assert metadata["status"] == "complete"
    assert "Power Platform ALM app setup" in metadata["description"]

    for phrase in [
        "SOTA requirements review",
        "solution-based Power Platform ALM app",
        "orchestration-only",
        "managed environments",
        "Source control should remain the single source of truth",
        "Azure DevOps-oriented",
        "deprecated ALM Accelerator",
        "pac",
        "az",
        "pacx",
        "solution scaffold",
        "service-boundary contract",
        "Phase 3 Scaffold Contract",
    ]:
        assert phrase in spec

    for phrase in [
        "SOTA Requirements and ALM Architecture",
        "Toolchain and Environment Bootstrap",
        "Power Platform Solution and Orchestration App",
        "ALM Automation and Delivery",
        "Conductor - Automated Review and Checkpoint",
        (
            "via conductor-review, auto-fix, and auto-progress "
            "'Power Platform Solution and Orchestration App'"
        ),
        (
            "via conductor-review, auto-fix, and auto-progress "
            "'ALM Automation and Delivery'"
        ),
    ]:
        assert phrase in plan

    assert "power_platform_alm_app_20260510" in track_index
    assert "Power Platform ALM App Setup and Delivery" in registry
    assert "Power Platform Solution Scaffold" in track_index
    assert "ALM Workflow" in track_index
