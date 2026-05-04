from __future__ import annotations

import pandas as pd
import pytest

from nwau_py.contracts import (
    CalculatorContract,
    ContractValidationError,
    PricingYear,
    validate_required_input_columns,
    validate_required_output_columns,
)


def test_pricing_year_accepts_supported_years():
    assert PricingYear(year="2025").as_int == 2025
    assert PricingYear(year="2024").suffix == "24"


@pytest.mark.parametrize("year", ["2025-26", "99", "", "2030"])
def test_pricing_year_rejects_invalid_years(year):
    with pytest.raises(ValueError, match="pricing year must be a supported"):
        PricingYear(year=year)


def test_calculator_contract_validates_columns_and_identifiers():
    contract = CalculatorContract(
        calculator_id="acute",
        pricing_year=PricingYear(year="2025"),
        required_input_columns=("DRG", "LOS", "PAT_SAMEDAY_FLAG"),
        required_output_columns=("NWAU25",),
    )

    assert contract.schema_version == "1.0"
    contract.validate_input_columns(["DRG", "LOS", "PAT_SAMEDAY_FLAG", "EXTRA"])
    contract.validate_output_columns(pd.Index(["NWAU25", "EXTRA"]))


@pytest.mark.parametrize("calculator_id", ["", "bad", "acute ", "web"])
def test_calculator_contract_rejects_invalid_calculator_ids(calculator_id):
    with pytest.raises(ValueError, match="calculator_id must be one of"):
        CalculatorContract(
            calculator_id=calculator_id,
            pricing_year=PricingYear(year="2025"),
            required_input_columns=("DRG",),
            required_output_columns=("NWAU25",),
        )


@pytest.mark.parametrize(
    "columns,required,match",
    [
        (["DRG"], ["DRG", "LOS"], "missing required input columns"),
        (["NWAU25"], ["NWAU25", "EXTRA"], "missing required output columns"),
    ],
)
def test_column_validation_helpers_report_missing_columns(columns, required, match):
    validator = (
        validate_required_input_columns
        if match.startswith("missing required input")
        else validate_required_output_columns
    )

    with pytest.raises(ContractValidationError, match=match):
        validator(columns, required)


def test_calculator_contract_rejects_blank_and_duplicate_columns():
    with pytest.raises(ValueError, match="must not be empty"):
        CalculatorContract(
            calculator_id="acute",
            pricing_year=PricingYear(year="2025"),
            required_input_columns=(),
            required_output_columns=("NWAU25",),
        )

    with pytest.raises(ValueError, match="must not contain duplicate names"):
        CalculatorContract(
            calculator_id="acute",
            pricing_year=PricingYear(year="2025"),
            required_input_columns=("DRG", "DRG"),
            required_output_columns=("NWAU25",),
        )
