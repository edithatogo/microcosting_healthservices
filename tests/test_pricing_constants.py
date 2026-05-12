from nwau_py.pricing_constants import (
    NEP_BY_YEAR,
    get_nec,
    get_nep,
    get_supported_pricing_years,
)


def test_nep26_value():
    assert NEP_BY_YEAR["2026"] == 7418
    assert get_nep("2026") == 7418


def test_nep25_value():
    assert NEP_BY_YEAR["2025"] == 7434
    assert get_nep("2025") == 7434


def test_get_nep_unknown_year():
    assert get_nep("2024") is None
    assert get_nep("1999") is None


def test_get_nec_defaults():
    """NEC defaults should be 0 until IHACPA determines values."""
    assert get_nec("2025") == 0
    assert get_nec("2026") == 0


def test_get_supported_years():
    years = get_supported_pricing_years()
    assert "2025" in years
    assert "2026" in years
    assert years == sorted(years)


def test_get_nep_returns_int():
    assert isinstance(get_nep("2026"), int)
