# Plan: Classification Input Validation

## Phase 1: Matrix and Schema Design
- [x] Task: Create a year-by-year classification compatibility matrix.
    - [x] Include AR-DRG, AECC, UDG, Tier 2, AMHCC, and known transition years.
    - [x] Identify licensed/non-redistributable inputs.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Matrix and Schema Design' (Protocol in workflow.md)

## Phase 2: Validator Tests
- [ ] Task: Write validation tests for stream-specific required fields and version mismatches.
    - [ ] Cover valid, missing, invalid, and incompatible version cases.
    - [ ] Include CLI-facing diagnostics where applicable.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Validator Tests' (Protocol in workflow.md)

## Phase 3: Validator Implementation and Docs
- [ ] Task: Implement strict classification-aware validation and documentation.
    - [ ] Add Pydantic or equivalent schema models at module boundaries.
    - [ ] Update docs with preparation guidance for activity datasets.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Validator Implementation and Docs' (Protocol in workflow.md)
