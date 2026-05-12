# Expert Panel Priority Map

This file maps the simulated expert-panel recommendations to Conductor tracks.
It is not an endorsement by real experts or IHACPA.

## Priority Order

| Priority | Expert-Panel Recommendation | Owning Track(s) | Status |
| --- | --- | --- | --- |
| 0 | Governance and claim control | `roadmap_portfolio_governance_backfill_20260512`, `abstraction_doctrine_enforcement_20260512`, `expert_panel_remediation_20260512` | roadmap |
| 1 | Executable contracts and schemas | `reference_data_manifest_schema_20260512`, `formula_parameter_bundle_pipeline_20260512`, `coding_set_version_registry_20260512`, `contract_schema_export_20260512` | roadmap |
| 2 | Validation gates and SAS/Excel parity | `pricing_year_validation_gates_20260512`, `cross_language_golden_tests_20260504`, `formula_parameter_bundle_pipeline_20260512` | roadmap/partial |
| 3 | Source discovery and restricted asset controls | `ihacpa_source_scanner_20260512`, `icd_achi_acs_license_workflow_20260512`, `source_archive_provenance_20260504` | roadmap/partial |
| 4 | One complete stream/year canary | `end_to_end_validated_canary_20260512`, `rust_acute_python_poc_20260510`, `polyglot_rust_core_roadmap_20260512` | roadmap/partial |
| 5 | Rust core promotion | `rust_core_architecture_20260510`, `python_rust_binding_stabilization_20260512`, `polyglot_rust_core_roadmap_20260512` | roadmap/partial |
| 6 | Classification and grouper capabilities | `ar_drg_icd_mapping_registry_20260512`, `ar_drg_grouper_integration_20260512`, `emergency_udg_aecc_transition_registry_20260512`, `emergency_code_mapping_pipeline_20260512`, `emergency_grouper_integration_20260512` | roadmap |
| 7 | Public documentation and appropriate-use material | `public_appropriate_use_docs_20260512`, `costing_study_tutorials_20260512`, `docs_release_publication_readiness_20260510` | roadmap/partial |
| 8 | Costing-study support | `cost_bucket_registry_20260512`, `nhcdc_cost_report_ingestion_20260512`, `ahpcs_costing_process_model_20260512`, `cost_bucket_analytics_tutorials_20260512` | roadmap |
| 9 | Polyglot bindings and apps | `cli_file_interop_binding_20260512`, `c_abi_binding_20260512`, `r_binding_20260512`, `julia_binding_20260512`, `csharp_dotnet_binding_20260512`, `go_binding_20260512`, `typescript_wasm_binding_20260512`, `java_jvm_binding_20260512`, `duckdb_sql_binding_20260512`, `sas_interop_binding_20260512`, `power_platform_binding_20260512` | roadmap |
| 10 | Publication expansion | `release_evidence_automation_20260512`, `release_supply_chain_governance_20260504`, `repository-publication-sota-audit template`, `conda recipe workflow`, future registry-specific tracks | partial |

## Immediate Gaps

- Binding tracks should not start implementation until contract schemas and
  conformance tests exist.
- Binding tracks should not start implementation until contract schemas and
  conformance tests exist.
- Publication expansion should not proceed for registries beyond PyPI until
  registry-specific readiness evidence exists.

## Governance Rule

When resolving conflicts between expert recommendations, use the chaired
deliberation order in
`docs/reviews/20260512-expert-panel/deliberation-and-prioritisation.md`.
