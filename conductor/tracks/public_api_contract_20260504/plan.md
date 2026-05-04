# Plan: Public Calculator API Contract

## Phase 1: Contract Shape

- [ ] Task: Write tests for calculator capability metadata
    - [ ] Verify supported years, inputs, outputs, parameters, and validation status
    - [ ] Verify unsupported combinations produce structured errors
    - [ ] Verify numeric precision and versioned contract identifiers
- [ ] Task: Define public contract schema
    - [ ] Add versioning policy
    - [ ] Add error model and validation response model
    - [ ] Add explicit input, output, and parameter schema shapes
- [ ] Task: Conductor - User Manual Verification 'Contract Shape' (Protocol in workflow.md)

## Phase 2: API and CLI Alignment

- [ ] Task: Write tests aligning CLI and Python API outputs
    - [ ] Use the same contract definitions
    - [ ] Cover errors and successful calculations
- [ ] Task: Refactor one calculator surface to contract-backed behavior
    - [ ] Preserve existing public behavior where documented
    - [ ] Add deprecation notes where behavior must change
    - [ ] Keep adapter responsibilities limited to parsing, validation, orchestration, and formatting
- [ ] Task: Conductor - User Manual Verification 'API and CLI Alignment' (Protocol in workflow.md)

## Phase 3: Generation Readiness

- [ ] Task: Write checks for OpenAPI and C# model generation compatibility
    - [ ] Validate enum naming and numeric precision
    - [ ] Validate schema examples
- [ ] Task: Document generation pathway
    - [ ] Define how web and C# adapters consume contracts
    - [ ] Define contract compatibility rules
    - [ ] Define how the calculator core publishes contract-ready metadata
- [ ] Task: Conductor - User Manual Verification 'Generation Readiness' (Protocol in workflow.md)
