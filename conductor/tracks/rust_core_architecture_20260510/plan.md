# Plan: Rust Core Architecture and Calculator Abstraction

## Phase 1: Current-State Architecture Audit

- [x] Task: Write tests for Rust architecture governance [2151123]
    - [ ] Verify the tracks registry contains the Rust architecture roadmap in the expected order
    - [ ] Verify architecture docs distinguish current Python behavior from intended Rust-core behavior
    - [ ] Verify Power Platform remains orchestration-only
- [x] Task: Audit current calculator boundaries [43d4a0a]
    - [x] Map formulae, parameters, schemas, reference loading, provenance, and adapter responsibilities
    - [x] Identify remaining pandas-coupled execution paths
    - [x] Record where existing Arrow/Parquet bundles and golden fixtures already satisfy the target contract
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Current-State Architecture Audit' (Protocol in workflow.md)

## Phase 2: Rust-Core Target Architecture ADR

- [ ] Task: Write tests for the new ADR and documentation links
    - [ ] Verify the ADR exists and is referenced from Conductor and Starlight navigation where appropriate
    - [ ] Verify the ADR names Rust as the intended future core and Python as the current validated path
- [ ] Task: Add the Rust-core architecture ADR
    - [ ] Define crate responsibilities, adapter boundaries, and promotion gates
    - [ ] Record why Arrow-compatible batch contracts are primary
    - [ ] Supersede the C#-engine-first assumption without removing Power Platform support
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Rust-Core Target Architecture ADR' (Protocol in workflow.md)

## Phase 3: Contract and Schema Boundary Design

- [ ] Task: Write contract tests for boundary documentation
    - [ ] Verify formulae, parameters, schemas, bundles, provenance, and validation status are documented as separate concepts
    - [ ] Verify adapters are prohibited from duplicating formula logic
- [ ] Task: Update contract and boundary documents
    - [ ] Update public API contract guidance for Rust-backed batch execution
    - [ ] Update C#, Power Platform, and web architecture docs to consume the Rust-core contract
    - [ ] Document scalar helper limits and batch-first interface expectations
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Contract and Schema Boundary Design' (Protocol in workflow.md)

## Phase 4: Migration and Promotion Policy

- [ ] Task: Write migration policy tests
    - [ ] Verify Rust promotion requires golden fixture parity and explicit validation status
    - [ ] Verify Python remains default until a calculator-specific promotion record exists
- [ ] Task: Document calculator-by-calculator migration policy
    - [ ] Define canary, parity, performance, rollback, and release-note requirements
    - [ ] Define how validation claims appear in docs and release metadata
    - [ ] Update product and tech-stack docs only where the architecture materially changes them
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Migration and Promotion Policy' (Protocol in workflow.md)
