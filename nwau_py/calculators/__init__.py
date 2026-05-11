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
    "AcuteCalculationContract",
    "AcuteContractError",
    "AcuteInputContract",
    "AcuteParams",
    "AcuteReferenceBundle",
    "EDParams",
    "MHParams",
    "OutpatientParams",
    "SubacuteParams",
    "build_acute_contract",
    "calculate_acute",
    "calculate_acute_rust_2025",
    "calculate_adjusted_nwau",
    "calculate_ed",
    "calculate_funding",
    "calculate_mh",
    "calculate_outpatients",
    "calculate_subacute",
    "load_formula",
    "load_weights",
    "validate_acute_input_frame",
]
