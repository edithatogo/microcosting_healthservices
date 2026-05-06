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

3. [ ] **Track: Python Tooling and CI Modernization**
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

8. [ ] **Track: C# Calculation Engine and Power Platform Adapter**
   *Link: [./tracks/csharp_power_platform_engine_20260504/](./tracks/csharp_power_platform_engine_20260504/)*
   *Depends on: public API contract, calculator core abstractions, and golden fixtures.*
   *Gate: keep Power Platform orchestration separate from the calculation engine and drive parity from shared fixtures.*

9. [x] **Track: Release and Supply-Chain Governance**
   *Link: [./tracks/release_supply_chain_governance_20260504/](./tracks/release_supply_chain_governance_20260504/)*
   *Depends on: CI, validation evidence, and contract stability.*
   *Gate: add release policy, signed artifacts, dependency automation, and provenance controls after the implementation pipeline is stable.*

## Umbrella Coordination

- **Modernization Foundation**: [./tracks/modernization_foundation_20260504/](./tracks/modernization_foundation_20260504/)
  - Coordination only.
  - Retained to preserve sequencing and governance context.
  - Do not duplicate work already owned by the focused tracks above.
