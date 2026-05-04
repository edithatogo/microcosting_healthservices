# Plan: Cross-Language Golden Test Suite

## Phase 1: Fixture Contract

- [ ] Task: Write tests for fixture manifest schema and payload rules
    - [ ] Validate calculator, pricing year, service stream, source basis, tolerance, rounding policy, and privacy classification
    - [ ] Reject fixtures without provenance, schema version, or cross-language readiness metadata
- [ ] Task: Define the fixture pack format
    - [ ] Use a JSON manifest with Arrow/Parquet tabular payloads where practical
    - [ ] Document precision, rounding policy, expected schema, and runner-neutral typing
- [ ] Task: Conductor - User Manual Verification 'Fixture Contract' (Protocol in workflow.md)

## Phase 2: Python Consumption

- [ ] Task: Write tests that consume fixture packs through the shared manifest
    - [ ] Cover at least one implemented calculator
    - [ ] Distinguish regression parity from output parity and preserve provenance in failures
- [ ] Task: Add a fixture runner
    - [ ] Generate pytest cases from manifest metadata
    - [ ] Validate privacy classification, tolerance, and source basis before execution
- [ ] Task: Conductor - User Manual Verification 'Python Consumption' (Protocol in workflow.md)

## Phase 3: Cross-Engine Readiness

- [ ] Task: Write compatibility checks for C# and web consumption
    - [ ] Verify naming, numeric precision, enum representation, and Arrow/Parquet readability
    - [ ] Verify no Python-specific assumptions leak into the fixture pack
- [ ] Task: Document the cross-engine parity workflow
    - [ ] Define how Python, C#, and web runners consume the same manifest and payloads
    - [ ] Define the release-blocking criteria for fixture packs marked cross-language ready
- [ ] Task: Conductor - User Manual Verification 'Cross-Engine Readiness' (Protocol in workflow.md)
