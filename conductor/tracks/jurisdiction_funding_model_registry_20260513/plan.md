# Plan: Jurisdiction Funding Model Registry

## Phase 1: State and Territory Source Inventory
- [ ] Task: Source public evidence for all jurisdictions.
    - [ ] NSW State Price and LHD/SHN service agreement notes.
    - [ ] VIC national model transition, WIES history, VCDC/VicABC sources.
    - [ ] QLD Efficient Price, QWAU, and Queensland ABF modifications.
    - [ ] WA state-specific ABF adjustments and allocation price references.
    - [ ] SA State Efficient Price and NEP-equivalent cost per NWAU sources.
    - [ ] TAS service plan activity/funding schedules.
    - [ ] ACT applicable price and ABF service funding agreement.
    - [ ] NT service plan price per WAU and block funding schedules.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: State and Territory Source Inventory' (Protocol in workflow.md)

## Phase 2: Registry Schema
- [ ] Task: Define jurisdiction model schema.
    - [ ] Add jurisdiction, financial year, source unit, mapped HWAU unit, price, adjustment, stream applicability, source status, and provenance.
    - [ ] Add blocked-source handling for missing or restricted data.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Registry Schema' (Protocol in workflow.md)

## Phase 3: Validation and Parallel Use
- [ ] Task: Add jurisdiction fixtures and tests.
    - [ ] Add public-safe source-status fixtures for all jurisdictions.
    - [ ] Add valuation selection tests.
    - [ ] Add fail-closed tests for unavailable jurisdiction/year combinations.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Validation and Parallel Use' (Protocol in workflow.md)
