# Plan: NHCDC Cost Report Ingestion

## Phase 1: Source Inventory
- [ ] Task: Inventory public NHCDC reports, appendices, and data request specifications by year.
    - [ ] Capture URLs, file types, checksums, publication dates, and table categories.
    - [ ] Record missing or changed formats as explicit gaps.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Source Inventory' (Protocol in workflow.md)

## Phase 2: Parser and Normalization
- [ ] Task: Add parser fixtures and normalized output schema for public NHCDC tables.
    - [ ] Use safe sample workbooks or fixture slices.
    - [ ] Preserve table-level provenance.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Parser and Normalization' (Protocol in workflow.md)

## Phase 3: Documentation and Examples
- [ ] Task: Document public NHCDC table ingestion and interpretation limits.
    - [ ] Link cost bucket registry and costing-study tutorials.
    - [ ] Explain aggregate public data versus confidential patient-level submissions.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Documentation and Examples' (Protocol in workflow.md)
