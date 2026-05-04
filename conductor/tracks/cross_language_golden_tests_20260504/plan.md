# Plan: Cross-Language Golden Test Suite

## Phase 1: Fixture Contract

- [ ] Task: Write tests for fixture schema
    - [ ] Validate inputs, outputs, tolerance, source basis, and privacy flags
    - [ ] Reject fixtures without provenance
- [ ] Task: Define fixture format
    - [ ] Use JSON or Arrow-compatible fixtures
    - [ ] Document precision and rounding policy
- [ ] Task: Conductor - User Manual Verification 'Fixture Contract' (Protocol in workflow.md)

## Phase 2: Python Consumption

- [ ] Task: Write tests that consume fixture packs
    - [ ] Cover at least one implemented calculator
    - [ ] Distinguish regression parity from output parity
- [ ] Task: Add fixture runner
    - [ ] Generate pytest cases from fixture metadata
    - [ ] Report fixture provenance in failures
- [ ] Task: Conductor - User Manual Verification 'Python Consumption' (Protocol in workflow.md)

## Phase 3: Cross-Engine Readiness

- [ ] Task: Write C# compatibility checks for fixture format
    - [ ] Verify naming, numeric precision, and enum representation
    - [ ] Verify no Python-specific assumptions leak into fixtures
- [ ] Task: Document cross-engine parity workflow
    - [ ] Define how Python, C#, and web runners consume the same fixtures
    - [ ] Define release blocking criteria
- [ ] Task: Conductor - User Manual Verification 'Cross-Engine Readiness' (Protocol in workflow.md)

