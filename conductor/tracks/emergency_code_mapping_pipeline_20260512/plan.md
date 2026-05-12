# Plan: Emergency Code Mapping Pipeline

## Phase 1: Mapping Bundle Schema
- [ ] Task: Define emergency mapping-bundle schema and provenance fields.
    - [ ] Include source fields, target classification, table version, pricing years, checksums, and validation status.
    - [ ] Define unknown, unmapped, deprecated, and invalid diagnostics.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Mapping Bundle Schema' (Protocol in workflow.md)

## Phase 2: Mapping Engine and Tests
- [ ] Task: Implement table-driven emergency mapping and diagnostics.
    - [ ] Add tests for mapped, unmapped, invalid, and incompatible-year cases.
    - [ ] Preserve raw and mapped fields for audit output.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Mapping Engine and Tests' (Protocol in workflow.md)

## Phase 3: Documentation
- [ ] Task: Document emergency mapping workflow and future-table onboarding.
    - [ ] Include dry-run data-quality review examples.
    - [ ] Clarify when official or local mapping sources are required.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Documentation' (Protocol in workflow.md)
