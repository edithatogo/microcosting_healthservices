from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class CommunityMHArtifact:
    """A single year's worth of community mental health calculator artifacts."""

    year: str
    pricing_status: str
    sas_templates: list[str] = field(default_factory=list)
    sas_calculators: list[str] = field(default_factory=list)
    adm_price_weights: list[str] = field(default_factory=list)
    cmty_price_weights: list[str] = field(default_factory=list)
    excel_workbooks: list[str] = field(default_factory=list)
    amhcc_admitted_prefix: str = "1"
    amhcc_community_prefix: str = "2"
    user_guide_available: bool = False


_ARCHIVE = "archive/sas"

CMTY_MH_ARTIFACTS: list[CommunityMHArtifact] = [
    CommunityMHArtifact(
        year="2021",
        pricing_status="shadow",
        sas_templates=[
            f"{_ARCHIVE}/NEP21 SAS NWAU Calculator/NWAU21_TEMPLATE_MH.sas",
        ],
        sas_calculators=[
            f"{_ARCHIVE}/NEP21 SAS NWAU Calculator/Calculators/NWAU21_CALCULATOR_MH.sas",
        ],
        adm_price_weights=[
            f"{_ARCHIVE}/NEP21 SAS NWAU Calculator/Calculators/nep21_mh_adm_price_weights.sas7bdat",
        ],
        cmty_price_weights=[
            f"{_ARCHIVE}/NEP21 SAS NWAU Calculator/Calculators/nep21_mh_cmty_price_weights.sas7bdat",
        ],
    ),
    CommunityMHArtifact(
        year="2022",
        pricing_status="shadow",
        sas_templates=[
            f"{_ARCHIVE}/NEP22 SAS NWAU Calculator/NWAU22_TEMPLATE_MH.sas",
        ],
        sas_calculators=[
            f"{_ARCHIVE}/NEP22 SAS NWAU Calculator/calculators/NWAU22_CALCULATOR_MH.sas",
        ],
        adm_price_weights=[
            f"{_ARCHIVE}/NEP22 SAS NWAU Calculator/calculators/nep22_mh_adm_price_weights.sas7bdat",
        ],
        cmty_price_weights=[
            f"{_ARCHIVE}/NEP22 SAS NWAU Calculator/calculators/nep22_mh_cmty_price_weights.sas7bdat",
        ],
        excel_workbooks=[
            "archive/ihacpa/raw/2022/excel/nwau22_calculator_-_community_mental_health_care_services_amhcc_shadow.xlsb",
        ],
    ),
    CommunityMHArtifact(
        year="2023",
        pricing_status="shadow",
        sas_templates=[
            f"{_ARCHIVE}/NEP23_SAS_NWAU_calculator/NWAU23_TEMPLATE_MH.sas",
        ],
        sas_calculators=[
            f"{_ARCHIVE}/NEP23_SAS_NWAU_calculator/calculators/NWAU23_CALCULATOR_MH.sas",
        ],
        adm_price_weights=[
            f"{_ARCHIVE}/NEP23_SAS_NWAU_calculator/calculators/nep23_mh_adm_price_weights.sas7bdat",
        ],
        cmty_price_weights=[
            f"{_ARCHIVE}/NEP23_SAS_NWAU_calculator/calculators/nep23_mh_cmty_price_weights.sas7bdat",
        ],
    ),
    CommunityMHArtifact(
        year="2024",
        pricing_status="shadow",
        sas_templates=[
            f"{_ARCHIVE}/NWAU24_SAS_Calculator/NWAU24_TEMPLATE_MH.sas",
        ],
        sas_calculators=[
            f"{_ARCHIVE}/NWAU24_SAS_Calculator/calculators/NWAU24_CALCULATOR_MH.sas",
        ],
        adm_price_weights=[
            f"{_ARCHIVE}/NWAU24_SAS_Calculator/calculators/nep24_mh_adm_price_weights.sas7bdat",
        ],
        cmty_price_weights=[
            f"{_ARCHIVE}/NWAU24_SAS_Calculator/calculators/nep24_mh_cmty_price_weights.sas7bdat",
        ],
    ),
    CommunityMHArtifact(
        year="2025",
        pricing_status="active",
        sas_templates=[
            f"{_ARCHIVE}/NEP25_SAS_NWAU_calculator/NWAU25_TEMPLATE_MH.sas",
        ],
        sas_calculators=[
            f"{_ARCHIVE}/NEP25_SAS_NWAU_calculator/calculators/NWAU25_CALCULATOR_MH.sas",
        ],
        adm_price_weights=[
            f"{_ARCHIVE}/NEP25_SAS_NWAU_calculator/calculators/nep25_mh_adm_price_weights.sas7bdat",
        ],
        cmty_price_weights=[
            f"{_ARCHIVE}/NEP25_SAS_NWAU_calculator/calculators/nep25_mh_cmty_price_weights.sas7bdat",
        ],
    ),
]


def get_inventory_by_year(year: str) -> CommunityMHArtifact | None:
    """Return the artifact record for a given pricing year (e.g. ``"2025"``)."""
    for artifact in CMTY_MH_ARTIFACTS:
        if artifact.year == year:
            return artifact
    return None


def get_active_years() -> list[str]:
    """Return list of years where community MH is actively priced."""
    return [a.year for a in CMTY_MH_ARTIFACTS if a.pricing_status == "active"]


def get_shadow_years() -> list[str]:
    """Return list of years where community MH is in shadow-pricing mode."""
    return [a.year for a in CMTY_MH_ARTIFACTS if a.pricing_status == "shadow"]