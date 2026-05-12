from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
import pandas as pd
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from nwau_py.classification_validators import (
    ClassificationValidationResult,
    validate_aecc,
    validate_amhcc,
    validate_ar_drg,
    validate_classification_input,
    validate_tier_2,
    validate_udg,
)

from nwau_py.classification_matrix import AR_DRG_VERSIONS

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_VALID_DRG_CODES = ["A01A", "B02B", "Z99Z", "P67Z", "T63A"]
_VALID_AECC_CODES = ["E0110A", "E0110B", "E0130A", "E9999Z"]
_VALID_UDG_CODES = ["U0101", "U0202", "U9999"]
_VALID_URG_CODES = ["R0101", "R0202", "R9999"]  # pre-2021 URG format
_VALID_TIER2_CODES = ["10.10", "20.05", "40.99", "30.00", "15.75"]
_VALID_AMHCC_CODES = ["1001", "2001", "1101", "2999", "2500"]

_ALL_YEARS = sorted(AR_DRG_VERSIONS)
_PRICING_YEARS = [y for y in _ALL_YEARS if int(y) >= 2013]


# ===================================================================
# ClassificationValidationResult
# ===================================================================


class TestClassificationValidationResult:
    def test_default_construction_is_valid(self):
        result = ClassificationValidationResult()
        assert result.is_valid is True
        assert result.errors == []
        assert result.warnings == []

    def test_with_errors_passed(self):
        result = ClassificationValidationResult(
            is_valid=False, errors=["bad code"], warnings=["needs review"]
        )
        assert result.is_valid is False
        assert result.errors == ["bad code"]
        assert result.warnings == ["needs review"]


# ===================================================================
# AR-DRG validation
# ===================================================================


class TestValidateArDrg:
    @pytest.mark.parametrize("code", _VALID_DRG_CODES)
    @pytest.mark.parametrize("year", ["2022", "2023", "2024", "2025"])
    def test_valid_drg_format_passes(self, code, year):
        result = validate_ar_drg(pd.Series([code]), year)
        assert result.is_valid, f"expected {code} for {year} to be valid"

    def test_all_valid_codes_pass_for_supported_years(self):
        codes = pd.Series(_VALID_DRG_CODES)
        for year in ["2021", "2022", "2023", "2024", "2025"]:
            result = validate_ar_drg(codes, year)
            assert result.is_valid, f"expected valid for {year}"

    @pytest.mark.parametrize(
        "bad_code", ["abc", "12345", "", "A01", "AB01A", "01AB", "A-1B", "A1B"]
    )
    def test_invalid_format_fails(self, bad_code):
        result = validate_ar_drg(pd.Series([bad_code]), "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_empty_string_fails(self):
        result = validate_ar_drg(pd.Series([""]), "2025")
        assert result.is_valid is False

    def test_none_value_produces_warning(self):
        codes = pd.Series([None])
        result = validate_ar_drg(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_nan_value_produces_warning(self):
        codes = pd.Series([np.nan])
        result = validate_ar_drg(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_mixed_valid_and_invalid_returns_errors(self):
        codes = pd.Series(["A01A", "bad", "B02B", ""])
        result = validate_ar_drg(codes, "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_version_mismatch_v11_code_with_v10_year_warns(self):
        codes = pd.Series(["A01A"])
        result = validate_ar_drg(codes, "2022")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_unknown_year_returns_error(self):
        codes = pd.Series(["A01A"])
        result = validate_ar_drg(codes, "1999")
        assert result.is_valid is False
        assert any("1999" in e or "year" in e.lower() for e in result.errors)

    def test_year_outside_supported_range(self):
        codes = pd.Series(["A01A"])
        result = validate_ar_drg(codes, "1999")
        assert result.is_valid is False

    @pytest.mark.parametrize("year", _PRICING_YEARS)
    def test_year_in_range_does_not_blow_up(self, year):
        codes = pd.Series(_VALID_DRG_CODES)
        result = validate_ar_drg(codes, year)
        assert isinstance(result, ClassificationValidationResult)

    def test_empty_series_handled_gracefully(self):
        codes = pd.Series([], dtype="object")
        result = validate_ar_drg(codes, "2025")
        assert result.is_valid
        assert result.errors == []

    def test_pandas_series_with_mixed_types(self):
        codes = pd.Series(["A01A", 123, None, "B02B"])
        result = validate_ar_drg(codes, "2025")
        assert result.is_valid is False

    def test_drg_code_with_lowercase_passes(self):
        codes = pd.Series(["a01a", "b02b"])
        result = validate_ar_drg(codes, "2025")
        assert result.is_valid


# ===================================================================
# AECC validation
# ===================================================================


class TestValidateAecc:
    @pytest.mark.parametrize("code", _VALID_AECC_CODES)
    @pytest.mark.parametrize("year", ["2021", "2022", "2023", "2024", "2025"])
    def test_valid_aecc_format_passes(self, code, year):
        result = validate_aecc(pd.Series([code]), year)
        assert result.is_valid, f"expected {code} for {year} to be valid"

    @pytest.mark.parametrize(
        "bad_code", ["abc", "12345", "", "E011", "E0110AA", "X0110A"]
    )
    def test_invalid_format_fails(self, bad_code):
        result = validate_aecc(pd.Series([bad_code]), "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_year_2013_has_no_aecc_returns_error(self):
        codes = pd.Series(["E0110A"])
        result = validate_aecc(codes, "2013")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    @pytest.mark.parametrize("year", ["2014", "2015", "2016", "2017", "2018", "2019"])
    def test_early_years_without_aecc_return_error(self, year):
        codes = pd.Series(["E0110A"])
        result = validate_aecc(codes, year)
        assert result.is_valid is False

    def test_shadow_pricing_year_2020_is_valid_with_possible_warning(self):
        codes = pd.Series(["E0110A"])
        result = validate_aecc(codes, "2020")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_none_value_produces_warning(self):
        codes = pd.Series([None])
        result = validate_aecc(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_nan_value_produces_warning(self):
        codes = pd.Series([np.nan])
        result = validate_aecc(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_mixed_valid_and_invalid_aecc_returns_error(self):
        codes = pd.Series(["E0110A", "bad", "E9999Z"])
        result = validate_aecc(codes, "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_unknown_year_returns_error(self):
        codes = pd.Series(["E0110A"])
        result = validate_aecc(codes, "1999")
        assert result.is_valid is False
        assert any("1999" in e or "year" in e.lower() for e in result.errors)

    def test_empty_series_handled_gracefully(self):
        codes = pd.Series([], dtype="object")
        result = validate_aecc(codes, "2025")
        assert result.is_valid
        assert result.errors == []

    def test_aecc_lowercase_still_passes(self):
        codes = pd.Series(["e0110a", "e0110b"])
        result = validate_aecc(codes, "2025")
        assert result.is_valid


# ===================================================================
# UDG / URG validation
# ===================================================================


class TestValidateUdg:
    @pytest.mark.parametrize("code", _VALID_UDG_CODES)
    @pytest.mark.parametrize("year", ["2021", "2022", "2023", "2024", "2025"])
    def test_valid_udg_format_passes(self, code, year):
        result = validate_udg(pd.Series([code]), year)
        assert result.is_valid, f"expected {code} for {year} to be valid"

    @pytest.mark.parametrize("code", _VALID_URG_CODES)
    @pytest.mark.parametrize("year", ["2016", "2017", "2018", "2019", "2020"])
    def test_urg_format_accepted_for_pre_2021_years(self, code, year):
        result = validate_udg(pd.Series([code]), year)
        assert result.is_valid, f"expected {code} for {year} to be valid"

    @pytest.mark.parametrize("bad_code", ["abc", "12345", "", "1234", "U"])
    def test_invalid_format_fails(self, bad_code):
        result = validate_udg(pd.Series([bad_code]), "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_none_value_produces_warning(self):
        codes = pd.Series([None])
        result = validate_udg(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_nan_value_produces_warning(self):
        codes = pd.Series([np.nan])
        result = validate_udg(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_mixed_valid_and_invalid_udg_returns_error(self):
        codes = pd.Series(["U0101", "", "U9999", "bad"])
        result = validate_udg(codes, "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_unknown_year_returns_error(self):
        codes = pd.Series(["U0101"])
        result = validate_udg(codes, "1999")
        assert result.is_valid is False

    def test_empty_series_handled_gracefully(self):
        codes = pd.Series([], dtype="object")
        result = validate_udg(codes, "2025")
        assert result.is_valid
        assert result.errors == []

    def test_urg_used_with_post_2020_year_gives_warning(self):
        codes = pd.Series(["R0101"])
        result = validate_udg(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_udg_lowercase_still_passes(self):
        codes = pd.Series(["u0101", "u0202"])
        result = validate_udg(codes, "2025")
        assert result.is_valid


# ===================================================================
# Tier 2 validation
# ===================================================================


class TestValidateTier2:
    @pytest.mark.parametrize("code", _VALID_TIER2_CODES)
    @pytest.mark.parametrize("year", ["2022", "2023", "2024", "2025"])
    def test_valid_tier2_format_passes(self, code, year):
        result = validate_tier_2(pd.Series([code]), year)
        assert result.is_valid, f"expected {code} for {year} to be valid"

    @pytest.mark.parametrize(
        "bad_code", ["abc", "10", "10.100", "100.10", "", ".10", "10."]
    )
    def test_invalid_format_fails(self, bad_code):
        result = validate_tier_2(pd.Series([bad_code]), "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_year_2021_has_no_versioned_tier_2_but_accepts_valid_format(self):
        codes = pd.Series(["10.10", "20.05"])
        result = validate_tier_2(codes, "2021")
        assert result.is_valid

    def test_pre_2021_years_accept_valid_format(self):
        for year in ["2016", "2017", "2018", "2019", "2020"]:
            codes = pd.Series(["10.10"])
            result = validate_tier_2(codes, year)
            assert result.is_valid, f"expected valid for {year}"

    def test_none_value_produces_warning(self):
        codes = pd.Series([None])
        result = validate_tier_2(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_nan_value_produces_warning(self):
        codes = pd.Series([np.nan])
        result = validate_tier_2(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_mixed_valid_and_invalid_tier2_returns_error(self):
        codes = pd.Series(["10.10", "abc", "40.99", ""])
        result = validate_tier_2(codes, "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_unknown_year_returns_error(self):
        codes = pd.Series(["10.10"])
        result = validate_tier_2(codes, "1999")
        assert result.is_valid is False

    def test_empty_series_handled_gracefully(self):
        codes = pd.Series([], dtype="object")
        result = validate_tier_2(codes, "2025")
        assert result.is_valid
        assert result.errors == []

    def test_tier_2_as_numeric_series(self):
        codes = pd.Series([10.10, 20.05], dtype="float64")
        result = validate_tier_2(codes, "2025")
        assert result.is_valid


# ===================================================================
# AMHCC validation
# ===================================================================


class TestValidateAmhcc:
    @pytest.mark.parametrize("code", _VALID_AMHCC_CODES)
    @pytest.mark.parametrize("year", ["2021", "2022", "2023", "2024", "2025"])
    def test_valid_amhcc_format_passes(self, code, year):
        result = validate_amhcc(pd.Series([code]), year)
        assert result.is_valid, f"expected {code} for {year} to be valid"

    def test_community_prefix_2_is_valid_for_all_years(self):
        for year in ["2021", "2022", "2023", "2024", "2025"]:
            result = validate_amhcc(pd.Series(["2001", "2500", "2999"]), year)
            assert result.is_valid, f"expected valid for community prefix in {year}"

    @pytest.mark.parametrize("bad_code", ["abc", "3xxx", "", "12345", "12", "ABCD"])
    def test_invalid_format_fails(self, bad_code):
        result = validate_amhcc(pd.Series([bad_code]), "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_year_2013_has_no_mh_calculator_returns_error(self):
        codes = pd.Series(["1001"])
        result = validate_amhcc(codes, "2013")
        assert result.is_valid is False
        msg = "expected 2013 year to produce mh-related error"
        assert any(
            "2013" in e or "mh" in e.lower() or "calculator" in e.lower()
            for e in result.errors
        ), msg

    @pytest.mark.parametrize(
        "year", ["2014", "2015", "2016", "2017", "2018", "2019", "2020"]
    )
    def test_early_years_without_amhcc_return_error(self, year):
        codes = pd.Series(["1001"])
        result = validate_amhcc(codes, year)
        assert result.is_valid is False

    def test_none_value_produces_warning(self):
        codes = pd.Series([None])
        result = validate_amhcc(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_nan_value_produces_warning(self):
        codes = pd.Series([np.nan])
        result = validate_amhcc(codes, "2025")
        assert result.is_valid
        assert len(result.warnings) >= 1

    def test_mixed_valid_and_invalid_amhcc_returns_error(self):
        codes = pd.Series(["1001", "bad", "2001", ""])
        result = validate_amhcc(codes, "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_unknown_year_returns_error(self):
        codes = pd.Series(["1001"])
        result = validate_amhcc(codes, "1999")
        assert result.is_valid is False

    def test_empty_series_handled_gracefully(self):
        codes = pd.Series([], dtype="object")
        result = validate_amhcc(codes, "2025")
        assert result.is_valid
        assert result.errors == []

    def test_admitted_prefix_1_is_valid(self):
        codes = pd.Series(["1001", "1500", "1999"])
        result = validate_amhcc(codes, "2025")
        assert result.is_valid


# ===================================================================
# validate_classification_input
# ===================================================================


class TestValidateClassificationInput:
    def test_acute_stream_validates_drg_column(self):
        df = pd.DataFrame({"DRG": ["A01A", "B02B"]})
        result = validate_classification_input(df, "acute", "2025")
        assert result.is_valid

    def test_acute_stream_invalid_drg_reports_errors(self):
        df = pd.DataFrame({"DRG": ["bad", ""]})
        result = validate_classification_input(df, "acute", "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_acute_stream_missing_drg_column(self):
        df = pd.DataFrame({"LOS": [1]})
        with pytest.raises(ValueError):
            validate_classification_input(df, "acute", "2025")

    def test_ed_stream_validates_aecc_column(self):
        df = pd.DataFrame({"AECC": ["E0110A", "E9999Z"]})
        result = validate_classification_input(df, "ed", "2025")
        assert result.is_valid

    def test_ed_stream_invalid_aecc_reports_errors(self):
        df = pd.DataFrame({"AECC": ["bad", "E011"]})
        result = validate_classification_input(df, "ed", "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_ed_stream_missing_aecc_column(self):
        df = pd.DataFrame({"LOS": [1]})
        with pytest.raises(ValueError):
            validate_classification_input(df, "ed", "2025")

    def test_outpatients_stream_validates_tier2_clinic_column(self):
        df = pd.DataFrame({"TIER2_CLINIC": ["10.10", "20.05"]})
        result = validate_classification_input(df, "outpatients", "2025")
        assert result.is_valid

    def test_outpatients_stream_invalid_tier2_reports_errors(self):
        df = pd.DataFrame({"TIER2_CLINIC": ["abc", "10.100"]})
        result = validate_classification_input(df, "outpatients", "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_outpatients_stream_missing_tier2_clinic_column(self):
        df = pd.DataFrame({"LOS": [1]})
        with pytest.raises(ValueError):
            validate_classification_input(df, "outpatients", "2025")

    def test_mh_stream_validates_amhcc_column(self):
        df = pd.DataFrame({"AMHCC": ["1001", "2001"]})
        result = validate_classification_input(df, "mh", "2025")
        assert result.is_valid

    def test_mh_stream_invalid_amhcc_reports_errors(self):
        df = pd.DataFrame({"AMHCC": ["abc", ""]})
        result = validate_classification_input(df, "mh", "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_mh_stream_missing_amhcc_column(self):
        df = pd.DataFrame({"LOS": [1]})
        with pytest.raises(ValueError):
            validate_classification_input(df, "mh", "2025")

    def test_community_mh_stream_validates_amhcc_column(self):
        df = pd.DataFrame({"AMHCC": ["2001", "2500"]})
        result = validate_classification_input(df, "community_mh", "2025")
        assert result.is_valid

    def test_community_mh_stream_invalid_amhcc_reports_errors(self):
        df = pd.DataFrame({"AMHCC": ["bad"]})
        result = validate_classification_input(df, "community_mh", "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    def test_community_mh_stream_missing_amhcc_column(self):
        df = pd.DataFrame({"SC_PAT_PUB": [1]})
        with pytest.raises(ValueError):
            validate_classification_input(df, "community_mh", "2025")

    def test_unknown_stream_raises_value_error(self):
        df = pd.DataFrame({"DRG": ["A01A"]})
        with pytest.raises(ValueError, match=r"unknown.*stream|unrecognized"):
            validate_classification_input(df, "unknown_stream", "2025")

    @pytest.mark.parametrize(
        "stream,column",
        [
            ("acute", "DRG"),
            ("ed", "AECC"),
            ("outpatients", "TIER2_CLINIC"),
            ("mh", "AMHCC"),
            ("community_mh", "AMHCC"),
        ],
    )
    def test_all_streams_with_empty_dataframe(self, stream, column):
        df = pd.DataFrame({column: []})
        result = validate_classification_input(df, stream, "2025")
        assert result.is_valid

    def test_year_propagated_to_sub_validator(self):
        df = pd.DataFrame({"DRG": ["A01A"]})
        result = validate_classification_input(df, "acute", "1999")
        assert result.is_valid is False
        assert len(result.errors) >= 1


# ===================================================================
# Edge cases
# ===================================================================


class TestEdgeCases:
    def test_empty_series_handled_by_all_validators(self):
        empty = pd.Series([], dtype="object")
        for validator, year in [
            (validate_ar_drg, "2025"),
            (validate_aecc, "2025"),
            (validate_udg, "2025"),
            (validate_tier_2, "2025"),
            (validate_amhcc, "2025"),
        ]:
            result = validator(empty, year)
            assert result.is_valid, f"{validator.__name__} failed on empty series"
            assert result.errors == []

    @pytest.mark.parametrize(
        "validator,codes",
        [
            (validate_ar_drg, ["A01A", "bad", "", "B02B", None]),
            (validate_aecc, ["E0110A", "invalid", "", None]),
            (validate_udg, ["U0101", "bad", "", np.nan]),
            (validate_tier_2, ["10.10", "abc", "", None]),
            (validate_amhcc, ["1001", "bad", "", np.nan]),
        ],
    )
    def test_mixed_valid_invalid_returns_false_with_errors(self, validator, codes):
        result = validator(pd.Series(codes), "2025")
        assert result.is_valid is False
        assert len(result.errors) >= 1

    @pytest.mark.parametrize(
        "validator,year",
        [
            (validate_ar_drg, "1999"),
            (validate_aecc, "1999"),
            (validate_udg, "1999"),
            (validate_tier_2, "1999"),
            (validate_amhcc, "1999"),
        ],
    )
    def test_year_outside_supported_range(self, validator, year):
        result = validator(pd.Series(["A01A"]), year)
        assert result.is_valid is False

    def test_numpy_nan_in_all_validators(self):
        for validator, year in [
            (validate_ar_drg, "2025"),
            (validate_aecc, "2025"),
            (validate_udg, "2025"),
            (validate_tier_2, "2025"),
            (validate_amhcc, "2025"),
        ]:
            result = validator(pd.Series([np.nan]), year)
            assert result.is_valid
            assert len(result.warnings) >= 1

    def test_none_in_all_validators(self):
        for validator, year in [
            (validate_ar_drg, "2025"),
            (validate_aecc, "2025"),
            (validate_udg, "2025"),
            (validate_tier_2, "2025"),
            (validate_amhcc, "2025"),
        ]:
            result = validator(pd.Series([None]), year)
            assert result.is_valid
            assert len(result.warnings) >= 1
