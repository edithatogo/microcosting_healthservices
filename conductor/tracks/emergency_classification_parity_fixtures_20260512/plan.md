# Plan: Emergency Classification Parity Fixtures

## Phase 1: Fixture Schema
- [ ] Task: Define emergency classification fixture schema and provenance fields.
    - [ ] Include raw source fields, expected UDG/AECC, stream, pricing year, mapping version, and expected NWAU-relevant outputs.
    - [ ] Define synthetic versus local official fixture handling.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Fixture Schema' (Protocol in workflow.md)

## Phase 2: Fixture Validation
- [ ] Task: Add fixture loader and compatibility tests.
    - [ ] Reject incompatible UDG/AECC, pricing-year, stream, and mapping-version combinations.
    - [ ] Support precomputed and externally derived classification workflows.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Fixture Validation' (Protocol in workflow.md)

## Phase 3: Documentation
- [ ] Task: Document emergency classification fixture creation and validation workflow.
    - [ ] Explain UDG-era, AECC-era, and transition-year fixture handling.
    - [ ] Add safe synthetic examples.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Documentation' (Protocol in workflow.md)
