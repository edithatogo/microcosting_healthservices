# Plan: AR-DRG Version Parity Fixtures

## Phase 1: Fixture Schema
- [ ] Task: Define AR-DRG parity fixture schema and provenance fields.
    - [ ] Include coded episode inputs, expected AR-DRG, expected NWAU-relevant fields, and version metadata.
    - [ ] Define synthetic versus local licensed fixture handling.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Fixture Schema' (Protocol in workflow.md)

## Phase 2: Fixture Validation
- [ ] Task: Add fixture loader and compatibility tests.
    - [ ] Reject incompatible pricing-year, coding-set, AR-DRG, or grouper versions.
    - [ ] Support precomputed and external-grouper workflows.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Fixture Validation' (Protocol in workflow.md)

## Phase 3: Documentation
- [ ] Task: Document AR-DRG fixture creation and validation workflow.
    - [ ] Explain how fixtures prove grouping and downstream NWAU behavior.
    - [ ] Add safe examples that avoid restricted product redistribution.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Documentation' (Protocol in workflow.md)
