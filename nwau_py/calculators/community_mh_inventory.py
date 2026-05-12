from __future__ import annotations

from dataclasses import dataclass, field
from typing import Final


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


_ARCHIVE: Final[str] = "archive/sas"


def _y(
    year: str,
    status: str,
    template_dir: str,
    calc_dir: str,
    suf: str | None = None,
    excel: str = "",
) -> CommunityMHArtifact:
    """Build a single year's artifact entry.

    Args:
        year: Four-digit pricing year label.
        status: Pricing status for the year.
        template_dir: Archived directory containing the SAS template.
        calc_dir: Archived directory containing the SAS calculator and tables.
        suf: Optional two-digit suffix used in artifact filenames.
        excel: Optional workbook path for supporting Excel artifacts.

    Returns:
        A fully-populated community mental health artifact record.
    """
    suffix = suf or year[-2:]
    return CommunityMHArtifact(
        year=year,
        pricing_status=status,
        sas_templates=[f"{_ARCHIVE}/{template_dir}/NWAU{suffix}_TEMPLATE_MH.sas"],
        sas_calculators=[f"{_ARCHIVE}/{calc_dir}/NWAU{suffix}_CALCULATOR_MH.sas"],
        adm_price_weights=[
            f"{_ARCHIVE}/{calc_dir}/nep{suffix}_mh_adm_price_weights.sas7bdat"
        ],
        cmty_price_weights=[
            f"{_ARCHIVE}/{calc_dir}/nep{suffix}_mh_cmty_price_weights.sas7bdat"
        ],
        excel_workbooks=[excel] if excel else [],
    )


CMTY_MH_ARTIFACTS: list[CommunityMHArtifact] = [
    _y(
        "2021",
        "shadow",
        "NEP21 SAS NWAU Calculator",
        "NEP21 SAS NWAU Calculator/Calculators",
    ),
    _y(
        "2022",
        "shadow",
        "NEP22 SAS NWAU Calculator",
        "NEP22 SAS NWAU Calculator/calculators",
        excel=(
            "archive/ihacpa/raw/2022/excel/"
            "nwau22_calculator_-_community_mental_health_care_services_amhcc_shadow.xlsb"
        ),
    ),
    _y(
        "2023",
        "shadow",
        "NEP23_SAS_NWAU_calculator",
        "NEP23_SAS_NWAU_calculator/calculators",
    ),
    _y(
        "2024",
        "shadow",
        "NWAU24_SAS_Calculator",
        "NWAU24_SAS_Calculator/calculators",
    ),
    _y(
        "2025",
        "active",
        "NEP25_SAS_NWAU_calculator",
        "NEP25_SAS_NWAU_calculator/calculators",
    ),
    CommunityMHArtifact(
        year="2026",
        pricing_status="shadow",
        excel_workbooks=[
            "archive/ihacpa/raw/2026/excel/"
            "nwau26_calculator_for_mental_health_activity_community.xlsb"
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
