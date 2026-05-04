# Plan: Calculator Core Abstraction and Validation Models

## Phase 1: Contract Tests

- [ ] Task: Write tests for parameter and schema boundaries
    - [ ] Validate pricing-year selection
    - [ ] Validate required input fields and output columns
    - [ ] Validate explicit error shapes for invalid contract inputs
- [ ] Task: Introduce calculator contract types
    - [ ] Add parameter, input, output, and provenance model concepts
    - [ ] Keep behavior-compatible adapters for existing calculators
    - [ ] Bind these types to the public API contract definitions
- [ ] Task: Conductor - User Manual Verification 'Contract Tests' (Protocol in workflow.md)

## Phase 2: Reference Data Boundaries

- [ ] Task: Write tests for reference data resolution
    - [ ] Verify explicit data bundle selection
    - [ ] Verify missing data produces clear errors
- [ ] Task: Implement reference data abstraction
    - [ ] Separate raw archive, extracted data, and runtime bundle locations
    - [ ] Add provenance metadata to runtime resolution
    - [ ] Make bundle selection deterministic from year, calculator, and manifest identity
- [ ] Task: Conductor - User Manual Verification 'Reference Data Boundaries' (Protocol in workflow.md)

## Phase 3: Adapter Boundaries

- [ ] Task: Write tests proving CLI and library paths share the same core behavior
    - [ ] Use shared fixtures
    - [ ] Assert equivalent outputs
- [ ] Task: Separate delivery adapters from calculator core
    - [ ] Define adapter responsibilities for CLI, Python API, web, and C#
    - [ ] Document prohibited adapter behavior
    - [ ] Keep adapter code limited to parsing, validation, orchestration, and formatting
- [ ] Task: Conductor - User Manual Verification 'Adapter Boundaries' (Protocol in workflow.md)
