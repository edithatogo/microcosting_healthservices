from __future__ import annotations

import pandas as pd

from nwau_py.contracts import (
    CalculatorContract,
    PricingYear,
    validate_required_input_columns,
    validate_required_output_columns,
)

_COMMUNITY_MH_ID = "community_mh"

_COMMUNITY_MH_INPUT_COLUMNS: tuple[str, ...] = (
    "AMHCC",
    "SC_PAT_PUB",
    "SC_NOPAT_PUB",
    "STATE",
)


class CommunityMHContractError(ValueError):
    """Raised when a community mental health contract constraint is violated."""


def build_community_mh_contract(year: str) -> CalculatorContract:
    """Build a ``CalculatorContract`` for the community mental health stream.

    Parameters
    ----------
    year:
        Four-digit pricing year (e.g. ``"2025"``).

    Returns
    -------
    CalculatorContract
        A frozen Pydantic model describing the community mental health
        calculator boundary.
    """
    suffix = year[-2:]
    return CalculatorContract(
        calculator_id=_COMMUNITY_MH_ID,
        pricing_year=PricingYear(year=year),
        required_input_columns=_COMMUNITY_MH_INPUT_COLUMNS,
        required_output_columns=(f"NWAU{suffix}",),
    )


# Singleton contract for the current default year.
_COMMUNITY_MH_CONTRACT: CalculatorContract | None = None


def _get_contract() -> CalculatorContract:
    global _COMMUNITY_MH_CONTRACT
    if _COMMUNITY_MH_CONTRACT is None:
        _COMMUNITY_MH_CONTRACT = build_community_mh_contract("2025")
    return _COMMUNITY_MH_CONTRACT


COMMUNITY_MH_CONTRACT = _get_contract()


def validate_community_mh_input(df: pd.DataFrame) -> None:
    """Validate input columns for community mental health calculation.

    Parameters
    ----------
    df:
        Input DataFrame to validate.

    Raises
    ------
    CommunityMHContractError
        If required input columns are missing.
    """
    try:
        validate_required_input_columns(
            df.columns.tolist(),
            COMMUNITY_MH_CONTRACT.required_input_columns,
        )
    except ValueError as exc:
        raise CommunityMHContractError(str(exc)) from exc


def validate_community_mh_output(df: pd.DataFrame) -> None:
    """Validate output columns from community mental health calculation.

    Parameters
    ----------
    df:
        Output DataFrame to validate.

    Raises
    ------
    CommunityMHContractError
        If the NWAU output column is missing.
    """
    try:
        validate_required_output_columns(
            df.columns.tolist(),
            COMMUNITY_MH_CONTRACT.required_output_columns,
        )
    except ValueError as exc:
        raise CommunityMHContractError(str(exc)) from exc