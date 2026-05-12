from __future__ import annotations

import re
from dataclasses import dataclass, field

import numpy as np
import pandas as pd

from nwau_py.classification_matrix import (
    AECC_VERSIONS,
    AMHCC_VERSIONS,
    AR_DRG_VERSIONS,
    TIER_2_VERSIONS,
    UDG_VERSIONS,
)

__all__ = [
    "ClassificationValidationResult",
    "validate_aecc",
    "validate_amhcc",
    "validate_ar_drg",
    "validate_classification_input",
    "validate_tier_2",
    "validate_udg",
]

_DRG_RE = re.compile(r"^[A-Za-z]\d{2}[A-Za-z]$")
_AECC_RE = re.compile(r"^[Ee]\d{4}[A-Za-z]$")
_UDG_RE = re.compile(r"^[A-Za-z]\d{4}$")
_TIER2_RE = re.compile(r"^\d{2}\.\d{2}$")
_AMHCC_RE = re.compile(r"^[12]\d{3}$")
_URG_RE = re.compile(r"^[Rr]\d{4}$")


@dataclass
class ClassificationValidationResult:
    is_valid: bool = True
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


def _latest_version(versions: dict[str, str | None]) -> str | None:
    latest_year = sorted(versions)[-1]
    return versions[latest_year]


def _make_result(
    is_valid: bool,
    errors: list[str],
    warnings: list[str],
) -> ClassificationValidationResult:
    return ClassificationValidationResult(
        is_valid=is_valid, errors=errors, warnings=warnings
    )


def _validate_codes(
    codes: pd.Series,
    pattern: re.Pattern,
    year: str,
    versions: dict,
    *,
    none_version_error: bool = False,
    format_name: str = "code",
    check_urg: bool = False,
) -> ClassificationValidationResult:
    errors: list[str] = []
    warnings: list[str] = []

    if year not in versions:
        errors.append(f"Unsupported year: {year}")
        return _make_result(False, errors, warnings)

    year_version = versions[year]

    if year_version is None and none_version_error:
        errors.append(f"{format_name} is not available for pricing year {year}")
        return _make_result(False, errors, warnings)

    if year_version is not None and "shadow" in year_version:
        warnings.append(f"{year} is a shadow pricing year for {format_name}")

    if year_version is not None:
        latest = _latest_version(versions)
        if latest is not None and year_version != latest:
            warnings.append(
                f"{format_name} version {year_version} for year {year} "
                f"is not the latest version ({latest})"
            )

    if codes.empty:
        return _make_result(True, [], warnings)

    for i, val in enumerate(codes):
        if pd.isna(val):
            warnings.append(
                f"Row {i}: missing {format_name} value (will be skipped)"
            )
            continue

        if not isinstance(val, (str, np.floating, float, int)):
            errors.append(
                f"Row {i}: unexpected type '{type(val).__name__}' for {format_name}"
            )
            continue

        code_str = str(val).strip()
        if isinstance(val, (np.floating, float)):
            code_str = (
                f"{val:.2f}" if val != int(val) else str(int(val))
            )

        if not code_str:
            errors.append(f"Row {i}: empty {format_name} value")
            continue

        if not pattern.fullmatch(code_str):
            errors.append(
                f"Row {i}: invalid {format_name} format: '{code_str}'"
            )
            continue

        if check_urg and _URG_RE.fullmatch(code_str) and int(year) >= 2021:
            warnings.append(
                f"Row {i}: URG format ('{code_str}') used with year {year} "
                f"(URG was replaced by UDG from 2021)"
            )

    is_valid = len(errors) == 0
    return _make_result(is_valid, errors, warnings)


def validate_ar_drg(
    drg_codes: pd.Series, year: str
) -> ClassificationValidationResult:
    return _validate_codes(
        drg_codes, _DRG_RE, year, AR_DRG_VERSIONS, format_name="AR-DRG",
    )


def validate_aecc(
    aecc_codes: pd.Series, year: str
) -> ClassificationValidationResult:
    return _validate_codes(
        aecc_codes, _AECC_RE, year, AECC_VERSIONS,
        none_version_error=True, format_name="AECC",
    )


def validate_udg(
    udg_codes: pd.Series, year: str
) -> ClassificationValidationResult:
    return _validate_codes(
        udg_codes, _UDG_RE, year, UDG_VERSIONS,
        format_name="UDG", check_urg=True,
    )


def validate_tier_2(
    tier2_codes: pd.Series, year: str
) -> ClassificationValidationResult:
    return _validate_codes(
        tier2_codes, _TIER2_RE, year, TIER_2_VERSIONS,
        format_name="Tier 2",
    )


def validate_amhcc(
    amhcc_codes: pd.Series, year: str
) -> ClassificationValidationResult:
    errors: list[str] = []
    warnings: list[str] = []

    if year not in AMHCC_VERSIONS:
        errors.append(f"Unsupported year: {year}")
        return _make_result(False, errors, warnings)

    year_version = AMHCC_VERSIONS[year]

    if year_version is None:
        msg = (
            f"AMHCC is not available for pricing year {year}: "
            f"no MH calculator for this year"
        )
        errors.append(msg)
        return _make_result(False, errors, warnings)

    latest = _latest_version(AMHCC_VERSIONS)
    if latest is not None and year_version != latest:
        warnings.append(
            f"AMHCC version {year_version} for year {year} "
            f"is not the latest version ({latest})"
        )

    if amhcc_codes.empty:
        return _make_result(True, [], warnings)

    for i, val in enumerate(amhcc_codes):
        if pd.isna(val):
            warnings.append(
                f"Row {i}: missing AMHCC value (will be skipped)"
            )
            continue

        if not isinstance(val, (str, np.floating, float, int)):
            errors.append(
                f"Row {i}: unexpected type '{type(val).__name__}' for AMHCC"
            )
            continue

        code_str = str(val).strip()
        if isinstance(val, (np.floating, float)):
            code_str = str(int(val))

        if not code_str:
            errors.append(f"Row {i}: empty AMHCC value")
            continue

        if not _AMHCC_RE.fullmatch(code_str):
            errors.append(
                f"Row {i}: invalid AMHCC format: '{code_str}'"
            )
            continue

    is_valid = len(errors) == 0
    return _make_result(is_valid, errors, warnings)


_STREAM_MAP: dict[str, tuple[str, str]] = {
    "acute": ("DRG", "ar_drg"),
    "ed": ("AECC", "aecc"),
    "outpatients": ("TIER2_CLINIC", "tier_2"),
    "mh": ("AMHCC", "amhcc"),
    "community_mh": ("AMHCC", "amhcc"),
}

_VALIDATOR_MAP = {
    "ar_drg": validate_ar_drg,
    "aecc": validate_aecc,
    "tier_2": validate_tier_2,
    "amhcc": validate_amhcc,
}


def validate_classification_input(
    df: pd.DataFrame,
    stream: str,
    year: str,
) -> ClassificationValidationResult:
    stream_key = stream.lower()
    if stream_key not in _STREAM_MAP:
        raise ValueError(
            f"Unknown stream: '{stream}'. Expected one of: {list(_STREAM_MAP)}"
        )

    column, system = _STREAM_MAP[stream_key]

    if column not in df.columns:
        raise ValueError(
            f"DataFrame is missing required column '{column}' for stream "
            f"'{stream}'"
        )

    validator = _VALIDATOR_MAP[system]
    return validator(df[column], year)
