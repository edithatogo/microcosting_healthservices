# Plan: IHACPA Source Scanner

## Phase 1: Command Contract
- [ ] Task: Define source scanner command contract and source categories.
    - [ ] Specify dry-run output and review workflow.
    - [ ] Define gap-record handling for Box-hosted or inaccessible artifacts.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Command Contract' (Protocol in workflow.md)

## Phase 2: Scanner Implementation
- [ ] Task: Implement source discovery and draft-manifest generation.
    - [ ] Add parser tests using saved HTML or synthetic source fixtures.
    - [ ] Add checksum and retrieval metadata handling.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Scanner Implementation' (Protocol in workflow.md)

## Phase 3: Docs and CI Safety
- [ ] Task: Document scanner use and add non-network CI checks.
    - [ ] Ensure CI validates parser fixtures without depending on live IHACPA availability.
    - [ ] Explain manual review before committing source changes.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Docs and CI Safety' (Protocol in workflow.md)
