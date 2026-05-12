"""Tests for the community mental health calculator artifact inventory."""

from pathlib import Path

from nwau_py.calculators.community_mh_inventory import (
    CMTY_MH_ARTIFACTS,
    get_active_years,
    get_inventory_by_year,
    get_shadow_years,
)


def test_inventory_has_all_expected_years():
    """The inventory must cover NEP21 through NEP26."""
    years = sorted(a.year for a in CMTY_MH_ARTIFACTS)
    assert years == ["2021", "2022", "2023", "2024", "2025", "2026"]


def test_inventory_sas_templates_refer_to_existing_files():
    """Every SAS template path referenced in the inventory must exist."""
    for artifact in CMTY_MH_ARTIFACTS:
        for path in artifact.sas_templates:
            assert Path(path).exists(), (
                f"SAS template not found: {path} (year={artifact.year})"
            )


def test_inventory_sas_calculators_refer_to_existing_files():
    """Every SAS calculator path referenced in the inventory must exist."""
    for artifact in CMTY_MH_ARTIFACTS:
        for path in artifact.sas_calculators:
            assert Path(path).exists(), (
                f"SAS calculator not found: {path} (year={artifact.year})"
            )


def test_inventory_cmty_price_weights_refer_to_existing_files():
    """Every community price weights table must exist on disk."""
    for artifact in CMTY_MH_ARTIFACTS:
        for path in artifact.cmty_price_weights:
            assert Path(path).exists(), (
                f"Community price weights not found: {path} (year={artifact.year})"
            )


def test_inventory_adm_price_weights_refer_to_existing_files():
    """Every admitted price weights table must exist on disk."""
    for artifact in CMTY_MH_ARTIFACTS:
        for path in artifact.adm_price_weights:
            assert Path(path).exists(), (
                f"Admitted price weights not found: {path} (year={artifact.year})"
            )


def test_nep25_active_and_nep26_shadow_pricing():
    """NEP25 is active; NEP26 remains conservatively shadow-priced."""
    nep25 = next(a for a in CMTY_MH_ARTIFACTS if a.year == "2025")
    assert nep25.pricing_status == "active"
    nep26 = next(a for a in CMTY_MH_ARTIFACTS if a.year == "2026")
    assert nep26.pricing_status == "shadow"


def test_nep26_archived_paths_match_naming():
    """NEP26 path strings must match the archived naming convention exactly."""
    nep26 = next(a for a in CMTY_MH_ARTIFACTS if a.year == "2026")
    assert nep26.sas_templates == []
    assert nep26.sas_calculators == []
    assert nep26.adm_price_weights == []
    assert nep26.cmty_price_weights == []
    assert nep26.excel_workbooks == [
        "archive/ihacpa/raw/2026/excel/"
        "nwau26_calculator_for_mental_health_activity_community.xlsb"
    ]


def test_nep21_nep24_are_shadow_pricing():
    """NEP21 through NEP24 are shadow-pricing years for community mental
    health."""
    for artifact in CMTY_MH_ARTIFACTS:
        if artifact.year in ("2021", "2022", "2023", "2024"):
            assert artifact.pricing_status == "shadow", (
                f"Expected shadow pricing for year {artifact.year}"
            )


def test_nep22_has_excel_workbook():
    """NEP22 has a dedicated AMHCC shadow Excel workbook for community mental
    health."""
    nep22 = next(a for a in CMTY_MH_ARTIFACTS if a.year == "2022")
    assert len(nep22.excel_workbooks) >= 1
    for wb in nep22.excel_workbooks:
        assert Path(wb).exists(), f"Excel workbook not found: {wb}"


def test_amhcc_prefix_convention_documented():
    """AMHCC prefix '1' = admitted, '2' = community."""
    for artifact in CMTY_MH_ARTIFACTS:
        assert artifact.amhcc_admitted_prefix == "1"
        assert artifact.amhcc_community_prefix == "2"


def test_all_artifacts_have_user_guide_field():
    """Every inventory entry must record user-guide availability (even if
    marked as unavailable)."""
    for artifact in CMTY_MH_ARTIFACTS:
        assert isinstance(artifact.user_guide_available, bool)


def test_no_mh_calculator_before_nep21():
    """NEP13 through NEP20 do not have dedicated mental health calculators."""
    assert all(int(a.year) >= 2021 for a in CMTY_MH_ARTIFACTS)
    earliest = min(int(a.year) for a in CMTY_MH_ARTIFACTS)
    assert earliest == 2021, f"Expected earliest year 2021, got {earliest}"


def test_get_inventory_by_year_found():
    """get_inventory_by_year returns the correct artifact for a known year."""
    for year in ("2025",):
        art = get_inventory_by_year(year)
        assert art is not None
        assert art.year == year
        assert art.pricing_status == "active"
    nep26 = get_inventory_by_year("2026")
    assert nep26 is not None
    assert nep26.pricing_status == "shadow"


def test_get_inventory_by_year_not_found():
    """get_inventory_by_year returns None for an unknown year."""
    assert get_inventory_by_year("2015") is None
    assert get_inventory_by_year("2099") is None


def test_get_active_years():
    """get_active_years returns only years with active pricing status."""
    active = get_active_years()
    assert "2025" in active
    assert "2026" not in active
    assert all(y not in active for y in get_shadow_years())


def test_get_shadow_years():
    """get_shadow_years returns only years with shadow pricing status."""
    shadow = get_shadow_years()
    assert "2021" in shadow
    assert "2022" in shadow
    assert "2023" in shadow
    assert "2024" in shadow
    assert "2026" in shadow
    assert all(y not in shadow for y in get_active_years())
