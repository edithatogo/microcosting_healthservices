"""Tests for the IHACPA classification version matrix."""

from __future__ import annotations

from nwau_py.classification_matrix import (
    AECC_VERSIONS,
    AMHCC_VERSIONS,
    AN_SNAP_VERSIONS,
    AR_DRG_VERSIONS,
    CLASSIFICATION_SYSTEMS,
    LICENSED_CLASSIFICATIONS,
    TIER_2_VERSIONS,
    UDG_VERSIONS,
    get_classification_name,
    get_classification_version,
    get_supported_years,
    get_transition_years,
    is_classification_licensed,
)


def test_classification_systems_has_expected_keys():
    assert set(CLASSIFICATION_SYSTEMS) == {
        "ar_drg",
        "aecc",
        "udg",
        "tier_2",
        "amhcc",
        "an_snap",
    }


def test_ar_drg_versions_has_expected_keys():
    assert set(AR_DRG_VERSIONS) == set(str(y) for y in range(2013, 2026))


def test_aecc_versions_has_expected_keys():
    assert set(AECC_VERSIONS) == set(str(y) for y in range(2013, 2026))


def test_udg_versions_has_expected_keys():
    assert set(UDG_VERSIONS) == set(str(y) for y in range(2013, 2026))


def test_tier_2_versions_has_expected_keys():
    assert set(TIER_2_VERSIONS) == set(str(y) for y in range(2013, 2026))


def test_amhcc_versions_has_expected_keys():
    assert set(AMHCC_VERSIONS) == set(str(y) for y in range(2013, 2026))


def test_an_snap_versions_has_expected_keys():
    assert set(AN_SNAP_VERSIONS) == set(str(y) for y in range(2013, 2026))


def test_get_classification_version_ar_drg_2025():
    assert get_classification_version("2025", "ar_drg") == "v11.0"


def test_get_classification_version_aecc_2020():
    assert get_classification_version("2020", "aecc") == "v1.0_shadow"


def test_get_classification_version_aecc_2013():
    assert get_classification_version("2013", "aecc") is None


def test_get_classification_version_udg_2021():
    assert get_classification_version("2021", "udg") == "UDG_v1.3"


def test_get_classification_version_tier_2_2022():
    assert get_classification_version("2022", "tier_2") == "v7"


def test_get_classification_version_tier_2_2021():
    assert get_classification_version("2021", "tier_2") is None


def test_get_classification_version_amhcc_2025():
    assert get_classification_version("2025", "amhcc") == "v1"


def test_get_classification_version_an_snap_2022():
    assert get_classification_version("2022", "an_snap") == "v4.01"


def test_get_supported_years_returns_non_empty():
    for system in CLASSIFICATION_SYSTEMS:
        years = get_supported_years(system)
        assert len(years) > 0, f"no supported years for {system}"


def test_get_supported_years_ar_drg_all():
    years = get_supported_years("ar_drg")
    assert years == [str(y) for y in range(2013, 2026)]


def test_get_supported_years_aecc_excludes_none():
    years = get_supported_years("aecc")
    assert "2013" not in years
    assert "2020" in years
    assert "2025" in years


def test_get_supported_years_unknown_system():
    assert get_supported_years("nonexistent") == []


def test_get_classification_version_unknown_system():
    assert get_classification_version("2025", "nonexistent") is None


def test_get_classification_version_unknown_year():
    assert get_classification_version("1999", "ar_drg") is None


def test_all_classifications_are_licensed():
    for system in CLASSIFICATION_SYSTEMS:
        assert is_classification_licensed(system), f"{system} is not licensed"


def test_is_classification_licensed_unknown():
    assert not is_classification_licensed("nonexistent")


def test_get_classification_name():
    assert get_classification_name("ar_drg") == "AR-DRG"
    assert get_classification_name("aecc") == "AECC"
    assert get_classification_name("an_snap") == "AN-SNAP"


def test_get_classification_name_unknown():
    assert get_classification_name("unknown") == "unknown"


def test_transition_years_ar_drg():
    transitions = get_transition_years("ar_drg")
    assert "2016" in transitions  # v7.0 -> v8.0
    assert "2018" in transitions  # v8.0 -> v9.0
    assert "2020" in transitions  # v9.0 -> v10.0
    assert "2021" not in transitions  # no change
    assert "2022" not in transitions  # no change
    assert "2023" in transitions  # v10.0 -> v11.0


def test_transition_years_aecc():
    transitions = get_transition_years("aecc")
    assert "2020" in transitions  # None -> v1.0_shadow
    assert "2021" in transitions  # v1.0_shadow -> v1.0
    assert "2022" in transitions  # v1.0 -> v1.1


def test_transition_years_udg():
    transitions = get_transition_years("udg")
    assert "2021" in transitions  # URG_v1.4 -> UDG_v1.3


def test_all_licensed_classifications_match():
    assert frozenset(CLASSIFICATION_SYSTEMS) == LICENSED_CLASSIFICATIONS
