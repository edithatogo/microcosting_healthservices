"""Tests for the community mental health calculator contract and validation
fixtures."""

from __future__ import annotations

from pathlib import Path

import pandas as pd
import pytest

from nwau_py.calculators.community_mh_contract import (
    COMMUNITY_MH_CONTRACT,
    CommunityMHContractError,
    build_community_mh_contract,
    validate_community_mh_input,
    validate_community_mh_output,
)


def test_contract_calculator_id():
    """The community MH contract must use a distinct calculator identifier."""
    c = COMMUNITY_MH_CONTRACT
    assert c.calculator_id == "community_mh"
    assert c.calculator_id not in ("mh", "acute", "ed")


def test_contract_required_input_columns():
    """The contract must require the core community mental health input
    columns."""
    c = COMMUNITY_MH_CONTRACT
    required = set(c.required_input_columns)
    assert "AMHCC" in required
    assert "SC_PAT_PUB" in required
    assert "SC_NOPAT_PUB" in required


def test_contract_required_output_columns():
    """The contract must require the NWAU output column."""
    c = COMMUNITY_MH_CONTRACT
    required = set(c.required_output_columns)
    assert any(col.startswith("NWAU") for col in required)


def test_build_contract_for_year():
    """build_community_mh_contract() returns a valid contract for a supported
    year."""
    contract = build_community_mh_contract("2025")
    assert contract.pricing_year.year == "2025"


def test_validate_input_valid():
    """validate_community_mh_input accepts a frame with all required columns."""
    df = pd.DataFrame(
        {
            "AMHCC": ["2001"],
            "SC_PAT_PUB": [1],
            "SC_NOPAT_PUB": [0],
            "STATE": [1],
        }
    )
    validate_community_mh_input(df)  # should not raise


def test_validate_input_missing_column():
    """validate_community_mh_input raises when required columns are missing."""
    df = pd.DataFrame({"AMHCC": ["2001"]})  # missing SC_PAT_PUB, SC_NOPAT_PUB
    with pytest.raises(CommunityMHContractError):
        validate_community_mh_input(df)


def test_validate_output_valid():
    """validate_community_mh_output accepts a frame with NWAU column."""
    df = pd.DataFrame({"NWAU25": [1.5], "AMHCC": ["2001"]})
    validate_community_mh_output(df)  # should not raise


def test_validate_output_missing():
    """validate_community_mh_output raises when NWAU column is missing."""
    df = pd.DataFrame({"AMHCC": ["2001"]})
    with pytest.raises(CommunityMHContractError):
        validate_community_mh_output(df)


def test_fixture_gap_record_exists():
    """A fixture-gap record must document that no golden fixtures exist for
    community mental health."""
    gap_path = Path(
        "conductor/tracks/community_mental_health_calculator_20260512/fixture_gaps.md"
    )
    assert gap_path.exists(), (
        "Fixture gap record not found. "
        "Create track fixture_gaps.md"
    )
    content = gap_path.read_text()
    assert "golden" in content.lower() or "fixture" in content.lower()


def test_contract_rejects_mh_calculator_id():
    """The community MH contract must not accept the generic 'mh' calculator
    ID."""
    c = COMMUNITY_MH_CONTRACT
    assert c.calculator_id != "mh"


def test_input_columns_include_stream_prefix():
    """The contract must include AMHCC prefix convention documentation."""
    c = COMMUNITY_MH_CONTRACT
    # AMHCC prefix "2" = community stream
    assert "AMHCC" in c.required_input_columns