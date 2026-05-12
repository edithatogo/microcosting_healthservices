"""Calculator entry points and contract types."""

from .acute import (
    AcuteCalculationContract,
    AcuteContractError,
    AcuteInputContract,
    AcuteParams,
    AcuteReferenceBundle,
    build_acute_contract,
    calculate_acute,
    calculate_acute_rust_2025,
    validate_acute_input_frame,
)
from .adjust import calculate_adjusted_nwau
from .community_mh_calculator import (
    CommunityMHCalculator,
    CommunityMHParams,
    calculate_community_mh,
)
from .community_mh_contract import (
    COMMUNITY_MH_CONTRACT,
    CommunityMHContractError,
    build_community_mh_contract,
    validate_community_mh_input,
    validate_community_mh_output,
)
from .community_mh_inventory import (
    CMTY_MH_ARTIFACTS,
    CommunityMHArtifact,
    get_active_years,
    get_inventory_by_year,
    get_shadow_years,
)
from .ed import EDParams, calculate_ed
from .funding_formula import (
    calculate_funding,
    load_formula,
    load_weights,
)
from .mh import MHParams, calculate_mh
from .outpatients import OutpatientParams, calculate_outpatients
from .subacute import SubacuteParams, calculate_subacute

__all__ = [
    "CMTY_MH_ARTIFACTS",
    "COMMUNITY_MH_CONTRACT",
    "AcuteCalculationContract",
    "AcuteContractError",
    "AcuteInputContract",
    "AcuteParams",
    "AcuteReferenceBundle",
    "CommunityMHArtifact",
    "CommunityMHCalculator",
    "CommunityMHContractError",
    "CommunityMHParams",
    "EDParams",
    "MHParams",
    "OutpatientParams",
    "SubacuteParams",
    "build_acute_contract",
    "build_community_mh_contract",
    "calculate_acute",
    "calculate_acute_rust_2025",
    "calculate_adjusted_nwau",
    "calculate_community_mh",
    "calculate_ed",
    "calculate_funding",
    "calculate_mh",
    "calculate_outpatients",
    "calculate_subacute",
    "get_active_years",
    "get_inventory_by_year",
    "get_shadow_years",
    "load_formula",
    "load_weights",
    "validate_acute_input_frame",
    "validate_community_mh_input",
    "validate_community_mh_output",
]
