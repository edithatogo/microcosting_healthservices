"""Tools for reproducing IHACPA National Weighted Activity Units.

Keep the package import light so utility modules such as provenance helpers can
be imported without pulling in optional scoring dependencies.
"""

from __future__ import annotations

from importlib import import_module

__all__ = [
    "ClassificationRequirement",
    "ClassificationValidationError",
    "ClassificationValidationResult",
    "build_classification_requirement",
    "classification_validation",
    "get_classification_name",
    "get_classification_requirement",
    "get_classification_version",
    "get_expected_classification_version",
    "get_required_classification_fields",
    "get_supported_classification_years",
    "get_transition_years",
    "is_classification_licensed",
    "normalize_classification_system",
    "score_readmission",
    "validate_aecc_input",
    "validate_amhcc_input",
    "validate_ar_drg_input",
    "validate_classification_input",
    "validate_classification_version",
    "validate_required_classification_fields",
    "validate_tier_2_input",
    "validate_udg_input",
]

_LAZY_ATTRS = {
    "score_readmission": (".scoring", "score_readmission"),
    "classification_validation": (".classification_validation", None),
    "ClassificationRequirement": (
        ".classification_validation",
        "ClassificationRequirement",
    ),
    "ClassificationValidationError": (
        ".classification_validation",
        "ClassificationValidationError",
    ),
    "ClassificationValidationResult": (
        ".classification_validation",
        "ClassificationValidationResult",
    ),
    "build_classification_requirement": (
        ".classification_validation",
        "build_classification_requirement",
    ),
    "get_classification_name": (
        ".classification_validation",
        "get_classification_name",
    ),
    "get_classification_version": (
        ".classification_validation",
        "get_classification_version",
    ),
    "get_classification_requirement": (
        ".classification_validation",
        "get_classification_requirement",
    ),
    "get_expected_classification_version": (
        ".classification_validation",
        "get_expected_classification_version",
    ),
    "get_required_classification_fields": (
        ".classification_validation",
        "get_required_classification_fields",
    ),
    "get_supported_classification_years": (
        ".classification_validation",
        "get_supported_classification_years",
    ),
    "get_transition_years": (".classification_validation", "get_transition_years"),
    "is_classification_licensed": (
        ".classification_validation",
        "is_classification_licensed",
    ),
    "normalize_classification_system": (
        ".classification_validation",
        "normalize_classification_system",
    ),
    "validate_aecc_input": (".classification_validation", "validate_aecc_input"),
    "validate_amhcc_input": (".classification_validation", "validate_amhcc_input"),
    "validate_ar_drg_input": (".classification_validation", "validate_ar_drg_input"),
    "validate_classification_input": (
        ".classification_validation",
        "validate_classification_input",
    ),
    "validate_classification_version": (
        ".classification_validation",
        "validate_classification_version",
    ),
    "validate_required_classification_fields": (
        ".classification_validation",
        "validate_required_classification_fields",
    ),
    "validate_tier_2_input": (".classification_validation", "validate_tier_2_input"),
    "validate_udg_input": (".classification_validation", "validate_udg_input"),
}


def __getattr__(name: str):
    """Lazily expose heavyweight public symbols on demand."""
    target = _LAZY_ATTRS.get(name)
    if target is not None:
        module_name, attr_name = target
        module = import_module(module_name, __name__)
        return module if attr_name is None else getattr(module, attr_name)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
