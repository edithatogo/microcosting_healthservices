from __future__ import annotations

import re
from pathlib import Path

import pytest

from nwau_py.classification_validation import (
    ClassificationValidationError,
    get_classification_version,
    get_supported_classification_years,
    get_transition_years,
    is_classification_licensed,
    validate_aecc_input,
    validate_amhcc_input,
    validate_ar_drg_input,
    validate_tier_2_input,
    validate_udg_input,
)

ROOT = Path(__file__).resolve().parents[1]
TRACK = ROOT / "conductor" / "tracks" / "classification_input_validation_20260512"


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_track_matrix_records_streams_versions_and_license_caveats():
    matrix = _read_text(TRACK / "classification_matrix.md")

    for phrase in [
        "AR-DRG",
        "AECC",
        "UDG",
        "Tier 2",
        "AMHCC",
        "licensed / non-redistributable",
        "Do not treat them as interchangeable",
        "Version 10.0",
    ]:
        assert phrase in matrix


@pytest.mark.parametrize(
    ("validator", "fields", "year", "version"),
    [
        (validate_ar_drg_input, ("DRG",), "2026", "v12.0"),
        (validate_aecc_input, ("AECC",), "2026", "v1.1"),
        (validate_udg_input, ("UDG",), "2026", "UDG_v1.3"),
        (validate_tier_2_input, ("TIER2_CLINIC",), "2026", "v10.0"),
        (validate_amhcc_input, ("AMHCC",), "2026", "v1"),
    ],
)
def test_stream_validators_accept_matching_year_versions(
    validator,
    fields,
    year,
    version,
):
    result = validator(fields, year=year, version=version)

    assert result.is_valid is True
    assert result.pricing_year == year
    assert result.declared_version == version
    assert result.required_fields == fields


def test_ar_drg_validator_reports_missing_required_field():
    with pytest.raises(ClassificationValidationError, match="DRG"):
        validate_ar_drg_input(("LOS",), year="2026", version="v12.0")


def test_ed_classification_versions_are_not_interchangeable():
    with pytest.raises(ClassificationValidationError, match=re.escape("expects v1.1")):
        validate_aecc_input(("AECC",), year="2026", version="UDG_v1.3")

    with pytest.raises(
        ClassificationValidationError,
        match=re.escape("expects UDG_v1.3"),
    ):
        validate_udg_input(("UDG",), year="2026", version="v1.1")


def test_tier_2_is_pricing_year_aware():
    assert get_classification_version("tier_2", "2025") == "v7"
    assert get_classification_version("tier_2", "2026") == "v10.0"

    with pytest.raises(
        ClassificationValidationError,
        match=re.escape("expects v10.0"),
    ):
        validate_tier_2_input(("TIER2_CLINIC",), year="2026", version="v9.1")


def test_classification_metadata_exposes_transitions_and_license_flags():
    assert is_classification_licensed("AR-DRG") is True
    assert is_classification_licensed("AECC") is False
    assert "2026" in get_transition_years("AR-DRG")
    assert "2026" in get_supported_classification_years("Tier 2")
