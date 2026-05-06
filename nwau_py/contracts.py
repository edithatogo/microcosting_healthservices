"""Strict calculator boundary contracts for adapters and orchestration.

The models in this module stay deliberately narrow:

- They validate calculator identifiers and pricing-year labels using the
  repository's existing edition naming convention.
- They record schema metadata and required columns without depending on pandas
  or any calculator implementation.
- They expose small helpers that adapter layers can use before handing data to
  a specific runtime or backend.
"""

from __future__ import annotations

import re
from collections.abc import Iterable
from typing import Any, ClassVar, cast

from pydantic import BaseModel, ConfigDict, field_validator

__all__ = [
    "CALCULATOR_IDENTIFIERS",
    "ContractValidationError",
    "CalculatorContract",
    "PricingYear",
    "validate_required_input_columns",
    "validate_required_output_columns",
]

CALCULATOR_IDENTIFIERS: frozenset[str] = frozenset(
    {
        "acute",
        "adjust",
        "ed",
        "mh",
        "outpatients",
        "subacute",
    }
)
_PRICING_YEAR_RE = re.compile(r"^(?:201[3-9]|202[0-6])$")
_SCHEMA_VERSION_RE = re.compile(r"^\d+(?:\.\d+)*$")


class ContractValidationError(ValueError):
    """Raised when a calculator contract or column boundary is invalid."""


def _normalize_columns(columns: Iterable[str], *, field: str) -> tuple[str, ...]:
    if isinstance(columns, (str, bytes)):
        raise ContractValidationError(f"{field} must be an iterable of column names")

    normalized: list[str] = []
    seen: set[str] = set()
    for column in columns:
        if not isinstance(column, str):
            raise ContractValidationError(f"{field} must contain only strings")
        name = column.strip()
        if not name:
            raise ContractValidationError(f"{field} must not contain blank names")
        if name in seen:
            raise ContractValidationError(f"{field} must not contain duplicate names")
        seen.add(name)
        normalized.append(name)
    if not normalized:
        raise ContractValidationError(f"{field} must not be empty")
    return tuple(normalized)


def _missing_required_columns(
    actual_columns: Iterable[str],
    required_columns: Iterable[str],
    *,
    field: str,
) -> tuple[str, ...]:
    actual = _normalize_columns(actual_columns, field=f"{field}.actual_columns")
    required = _normalize_columns(required_columns, field=f"{field}.required_columns")
    actual_set = set(actual)
    return tuple(column for column in required if column not in actual_set)


def validate_required_input_columns(
    actual_columns: Iterable[str],
    required_columns: Iterable[str],
) -> None:
    """Raise when required input columns are missing."""

    missing = _missing_required_columns(
        actual_columns,
        required_columns,
        field="input_columns",
    )
    if missing:
        raise ContractValidationError(
            "missing required input columns: " + ", ".join(missing)
        )


def validate_required_output_columns(
    actual_columns: Iterable[str],
    required_columns: Iterable[str],
) -> None:
    """Raise when required output columns are missing."""

    missing = _missing_required_columns(
        actual_columns,
        required_columns,
        field="output_columns",
    )
    if missing:
        raise ContractValidationError(
            "missing required output columns: " + ", ".join(missing)
        )


class PricingYear(BaseModel):
    """Validated IHACPA pricing-year label."""

    model_config = ConfigDict(extra="forbid", frozen=True)

    year: str

    @field_validator("year")
    @classmethod
    def _validate_year(cls, value: str) -> str:
        if not _PRICING_YEAR_RE.fullmatch(value):
            raise ValueError(
                "pricing year must be a supported four-digit label "
                "between 2013 and 2026"
            )
        return value

    @property
    def as_int(self) -> int:
        """Return the pricing year as an integer."""

        return int(self.year)

    @property
    def suffix(self) -> str:
        """Return the two-digit edition suffix used by archive paths."""

        return self.year[-2:]


class CalculatorContract(BaseModel):
    """Strict boundary contract for a calculator adapter."""

    model_config = ConfigDict(extra="forbid", frozen=True)

    supported_calculators: ClassVar[frozenset[str]] = CALCULATOR_IDENTIFIERS

    schema_version: str = "1.0"
    calculator_id: str
    pricing_year: PricingYear
    input_schema_version: str = "1.0"
    output_schema_version: str = "1.0"
    required_input_columns: tuple[str, ...]
    required_output_columns: tuple[str, ...]

    @field_validator("schema_version", "input_schema_version", "output_schema_version")
    @classmethod
    def _validate_schema_version(cls, value: str) -> str:
        if not _SCHEMA_VERSION_RE.fullmatch(value):
            raise ValueError("schema version must be a dotted numeric label")
        return value

    @field_validator("calculator_id")
    @classmethod
    def _validate_calculator_id(cls, value: str) -> str:
        if value not in CALCULATOR_IDENTIFIERS:
            raise ValueError(
                f"calculator_id must be one of {sorted(CALCULATOR_IDENTIFIERS)}"
            )
        return value

    @field_validator(
        "required_input_columns",
        "required_output_columns",
        mode="before",
    )
    @classmethod
    def _validate_columns(
        cls,
        value: Any,
    ) -> tuple[str, ...]:
        if value is None:
            raise ValueError("columns must not be empty")
        if isinstance(value, (str, bytes)):
            raise ValueError("columns must be an iterable of column names")
        return _normalize_columns(cast(Iterable[str], value), field="columns")

    def validate_input_columns(self, actual_columns: Iterable[str]) -> None:
        """Validate adapter input columns against the contract."""

        validate_required_input_columns(actual_columns, self.required_input_columns)

    def validate_output_columns(self, actual_columns: Iterable[str]) -> None:
        """Validate adapter output columns against the contract."""

        validate_required_output_columns(actual_columns, self.required_output_columns)

    def missing_input_columns(self, actual_columns: Iterable[str]) -> tuple[str, ...]:
        """Return the required input columns that are missing."""

        return _missing_required_columns(
            actual_columns,
            self.required_input_columns,
            field="input_columns",
        )

    def missing_output_columns(self, actual_columns: Iterable[str]) -> tuple[str, ...]:
        """Return the required output columns that are missing."""

        return _missing_required_columns(
            actual_columns,
            self.required_output_columns,
            field="output_columns",
        )
