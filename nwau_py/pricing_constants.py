from __future__ import annotations

__all__ = [
    "NEC_BY_YEAR",
    "NEP_BY_YEAR",
    "PRICING_CONSTANTS_SCHEMA_VERSION",
    "get_nec",
    "get_nep",
    "get_supported_pricing_years",
]

PRICING_CONSTANTS_SCHEMA_VERSION = "1.0"

# NEP (National Efficient Price) per NWAU by pricing year
# Sources: IHACPA National Efficient Price Determinations
NEP_BY_YEAR: dict[str, int] = {
    "2025": 7434,
    "2026": 7418,
}

# NEC (National Efficient Cost) by pricing year
# Sources: IHACPA National Efficient Cost Determinations
NEC_BY_YEAR: dict[str, int] = {
    "2025": 0,  # NEC not yet determined for 2025
    "2026": 0,  # NEC not yet determined for 2026
}


def get_nep(year: str) -> int | None:
    """Return the NEP (National Efficient Price) for a given pricing year.

    Parameters
    ----------
    year:
        Four-digit pricing year (e.g. ``"2026"``).

    Returns
    -------
    int | None
        The NEP value, or ``None`` if not available.
    """
    return NEP_BY_YEAR.get(year)


def get_nec(year: str) -> int | None:
    """Return the NEC (National Efficient Cost) for a given pricing year."""
    return NEC_BY_YEAR.get(year)


def get_supported_pricing_years() -> list[str]:
    """Return sorted list of pricing years with NEP constants."""
    return sorted(NEP_BY_YEAR)
