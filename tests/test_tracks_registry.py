from __future__ import annotations

from pathlib import Path


TRACKS = Path(__file__).resolve().parents[1] / "conductor" / "tracks.md"


def test_tracks_registry_orders_the_focused_tracks():
    text = TRACKS.read_text(encoding="utf-8")
    expected = [
        "Source Archive and Provenance Registry",
        "Cross-Language Golden Test Suite",
        "Python Tooling and CI Modernization",
        "Calculator Core Abstraction and Validation Models",
        "Public Calculator API Contract",
        "Arrow and Polars Data Bundle Migration",
        "GitHub Pages Web App Prototype",
        "C# Calculation Engine and Power Platform Adapter",
        "Release and Supply-Chain Governance",
    ]

    positions = [text.index(name) for name in expected]
    assert positions == sorted(positions)


def test_tracks_registry_records_dependency_and_gate_language():
    text = TRACKS.read_text(encoding="utf-8")
    for phrase in [
        "Gate: establish source acquisition, storage policy, and manifest provenance",
        "Depends on: source archive manifesting and known-good reference artifacts.",
        "Depends on: source archive provenance and validation fixture shape.",
        "Depends on: validation evidence and CI coverage",
        "Depends on: calculator core abstractions and golden fixtures.",
        "Depends on: calculator core abstractions and stable validation fixtures.",
        "Depends on: public API contract, validation fixtures, and governance rules",
        "Depends on: public API contract, calculator core abstractions, and golden fixtures.",
        "Depends on: CI, validation evidence, and contract stability.",
    ]:
        assert phrase in text
