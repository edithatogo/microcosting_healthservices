"""Tools for reproducing IHACPA National Weighted Activity Units.

Keep the package import light so utility modules such as provenance helpers can
be imported without pulling in optional scoring dependencies.
"""

from __future__ import annotations

from importlib import import_module

__all__ = [
    "NEC26",
    "NEC26_SOURCE",
    "NEC_BY_YEAR",
    "NEP26",
    "NEP26_SOURCE",
    "NEP_BY_YEAR",
    "ARDRGMappingAssetReference",
    "ARDRGMappingCompatibilityResult",
    "ARDRGMappingRecord",
    "ARDRGMappingRegistryError",
    "ARDRGParityFixtureCompatibilityResult",
    "ARDRGParityFixtureError",
    "ARDRGParityFixtureRecord",
    "ClassificationRequirement",
    "ClassificationValidationError",
    "ClassificationValidationResult",
    "CodingSetCompatibilityResult",
    "CodingSetFamily",
    "CodingSetPolicy",
    "CodingSetRegistryError",
    "CodingSetVersion",
    "LicensedProductAssetReference",
    "LicensedProductCompatibilityResult",
    "LicensedProductManifestRecord",
    "LicensedProductWorkflowError",
    "ar_drg_mapping_registry",
    "ar_drg_version_parity_fixtures",
    "build_ar_drg_parity_fixture_reference",
    "build_classification_requirement",
    "build_licensed_product_asset_reference",
    "build_licensed_product_manifest_record",
    "classification_validation",
    "coding_set_registry",
    "diagnose_missing_licensed_assets",
    "ensure_ar_drg_mapping_compatibility",
    "ensure_ar_drg_parity_fixture_scope",
    "ensure_coding_set_compatibility",
    "ensure_commit_safe_exclusion",
    "ensure_licensed_product_compatibility",
    "formula_parameter_bundle",
    "get_ar_drg_mapping_record",
    "get_ar_drg_parity_fixture_record",
    "get_classification_name",
    "get_classification_requirement",
    "get_classification_version",
    "get_coding_set_family",
    "get_coding_set_policy",
    "get_coding_set_restriction",
    "get_coding_set_version",
    "get_expected_ar_drg_version",
    "get_expected_classification_version",
    "get_expected_coding_set_version",
    "get_expected_coding_set_versions",
    "get_licensed_product_manifest_record",
    "get_nec",
    "get_nep",
    "get_required_classification_fields",
    "get_supported_classification_years",
    "get_supported_coding_set_years",
    "get_supported_pricing_years",
    "get_transition_years",
    "is_classification_licensed",
    "is_coding_set_licensed",
    "is_coding_set_restricted",
    "is_commit_safe_excluded_path",
    "is_local_only_licensed_path",
    "licensed_product_workflow",
    "list_ar_drg_mapping_records",
    "list_ar_drg_parity_fixture_records",
    "list_coding_set_families",
    "list_licensed_product_manifest_records",
    "normalize_classification_system",
    "register_ar_drg_local_licensed_parity_fixture_reference",
    "register_ar_drg_synthetic_parity_fixture",
    "resolve_licensed_product_env_path",
    "score_readmission",
    "validate_aecc_input",
    "validate_amhcc_input",
    "validate_ar_drg_input",
    "validate_ar_drg_mapping_compatibility",
    "validate_ar_drg_parity_fixture_scope",
    "validate_ar_drg_version_binding",
    "validate_classification_input",
    "validate_classification_version",
    "validate_coding_set_compatibility",
    "validate_licensed_product_compatibility",
    "validate_required_classification_fields",
    "validate_tier_2_input",
    "validate_udg_input",
]

_LAZY_ATTRS = {
    "score_readmission": (".scoring", "score_readmission"),
    "formula_parameter_bundle": (".formula_parameter_bundle", None),
    "get_nec": (".pricing_constants", "get_nec"),
    "get_nep": (".pricing_constants", "get_nep"),
    "get_supported_pricing_years": (
        ".pricing_constants",
        "get_supported_pricing_years",
    ),
    "NEC26": (".pricing_constants", "NEC26"),
    "NEC26_SOURCE": (".pricing_constants", "NEC26_SOURCE"),
    "NEC_BY_YEAR": (".pricing_constants", "NEC_BY_YEAR"),
    "NEP26": (".pricing_constants", "NEP26"),
    "NEP26_SOURCE": (".pricing_constants", "NEP26_SOURCE"),
    "NEP_BY_YEAR": (".pricing_constants", "NEP_BY_YEAR"),
    "coding_set_registry": (".coding_set_registry", None),
    "ar_drg_mapping_registry": (".ar_drg_mapping_registry", None),
    "ar_drg_version_parity_fixtures": (".ar_drg_version_parity_fixtures", None),
    "CodingSetCompatibilityResult": (
        ".coding_set_registry",
        "CodingSetCompatibilityResult",
    ),
    "CodingSetFamily": (".coding_set_registry", "CodingSetFamily"),
    "CodingSetPolicy": (".coding_set_registry", "CodingSetPolicy"),
    "CodingSetRegistryError": (".coding_set_registry", "CodingSetRegistryError"),
    "CodingSetVersion": (".coding_set_registry", "CodingSetVersion"),
    "ARDRGMappingAssetReference": (
        ".ar_drg_mapping_registry",
        "ARDRGMappingAssetReference",
    ),
    "ARDRGMappingCompatibilityResult": (
        ".ar_drg_mapping_registry",
        "ARDRGMappingCompatibilityResult",
    ),
    "ARDRGMappingRecord": (".ar_drg_mapping_registry", "ARDRGMappingRecord"),
    "ARDRGMappingRegistryError": (
        ".ar_drg_mapping_registry",
        "ARDRGMappingRegistryError",
    ),
    "ARDRGParityFixtureCompatibilityResult": (
        ".ar_drg_version_parity_fixtures",
        "ARDRGParityFixtureCompatibilityResult",
    ),
    "ARDRGParityFixtureError": (
        ".ar_drg_version_parity_fixtures",
        "ARDRGParityFixtureError",
    ),
    "ARDRGParityFixtureRecord": (
        ".ar_drg_version_parity_fixtures",
        "ARDRGParityFixtureRecord",
    ),
    "ensure_ar_drg_mapping_compatibility": (
        ".ar_drg_mapping_registry",
        "ensure_ar_drg_mapping_compatibility",
    ),
    "build_ar_drg_parity_fixture_reference": (
        ".ar_drg_version_parity_fixtures",
        "build_ar_drg_parity_fixture_reference",
    ),
    "ensure_ar_drg_parity_fixture_scope": (
        ".ar_drg_version_parity_fixtures",
        "ensure_ar_drg_parity_fixture_scope",
    ),
    "ensure_coding_set_compatibility": (
        ".coding_set_registry",
        "ensure_coding_set_compatibility",
    ),
    "get_ar_drg_mapping_record": (
        ".ar_drg_mapping_registry",
        "get_ar_drg_mapping_record",
    ),
    "get_expected_ar_drg_version": (
        ".ar_drg_mapping_registry",
        "get_expected_ar_drg_version",
    ),
    "get_coding_set_family": (".coding_set_registry", "get_coding_set_family"),
    "get_coding_set_policy": (".coding_set_registry", "get_coding_set_policy"),
    "get_coding_set_restriction": (
        ".coding_set_registry",
        "get_coding_set_restriction",
    ),
    "get_coding_set_version": (".coding_set_registry", "get_coding_set_version"),
    "get_expected_coding_set_version": (
        ".coding_set_registry",
        "get_expected_coding_set_version",
    ),
    "get_expected_coding_set_versions": (
        ".ar_drg_mapping_registry",
        "get_expected_coding_set_versions",
    ),
    "get_ar_drg_parity_fixture_record": (
        ".ar_drg_version_parity_fixtures",
        "get_ar_drg_parity_fixture_record",
    ),
    "get_supported_coding_set_years": (
        ".coding_set_registry",
        "get_supported_coding_set_years",
    ),
    "is_coding_set_licensed": (".coding_set_registry", "is_coding_set_licensed"),
    "is_coding_set_restricted": (".coding_set_registry", "is_coding_set_restricted"),
    "list_ar_drg_mapping_records": (
        ".ar_drg_mapping_registry",
        "list_ar_drg_mapping_records",
    ),
    "list_ar_drg_parity_fixture_records": (
        ".ar_drg_version_parity_fixtures",
        "list_ar_drg_parity_fixture_records",
    ),
    "list_coding_set_families": (".coding_set_registry", "list_coding_set_families"),
    "validate_ar_drg_mapping_compatibility": (
        ".ar_drg_mapping_registry",
        "validate_ar_drg_mapping_compatibility",
    ),
    "validate_ar_drg_parity_fixture_scope": (
        ".ar_drg_version_parity_fixtures",
        "validate_ar_drg_parity_fixture_scope",
    ),
    "validate_ar_drg_version_binding": (
        ".ar_drg_mapping_registry",
        "validate_ar_drg_version_binding",
    ),
    "validate_coding_set_compatibility": (
        ".coding_set_registry",
        "validate_coding_set_compatibility",
    ),
    "classification_validation": (".classification_validation", None),
    "ClassificationRequirement": (
        ".classification_validation", "ClassificationRequirement",
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
        ".classification_validation", "get_classification_name",
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
    "licensed_product_workflow": (".licensed_product_workflow", None),
    "LicensedProductAssetReference": (
        ".licensed_product_workflow",
        "LicensedProductAssetReference",
    ),
    "LicensedProductCompatibilityResult": (
        ".licensed_product_workflow",
        "LicensedProductCompatibilityResult",
    ),
    "LicensedProductManifestRecord": (
        ".licensed_product_workflow",
        "LicensedProductManifestRecord",
    ),
    "LicensedProductWorkflowError": (
        ".licensed_product_workflow",
        "LicensedProductWorkflowError",
    ),
    "build_licensed_product_asset_reference": (
        ".licensed_product_workflow",
        "build_licensed_product_asset_reference",
    ),
    "build_licensed_product_manifest_record": (
        ".licensed_product_workflow",
        "build_licensed_product_manifest_record",
    ),
    "diagnose_missing_licensed_assets": (
        ".licensed_product_workflow",
        "diagnose_missing_licensed_assets",
    ),
    "ensure_commit_safe_exclusion": (
        ".licensed_product_workflow",
        "ensure_commit_safe_exclusion",
    ),
    "ensure_licensed_product_compatibility": (
        ".licensed_product_workflow",
        "ensure_licensed_product_compatibility",
    ),
    "get_licensed_product_manifest_record": (
        ".licensed_product_workflow",
        "get_licensed_product_manifest_record",
    ),
    "is_commit_safe_excluded_path": (
        ".licensed_product_workflow",
        "is_commit_safe_excluded_path",
    ),
    "is_local_only_licensed_path": (
        ".licensed_product_workflow",
        "is_local_only_licensed_path",
    ),
    "list_licensed_product_manifest_records": (
        ".licensed_product_workflow",
        "list_licensed_product_manifest_records",
    ),
    "resolve_licensed_product_env_path": (
        ".licensed_product_workflow",
        "resolve_licensed_product_env_path",
    ),
    "validate_licensed_product_compatibility": (
        ".licensed_product_workflow",
        "validate_licensed_product_compatibility",
    ),
    "register_ar_drg_synthetic_parity_fixture": (
        ".ar_drg_version_parity_fixtures",
        "register_ar_drg_synthetic_parity_fixture",
    ),
    "register_ar_drg_local_licensed_parity_fixture_reference": (
        ".ar_drg_version_parity_fixtures",
        "register_ar_drg_local_licensed_parity_fixture_reference",
    ),
}


def __getattr__(name: str):
    """Lazily expose heavyweight public symbols on demand."""
    target = _LAZY_ATTRS.get(name)
    if target is not None:
        module_name, attr_name = target
        module = import_module(module_name, __name__)
        return module if attr_name is None else getattr(module, attr_name)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
