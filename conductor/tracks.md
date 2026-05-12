# Project Tracks

This file tracks the delivery order for the project. The focused tracks below are the implementation source of truth. The modernization foundation track is retained only as an umbrella coordination track and must not duplicate work owned by the focused tracks.

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

- [ ] **Track: IHACPA 2026-27 Support**
*Link: [./tracks/ihacpa_2026_27_support_20260512/](./tracks/ihacpa_2026_27_support_20260512/)*
*Gate: add current 2026-27 NEP, technical specification, price-weight, calculator, and classification-version support with explicit validation status.*

---

- [ ] **Track: Community Mental Health Calculator Support**
*Link: [./tracks/community_mental_health_calculator_20260512/](./tracks/community_mental_health_calculator_20260512/)*
*Gate: separate community mental health and AMHCC shadow/current behavior from admitted mental health before claiming stream coverage.*

---

- [ ] **Track: Classification Input Validation**
*Link: [./tracks/classification_input_validation_20260512/](./tracks/classification_input_validation_20260512/)*
*Gate: add stream-specific classification version matrices and strict input validation before broader calculator expansion.*

---

- [ ] **Track: Costing-Study Tutorials and Examples**
*Link: [./tracks/costing_study_tutorials_20260512/](./tracks/costing_study_tutorials_20260512/)*
*Gate: provide synthetic, reproducible costing-study workflows connecting NWAU, NEP, AHPCS, NHCDC, and benchmarking use cases.*

---

- [ ] **Track: Historical IHACPA Coverage Audit**
*Link: [./tracks/historical_ihacpa_coverage_20260512/](./tracks/historical_ihacpa_coverage_20260512/)*
*Gate: verify how far official NEP, technical specification, calculator, and NHCDC materials go back before extending historical support claims.*
