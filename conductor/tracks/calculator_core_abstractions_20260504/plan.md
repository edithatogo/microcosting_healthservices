# Plan: Calculator Core Abstraction and Validation Models

## Phase 1: Contract Tests

- [~] Task: Write tests for contract-backed parameter and schema boundaries
    - [ ] Validate pricing-year selection against the public API contract
    - [ ] Validate required input fields and output columns from the contract shape
    - [ ] Validate explicit error shapes for invalid contract inputs
- [ ] Task: Introduce calculator contract types
    - [ ] Add parameter, input, output, and provenance model concepts
    - [ ] Keep behavior-compatible adapters for existing calculators
    - [ ] Bind these types to the public API contract definitions
- [ ] Task: Conductor - User Manual Verification 'Contract Tests and Boundary Shape' (Protocol in workflow.md)

## Phase 2: Reference Data Boundaries

- [ ] Task: Write tests for reference bundle resolution
    - [ ] Verify explicit bundle selection by year, calculator, and manifest identity
    - [ ] Verify missing or mismatched bundles produce clear errors
- [ ] Task: Implement reference data abstraction
    - [ ] Separate raw archive, extracted data, and runtime bundle locations
    - [ ] Add provenance metadata to runtime resolution
    - [ ] Make bundle selection deterministic from year, calculator, and manifest identity
    - [ ] Keep acute and other calculators consuming resolved reference helpers instead of loading bundles inline
- [ ] Task: Conductor - User Manual Verification 'Reference Bundle Boundaries' (Protocol in workflow.md)

## Phase 3: Adapter Boundaries

- [ ] Task: Write tests proving CLI and library paths share the same core behavior
    - [ ] Use shared fixtures
    - [ ] Assert equivalent outputs
- [ ] Task: Separate delivery adapters from calculator core
    - [ ] Define adapter responsibilities for CLI, Python API, web, and C#
    - [ ] Document prohibited adapter behavior
    - [ ] Keep adapter code limited to parsing, validation, orchestration, and formatting
- [ ] Task: Conductor - User Manual Verification 'Adapter Boundaries' (Protocol in workflow.md)
