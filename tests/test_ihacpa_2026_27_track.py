from __future__ import annotations

import json
from pathlib import Path

from nwau_py.pricing_constants import (
    NEC_BY_YEAR,
    NEP_BY_YEAR,
    PRICING_CONSTANTS_SCHEMA_VERSION,
    get_nec,
    get_nep,
    get_supported_pricing_years,
)

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "ihacpa_2026_27_support_20260512"
TRACKS = ROOT / "conductor" / "tracks.md"
SOURCE_INVENTORY = TRACK / "source_inventory.md"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ihacpa_2026_27_support_track_scaffold_is_present():
    for path in [
        TRACK / "spec.md",
        TRACK / "plan.md",
        TRACK / "metadata.json",
        TRACK / "index.md",
        SOURCE_INVENTORY,
        TRACKS,
        ]:
        assert path.exists(), path


def test_ihacpa_2026_27_support_track_metadata_remains_conservative():
    metadata = json.loads(_read_text(TRACK / "metadata.json"))
    track_index = _read_text(TRACK / "index.md")
    registry = _read_text(TRACKS)

    assert metadata["track_id"] == "ihacpa_2026_27_support_20260512"
    assert metadata["status"] == "in_progress"
    assert metadata["track_class"] == "governance"
    assert metadata["current_state"] == "roadmap-only"
    assert metadata["publication_status"] == "not-applicable"
    assert metadata["completion_evidence"] == ["docs", "workflows", "tests"]

    assert "ihacpa_2026_27_support_20260512" in track_index
    assert "IHACPA 2026-27 Support" in registry
    assert (
        "Gate: add current 2026-27 NEP, technical specification, "
        "price-weight, calculator, and classification-version support with "
        "explicit validation status."
    ) in registry
    assert "explicit validation status" in registry
    assert "roadmap-only" in track_index
    assert "Phase 2 and Phase 3 remain open" in track_index
    assert "Phase 1 source inventory is in progress" in track_index


def test_ihacpa_2026_27_phase_1_source_inventory_is_complete_and_gap_explicit():
    inventory = _read_text(SOURCE_INVENTORY)
    spec = _read_text(TRACK / "spec.md")
    plan = _read_text(TRACK / "plan.md")

    for phrase in [
        "Scope: official IHACPA sources for 2026-27 NEP, NEC, technical specifications, NWAU calculators, and price-weight downloads.",
        "## Inventory",
        "## Explicit gaps",
        "## Source notes",
        "National Efficient Price Determination 2026",
        "National Efficient Cost Determination 2026",
        "National Pricing Model Technical Specifications 2026",
        "NWAU calculators",
        "Price weights",
        "$7,418 per NWAU(26)",
        "AR-DRG v12.0",
        "Tier 2 Version 10.0",
        "No checksums or hashes were previously captured",
        "calculator parity",
        "no standalone open license",
        "The SAS `.7Z` archive has not been extracted.",
        "No separate standalone NEC price-weight table file was found",
    ]:
        assert phrase in inventory or phrase in inventory.lower()

    assert "Do not claim calculator parity until verified against official IHACPA calculator outputs or source logic." in spec
    assert "Keep validation conservative and auditable." in spec
    assert "Phase 1 source inventory is in progress" in _read_text(TRACK / "index.md")

    for phrase in [
        "Record 2026-27 NEP, NEC, technical specifications, calculator, and price-weight source entries.",
        "Mark unavailable calculator artifacts as explicit gaps rather than inferred support.",
        "publication dates, checksums, and provenance notes still need to be filled in.",
    ]:
        assert phrase in plan

    assert "No checksums or hashes were previously captured" in inventory
    assert (
        "explicit gaps rather than being silently implied as support" in inventory
        or "Explicit gaps" in inventory
    )


def test_ihacpa_2026_27_phase_2_pricing_constants_api_exposes_nep26():
    assert PRICING_CONSTANTS_SCHEMA_VERSION == "1.0"
    assert tuple(get_supported_pricing_years()) == ("2025", "2026")
    assert NEP_BY_YEAR == {"2025": 7434, "2026": 7418}
    assert NEC_BY_YEAR == {"2025": 0, "2026": 0}
    assert get_nep("2026") == 7418
    assert get_nep("2025") == 7434
    assert get_nep("2024") is None
    assert get_nec("2026") == 0
    assert get_nec("2024") is None


def test_ihacpa_2026_27_phase_3_validation_status_stays_conservative():
    spec = _read_text(TRACK / "spec.md")
    index = _read_text(TRACK / "index.md")
    inventory = _read_text(SOURCE_INVENTORY)
    registry = _read_text(TRACKS)

    for phrase in [
        "Do not claim calculator parity until verified against official IHACPA calculator outputs or source logic.",
        "Keep validation conservative and auditable.",
        "explicit validation status",
        "Phase 2 and Phase 3 remain open",
        "not yet validated",
        "No NEP26 compiled/Python reference files from IHACPA.",
        "No NEP26 user guides or calculator documentation published yet.",
    ]:
        assert (
            phrase in spec
            or phrase in index
            or phrase in inventory
            or phrase in registry
        )

    assert "validated" not in index.lower()
    assert "parity validation is not claimed" in inventory or "not yet validated" in inventory
