from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "ihacpa_2026_27_support_20260512"
TRACKS = ROOT / "conductor" / "tracks.md"
SOURCE_INVENTORY = TRACK / "source_inventory.md"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ihacpa_2026_27_support_track_files_exist():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
        SOURCE_INVENTORY,
        TRACKS,
    ]:
        assert path.exists(), path


def test_ihacpa_2026_27_support_track_records_source_inventory_scope():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")
    track_index = _read_text(TRACK / "index.md")
    registry = _read_text(TRACKS)

    assert metadata["track_id"] == "ihacpa_2026_27_support_20260512"
    assert metadata["status"] == "in_progress"
    assert metadata["track_class"] == "governance"
    assert metadata["current_state"] == "roadmap-only"

    assert "NEP26" in spec
    assert "$7,418 per NWAU" in spec

    for url in [
        "https://www.ihacpa.gov.au/resources/national-efficient-price-determination-2026-27",
        "https://www.ihacpa.gov.au/what-we-do/pricing/national-pricing-model-technical-specifications",
        "https://www.ihacpa.gov.au/what-we-do/national-weighted-activity-unit-nwau-calculators",
    ]:
        assert url in spec

    for phrase in [
        (
            "Add a structured source manifest entry for 2026-27 NEP, NEC, "
            "technical specifications, price-weight tables, and calculator "
            "downloads when available."
        ),
        "Add versioned pricing constants for NEP26 and related metadata.",
        "Add compatibility tracking for AR-DRG v12.0 and Tier 2 v10.0.",
        (
            "Do not claim calculator parity until verified against official "
            "IHACPA calculator outputs or source logic."
        ),
        "Keep validation conservative and auditable.",
    ]:
        assert phrase in spec

    for phrase in [
        (
            "Record 2026-27 NEP, NEC, technical specifications, calculator, "
            "and price-weight source entries."
        ),
        (
            "Mark unavailable calculator artifacts as explicit gaps rather than "
            "inferred support."
        ),
        "Add NEP26 value with source citation.",
        "Document AR-DRG v12.0 and Tier 2 v10.0 impacts.",
    ]:
        assert phrase in plan

    assert "ihacpa_2026_27_support_20260512" in track_index
    assert "IHACPA 2026-27 Support" in registry
    assert (
        "Gate: add current 2026-27 NEP, technical specification, "
        "price-weight, calculator, and classification-version support with "
        "explicit validation status."
    ) in registry
    assert "explicit validation status" in registry


def test_ihacpa_2026_27_source_inventory_records_conservative_phase_1_state():
    inventory = _read_text(SOURCE_INVENTORY)
    plan = _read_text(TRACK / "plan.md")
    track_index = _read_text(TRACK / "index.md")

    for phrase in [
        "National Efficient Price Determination 2026",
        "$7,418 per NWAU(26)",
        "National Efficient Cost Determination 2026",
        "National Pricing Model Technical Specifications 2026",
        "NWAU calculators",
        "Price weights",
        "No checksums or hashes were captured",
        "calculator parity",
    ]:
        assert phrase in inventory

    assert "AR-DRG v12.0" in inventory or "AR-DRG Version 12.0" in inventory
    assert "Tier 2" in inventory and "Version 10.0" in inventory

    assert "[/]" in plan
    assert "publication dates, checksums, and provenance notes still need" in plan
    assert "Phase 1 source inventory is in progress" in track_index
    assert "Phase 2 and Phase 3 remain open" in track_index
