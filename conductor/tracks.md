# Project Tracks

This file tracks the delivery order for the project. The focused tracks below are the implementation source of truth. The modernization foundation track is retained only as an umbrella coordination track and must not duplicate work owned by the focused tracks.

New tracks must follow the governance rules in
[`roadmap-governance.md`](./roadmap-governance.md). In particular, new track
metadata should include track class, current state, dependencies, primary
contract, completion evidence, and publication status. Roadmap or scaffold
content alone is not sufficient evidence for marking a track complete.

## Delivery Order

1. [x] **Track: Source Archive and Provenance Registry**
   *Link: [./tracks/source_archive_provenance_20260504/](./tracks/source_archive_provenance_20260504/)*
   *Gate: establish source acquisition, storage policy, and manifest provenance before downstream validation or implementation work.*

2. [x] **Track: Cross-Language Golden Test Suite**
   *Link: [./tracks/cross_language_golden_tests_20260504/](./tracks/cross_language_golden_tests_20260504/)*
   *Depends on: source archive manifesting and known-good reference artifacts.*
   *Gate: define validation evidence and fixture contracts before broad tooling or architecture migrations.*

3. [x] **Track: Python Tooling and CI Modernization**
   *Link: [./tracks/python_tooling_ci_20260504/](./tracks/python_tooling_ci_20260504/)*
   *Depends on: source archive provenance and validation fixture shape.*
   *Gate: lock the supported Python/tooling matrix, CI, coverage, type checking, linting, and profiling entry points before larger refactors.*

4. [x] **Track: Calculator Core Abstraction and Validation Models**
   *Link: [./tracks/calculator_core_abstractions_20260504/](./tracks/calculator_core_abstractions_20260504/)*
   *Depends on: validation evidence and CI coverage so the boundary contract can be protected by tests.*
   *Gate: define the calculator core boundary, parameter models, schemas, and provenance metadata before adapter work.*

5. [x] **Track: Public Calculator API Contract**
   *Link: [./tracks/public_api_contract_20260504/](./tracks/public_api_contract_20260504/)*
   *Depends on: calculator core abstractions and golden fixtures.*
   *Gate: freeze the versioned input/output contract before web, C#, or Power Platform integration.*

6. [x] **Track: Arrow and Polars Data Bundle Migration**
   *Link: [./tracks/arrow_polars_data_bundle_20260504/](./tracks/arrow_polars_data_bundle_20260504/)*
   *Depends on: calculator core abstractions and stable validation fixtures.*
   *Gate: migrate data representation and DataFrame boundaries only after the core contract is stable.*

7. [x] **Track: GitHub Pages Web App Prototype**
   *Link: [./tracks/github_pages_web_app_20260504/](./tracks/github_pages_web_app_20260504/)*
   *Depends on: public API contract, validation fixtures, and governance rules for demo-only flows.*
   *Gate: implement the browser-facing prototype only after a contract and privacy boundary exist.*

8. [x] **Track: C# Calculation Engine and Power Platform Adapter**
   *Link: [./tracks/csharp_power_platform_engine_20260504/](./tracks/csharp_power_platform_engine_20260504/)*
   *Depends on: public API contract, calculator core abstractions, and golden fixtures.*
   *Gate: keep Power Platform orchestration separate from the calculation engine and drive parity from shared fixtures.*

9. [x] **Track: Release and Supply-Chain Governance**
   *Link: [./tracks/release_supply_chain_governance_20260504/](./tracks/release_supply_chain_governance_20260504/)*
   *Depends on: CI, validation evidence, and contract stability.*
   *Gate: add release policy, signed artifacts, dependency automation, and provenance controls after the implementation pipeline is stable.*

10. [x] **Track: Starlight Documentation Site and Versioning**
   *Link: [./archive/starlight_docs_site_20260506/](./archive/starlight_docs_site_20260506/)*
   *Depends on: public calculator contracts, validation vocabulary, docs governance, and GitHub Pages delivery rules.*
   *Gate: define and ship the Starlight documentation platform, its versioning model, migration path, plugin set, and deployment workflow before any docs-site decommissioning is considered.*

11. [x] **Track: Ecosystem Standards and Language Readiness**
   *Link: [./tracks/ecosystem_language_readiness_20260507/](./tracks/ecosystem_language_readiness_20260507/)*
   *Depends on: public calculator contracts, golden fixtures, release governance, Starlight documentation, and Power Platform boundary documentation.*
   *Gate: assess scientific software standards, language packaging maturity, C# and Power Platform implementation readiness, contribution pathways, and health interoperability standards before starting new language ports or integration surfaces.*

12. [x] **Track: Rust Core Architecture and Calculator Abstraction**
   *Link: [./tracks/rust_core_architecture_20260510/](./tracks/rust_core_architecture_20260510/)*
   *Depends on: public calculator contracts, Arrow/Parquet bundle guidance, golden fixtures, ecosystem readiness, and existing C# and Power Platform boundary documentation.*
   *Gate: define Rust as the intended future calculator core and document formula, parameter, schema, reference data, provenance, validation, and adapter boundaries before Rust implementation begins.*

13. [x] **Track: Rust Acute 2025 Proof of Concept with Python Bindings**
   *Link: [./tracks/rust_acute_python_poc_20260510/](./tracks/rust_acute_python_poc_20260510/)*
   *Depends on: Rust core architecture, acute 2025 golden fixtures, Python packaging, and Arrow-compatible batch contract decisions.*
   *Gate: implement the first Rust-backed acute 2025 canary behind explicit Python opt-in and prove fixture parity before any default runtime change.*

14. [x] **Track: Multi-Surface Binding and Delivery Roadmap**
   *Link: [./tracks/multi_surface_binding_delivery_20260510/](./tracks/multi_surface_binding_delivery_20260510/)*
   *Depends on: Rust core architecture, Rust/Python proof-of-concept results, public contracts, web architecture, and Power Platform boundary rules.*
   *Gate: define binding and delivery sequencing for Python, R, Julia, C#, Rust, Go, TypeScript/WASM, Streamlit, GitHub Pages, and Power Platform before implementing additional adapters.*

15. [x] **Track: Rust CI, Pre-Commit, and Supply-Chain Hardening**
   *Link: [./tracks/rust_ci_supply_chain_hardening_20260510/](./tracks/rust_ci_supply_chain_hardening_20260510/)*
   *Depends on: Python tooling and CI modernization, release governance, docs-site workflow, and Rust workspace decisions.*
   *Gate: align branch triggers, pre-commit hooks, Rust quality gates, dependency review, advisory checks, provenance, and release hardening before Rust code is treated as merge-ready.*

16. [x] **Track: Documentation, Release, and Public Readiness**
   *Link: [./tracks/docs_release_publication_readiness_20260510/](./tracks/docs_release_publication_readiness_20260510/)*
   *Depends on: Rust core architecture, binding delivery roadmap, Starlight documentation, release governance, validation vocabulary, and public repository status.*
   *Gate: publish conservative docs for current versus intended Rust-backed behavior, release status, contributor workflows, public-readiness gaps, and safe delivery surfaces.*

## Umbrella Coordination

- [x] **Track: Modernization Foundation**
  *Link: [./tracks/modernization_foundation_20260504/](./tracks/modernization_foundation_20260504/)*
  *Coordination only.*
  *Retained to preserve sequencing and governance context.*
  *Do not duplicate work already owned by the focused tracks above.*

---

- [x] **Track: Power Platform ALM App Setup and Delivery**
  *Link: [./archive/power_platform_alm_app_20260510/](./archive/power_platform_alm_app_20260510/)*
  *Gate: research current Microsoft Power Platform ALM guidance, choose a supported source-control and deployment path, create the solution-based orchestration scaffold, and wire it into a repeatable pack/unpack and promotion workflow.*

- [x] **Track: Power BI and Power Platform CLI Tooling**
  *Link: [./archive/power_bi_cli_tooling_20260511/](./archive/power_bi_cli_tooling_20260511/)*
  *Depends on: Power Platform ALM App Setup and Delivery.*
  *Gate: bootstrap `az`/`pac`/`powerbi` CLI tooling, normalize PATH and version checks, explicitly reject `pacx` legacy path, and define the delivery contract for Power Platform solution and Power BI operations.*

- [x] **Track: IHACPA Source Archive Gap Closure and Restore Validation**
  *Link: [./archive/ihacpa_source_archive_gap_closure_20260511/](./archive/ihacpa_source_archive_gap_closure_20260511/)*
  *Depends on: source archive manifesting and restore-policy rules.*
  *Gate: recover or explicitly gap-record the remaining Box-hosted SAS artifacts, keep the archive manifest truthful, and validate restore behavior against the committed provenance record.*

- [x] **Track: IHACPA Feature Incorporation and Calculator Coverage Roadmap**
  *Link: [./archive/ihacpa_feature_incorporation_roadmap_20260511/](./archive/ihacpa_feature_incorporation_roadmap_20260511/)*
  *Depends on: source archive inventory and current calculator surfaces.*
  *Gate: map archive families and helpers to executable surfaces, classify complexity/HAC/AHR status, and close any remaining parity gaps with tests and documented follow-on work.*

---

- [x] **Track: IHACPA 2026-27 Support**
*Link: [./tracks/ihacpa_2026_27_support_20260512/](./tracks/ihacpa_2026_27_support_20260512/)*
*Gate: add current 2026-27 NEP, technical specification, price-weight, calculator, and classification-version support with explicit validation status.*

---

- [x] **Track: Community Mental Health Calculator Support**
*Link: [./archive/community_mental_health_calculator_20260512/](./archive/community_mental_health_calculator_20260512/)*
*Gate: separate community mental health and AMHCC shadow/current behavior from admitted mental health before claiming stream coverage.*

- [x] **Track: Classification Input Validation**
*Link: [./tracks/classification_input_validation_20260512/](./tracks/classification_input_validation_20260512/)*
*Gate: add stream-specific classification version matrices and strict input validation before broader calculator expansion.*

---

- [x] **Track: Costing-Study Tutorials and Examples**
*Link: [./tracks/costing_study_tutorials_20260512/](./tracks/costing_study_tutorials_20260512/)*
*Gate: provide synthetic, reproducible costing-study workflows connecting NWAU, NEP, AHPCS, NHCDC, and benchmarking use cases.*

---

- [x] **Track: Historical IHACPA Coverage Audit**
*Link: [./tracks/historical_ihacpa_coverage_20260512/](./tracks/historical_ihacpa_coverage_20260512/)*
*Gate: verify how far official NEP, technical specification, calculator, and NHCDC materials go back before extending historical support claims.*

---

- [x] **Track: Python Rust Binding Stabilization**
*Link: [./tracks/python_rust_binding_stabilization_20260512/](./tracks/python_rust_binding_stabilization_20260512/)*
*Gate: stabilize pyo3/maturin bindings while keeping Python as the validated public API and Rust-backed paths opt-in until parity is proven.*

---

- [x] **Track: R Binding**
*Link: [./tracks/r_binding_20260512/](./tracks/r_binding_20260512/)*
*Gate: support health-economics and costing-study R users without duplicating calculator formula logic.*

---

- [x] **Track: Julia Binding**
*Link: [./tracks/julia_binding_20260512/](./tracks/julia_binding_20260512/)*
*Gate: support Julia analytics through C ABI or Arrow/CLI interop while preserving single-sourced calculator logic.*

---

- [x] **Track: TypeScript and WebAssembly Binding**
*Link: [./tracks/typescript_wasm_binding_20260512/](./tracks/typescript_wasm_binding_20260512/)*
*Gate: enable browser docs demos and Node workflows from the shared Rust core with synthetic-data-only privacy boundaries.*

---

- [x] **Track: C ABI Binding**
*Link: [./tracks/c_abi_binding_20260512/](./tracks/c_abi_binding_20260512/)*
*Gate: define a stable institutional embedding ABI only after core schemas and calculator parity are stable.*

---

- [x] **Track: CLI and File Interoperability Binding**
*Link: [./tracks/cli_file_interop_binding_20260512/](./tracks/cli_file_interop_binding_20260512/)*
*Gate: provide a language-neutral Arrow/Parquet/CSV and CLI contract for ecosystems where native bindings are premature.*

---

- [x] **Track: Reference Data Manifest Schema**
*Link: [./tracks/reference_data_manifest_schema_20260512/](./tracks/reference_data_manifest_schema_20260512/)*
*Gate: define machine-readable pricing-year manifests for source artifacts, constants, coding sets, and validation status before automating future-year support.*

---

- [x] **Track: IHACPA Source Scanner**
*Link: [./tracks/ihacpa_source_scanner_20260512/](./tracks/ihacpa_source_scanner_20260512/)*
*Gate: discover and draft future IHACPA source manifests without overclaiming validation or redistributing restricted material.*

---

- [x] **Track: Pricing-Year Validation Gates**
*Link: [./tracks/pricing_year_validation_gates_20260512/](./tracks/pricing_year_validation_gates_20260512/)*
*Gate: prevent pricing years from being marked supported or validated without required source, extraction, and fixture evidence.*
*Evidence surfaces: `funding-calculator validate-year <year>`, the validation ladder in `conductor/roadmap-governance.md`, the status vocabulary in `conductor/validation-vocabulary.md`, and the manifest schema contract in `conductor/tracks/reference_data_manifest_schema_20260512`.*

---

- [x] **Track: Pricing-Year Diff Tooling**
*Link: [./tracks/pricing_year_diff_tooling_20260512/](./tracks/pricing_year_diff_tooling_20260512/)*
*Gate: compare pricing years and summarize formula, parameter, classification, source, and validation deltas for review and releases.*
*Evidence surfaces: the installed `funding-calculator diff-year <from-year> <to-year>` command, `conductor/tracks/pricing_year_diff_tooling_20260512/strategy.md`, and `conductor/tracks/pricing_year_diff_tooling_20260512/ci_notes.md`.*

---

- [x] **Track: Coding-Set Version Registry**
*Link: [./tracks/coding_set_version_registry_20260512/](./tracks/coding_set_version_registry_20260512/)*
*Gate: record AR-DRG, AECC, UDG, Tier 2, AMHCC, ICD-10-AM, ACHI, and ACS version compatibility and licensing boundaries.*
*Evidence surfaces: `conductor/roadmap-governance.md`, `conductor/validation-vocabulary.md`, `conductor/tracks/classification_input_validation_20260512/classification_matrix.md`, `docs/reviews/20260512-expert-panel/deliberation-and-prioritisation.md`, `conductor/tracks/coding_set_version_registry_20260512/strategy.md`, and `conductor/tracks/coding_set_version_registry_20260512/ci_notes.md`.*

---

- [x] **Track: Formula and Parameter Bundle Pipeline**
*Link: [./tracks/formula_parameter_bundle_pipeline_20260512/](./tracks/formula_parameter_bundle_pipeline_20260512/)*
*Gate: extract, normalize, version, diff, and validate future IHACPA formula and parameter bundles before production calculator claims.*
*Evidence surfaces: `reference-data/2026/manifest.yaml`, `contracts/source-scanner/examples/add-year.draft-manifest.json`, and `conductor/tracks/end_to_end_validated_canary_20260512`.*

---

- [x] **Track: AR-DRG ICD/ACHI/ACS Mapping Registry**
*Link: [./tracks/ar_drg_icd_mapping_registry_20260512/](./tracks/ar_drg_icd_mapping_registry_20260512/)*
*Gate: model version-specific relationships between ICD-10-AM, ACHI, ACS, AR-DRG versions, and mapping-table provenance before deriving or validating DRGs.*

---

- [x] **Track: AR-DRG Grouper Integration**
*Link: [./tracks/ar_drg_grouper_integration_20260512/](./tracks/ar_drg_grouper_integration_20260512/)*
*Gate: support precomputed AR-DRGs and licensed external grouper integration without reimplementing proprietary grouping logic.*

---

- [x] **Track: ICD-10-AM/ACHI/ACS Licensed Product Workflow**
*Link: [./tracks/icd_achi_acs_license_workflow_20260512/](./tracks/icd_achi_acs_license_workflow_20260512/)*
*Gate: define local-only handling, manifest references, commit guards, setup docs, and appropriate-use caveats for licensed classification tables and groupers.*

---

- [x] **Track: AR-DRG Version Parity Fixtures**
*Link: [./tracks/ar_drg_version_parity_fixtures_20260512/](./tracks/ar_drg_version_parity_fixtures_20260512/)*
*Gate: validate version-specific AR-DRG grouping and admitted acute NWAU behavior with safe synthetic and local licensed fixtures.*

---

- [x] **Track: Emergency UDG/AECC Transition Registry**
*Link: [./tracks/emergency_udg_aecc_transition_registry_20260512/](./tracks/emergency_udg_aecc_transition_registry_20260512/)*
*Gate: model UDG, AECC, transition periods, emergency stream compatibility, and pricing-year applicability before accepting emergency classification inputs as interchangeable.*

---

- [x] **Track: Emergency Code Mapping Pipeline**
*Link: [./tracks/emergency_code_mapping_pipeline_20260512/](./tracks/emergency_code_mapping_pipeline_20260512/)*
*Gate: add versioned, provenance-aware mapping bundles for source emergency fields to UDG or AECC outputs without inventing unsupported crosswalks.*

---

- [x] **Track: Emergency Grouper Integration**
*Link: [./tracks/emergency_grouper_integration_20260512/](./tracks/emergency_grouper_integration_20260512/)*
*Gate: support precomputed and externally derived UDG/AECC outputs through a validated classifier interface and local tool/service integration.*

---

- [x] **Track: Emergency Classification Parity Fixtures**
*Link: [./tracks/emergency_classification_parity_fixtures_20260512/](./tracks/emergency_classification_parity_fixtures_20260512/)*
*Gate: validate UDG/AECC parity fixtures only after the emergency transition registry, mapping pipeline, and grouper integration are in place, and keep synthetic and local-only licensed fixtures separate from redistributed content.*

---

- [x] **Track: Abstraction Doctrine Enforcement**
*Link: [./tracks/abstraction_doctrine_enforcement_20260512/](./tracks/abstraction_doctrine_enforcement_20260512/)*
*Gate: make formula, parameter, registry, classifier, binding, app, and documentation boundaries explicit and enforceable before implementing more surfaces.*

---

- [x] **Track: Polyglot Rust Core Roadmap**
*Link: [./tracks/polyglot_rust_core_roadmap_20260512/](./tracks/polyglot_rust_core_roadmap_20260512/)*
*Gate: coordinate the transition from Python-first package to shared Rust calculator core with thin Python, R, Julia, TypeScript/WASM, C ABI, CLI/file, web, and Power Platform consumers.*

---

- [x] **Track: C#/.NET Binding**
*Link: [./tracks/csharp_dotnet_binding_20260512/](./tracks/csharp_dotnet_binding_20260512/)*
*Gate: expose institutional .NET integration through C ABI, service, or CLI/file contracts without duplicating formula logic.*

---

- [x] **Track: Go Binding**
*Link: [./tracks/go_binding_20260512/](./tracks/go_binding_20260512/)*
*Gate: support Go services and data pipelines through shared-core or file/service contracts without formula duplication.*

---

- [~] **Track: Kotlin/JVM Binding**
*Link: [./tracks/java_jvm_binding_20260512/](./tracks/java_jvm_binding_20260512/)*
*Gate: support enterprise JVM consumers through service, JNI/JNA, C ABI, or Arrow/Parquet interop with shared fixture validation.*

---

- [x] **Track: SQL and DuckDB Integration**
*Link: [./tracks/duckdb_sql_binding_20260512/](./tracks/duckdb_sql_binding_20260512/)*
*Gate: support analytical SQL workflows through table schemas and shared-core execution without hand-copied SQL formulas.*

---

- [x] **Track: SAS Interoperability**
*Link: [./tracks/sas_interop_binding_20260512/](./tracks/sas_interop_binding_20260512/)*
*Gate: support SAS reference comparison and import/export workflows without creating a separate SAS formula implementation.*

---

- [x] **Track: Power Platform Binding**
*Link: [./tracks/power_platform_binding_20260512/](./tracks/power_platform_binding_20260512/)*
*Gate: publish Power Platform orchestration as a managed solution/custom connector consumer of the shared calculator contract, never as a formula implementation.*

---

- [x] **Track: Cost Bucket Registry**
*Link: [./tracks/cost_bucket_registry_20260512/](./tracks/cost_bucket_registry_20260512/)*
*Gate: represent public IHACPA/NHCDC cost bucket definitions, mappings, caveats, and local overlay references without bundling confidential submissions.*

---

- [x] **Track: NHCDC Cost Report Ingestion**
*Link: [./tracks/nhcdc_cost_report_ingestion_20260512/](./tracks/nhcdc_cost_report_ingestion_20260512/)*
*Gate: ingest public NHCDC cost report appendices and data request specifications with provenance while distinguishing aggregate reports from patient-level costing data.*

---

- [x] **Track: AHPCS Costing Process Model**
*Link: [./tracks/ahpcs_costing_process_model_20260512/](./tracks/ahpcs_costing_process_model_20260512/)*
*Gate: model AHPCS costing-process concepts as validation aids for costing studies without claiming official compliance certification.*

---

- [x] **Track: Cost Bucket Analytics Tutorials**
*Link: [./tracks/cost_bucket_analytics_tutorials_20260512/](./tracks/cost_bucket_analytics_tutorials_20260512/)*
*Gate: publish synthetic and public-safe cost bucket tutorials for benchmarking, cost-versus-NWAU studies, and local mapping overlays.*

---

- [x] **Track: Roadmap Portfolio Governance Backfill**
*Link: [./tracks/roadmap_portfolio_governance_backfill_20260512/](./tracks/roadmap_portfolio_governance_backfill_20260512/)*
*Gate: backfill class, dependency, explicit contract, current-state, and completion-evidence metadata across the expanded Conductor roadmap before further broad implementation claims.*

---

- [x] **Track: Expert Panel Remediation**
*Link: [./tracks/expert_panel_remediation_20260512/](./tracks/expert_panel_remediation_20260512/)*
*Gate: convert simulated expert-panel findings into explicit track dependencies, gate notes, and remediation priorities before implementing lower-priority bindings or publication expansion.*

---

- [x] **Track: End-to-End Validated Canary**
*Link: [./tracks/end_to_end_validated_canary_20260512/](./tracks/end_to_end_validated_canary_20260512/)*
*Gate: prove one stream/year lifecycle from source archive through SAS/Excel parity, formula bundles, Rust canary, Python/CLI conformance, and Starlight documentation before scaling implementation claims.*

---

- [x] **Track: Public Appropriate-Use Documentation**
*Link: [./tracks/public_appropriate_use_docs_20260512/](./tracks/public_appropriate_use_docs_20260512/)*
*Gate: publish conservative docs for validation status, appropriate use, policy caveats, source licensing, and non-endorsement before broad promotion.*

---

- [ ] **Track: Release Evidence Automation**
*Link: [./tracks/release_evidence_automation_20260512/](./tracks/release_evidence_automation_20260512/)*
*Gate: make release, package, tag, docs, workflow, and registry publication claims machine-checkable before expanding publication targets.*

---

- [ ] **Track: Contract Schema Export**
*Link: [./tracks/contract_schema_export_20260512/](./tracks/contract_schema_export_20260512/)*
*Gate: export versioned schemas for calculator contracts, manifests, evidence, diagnostics, and provenance before implementing broad bindings.*
