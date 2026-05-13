# Plan: Jurisdiction Price Source Index

## Phase 1: Source Index Schema
- [ ] Task: Define source index fields.
    - [ ] Add jurisdiction, year, source, licence, checksum, units, and status.
    - [ ] Add extraction notes and blocked-source handling.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Source Index Schema' (Protocol in workflow.md)

## Phase 2: Jurisdiction Rows
- [ ] Task: Add public-safe source-index rows.
    - [ ] Add NSW, VIC, QLD, WA, SA, TAS, ACT, and NT rows.
    - [ ] Mark unavailable or restricted sources explicitly.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Jurisdiction Rows' (Protocol in workflow.md)

## Phase 3: Validation
- [ ] Task: Add source-index tests.
    - [ ] Prevent price values without provenance.
    - [ ] Prevent unknown source status from appearing as supported.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Validation' (Protocol in workflow.md)
