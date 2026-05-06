from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "ecosystem_language_readiness_20260507"
CONDUCTOR_INDEX = ROOT / "conductor" / "index.md"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ecosystem_language_readiness_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "parallelization.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
    ]:
        assert path.exists(), path


def test_ecosystem_language_readiness_track_scope_is_recorded():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    parallelization = _read_text(TRACK / "parallelization.md")
    conductor_index = _read_text(CONDUCTOR_INDEX)

    assert metadata["status"] == "new"
    assert metadata["track_id"] == "ecosystem_language_readiness_20260507"
    assert metadata["updated_at"] == "2026-05-06T22:13:30Z"

    for phrase in [
        "pyOpenSci",
        "rOpenSci",
        "Julia",
        "Power Platform",
        "C#",
        "FHIR R4",
        "HL7 v2",
        "IHE",
        "ICD-10-AM",
        "JOSS",
        "CITATION.cff",
        "Dependency Model",
        "Parallelization Model",
    ]:
        assert phrase in spec

    for phase in [
        "Repository Surface and Standards Audit",
        "Language and Platform Decision Matrix",
        "Health Standards and Community Contribution Roadmap",
    ]:
        assert phase in plan

    assert "Conductor - Automated Review and Checkpoint" in plan
    assert "Document dependency graph and parallel execution model" in plan
    assert "Ecosystem Standards and Language Readiness Track" in conductor_index

    for phrase in [
        "Subagent Workstreams",
        "Write Ownership",
        "Merge Order",
        "Power Platform ALM",
        "golden fixtures as the parity gate",
    ]:
        assert phrase in parallelization
