# Plan: Source Archive and Provenance Registry

## Phase 1: Manifest Contract

- [ ] Task: Write tests for archive manifest schema
    - [ ] Validate required fields and status values
    - [ ] Validate run context, schema version, and checksum algorithm fields
    - [ ] Validate SHA-256 and byte-count handling
- [ ] Task: Implement manifest schema helpers
    - [ ] Add typed structures for source artifacts
    - [ ] Add structured lifecycle fields for acquisition, extraction, implementation, and validation
    - [ ] Add status normalization for IHACPA-hosted and Box-hosted assets
    - [ ] Add a tracked provenance output path outside ignored raw storage
- [ ] Task: Conductor - User Manual Verification 'Manifest Contract' (Protocol in workflow.md)

## Phase 2: Acquisition Workflow

- [ ] Task: Write tests for IHACPA page parsing
    - [ ] Cover year grouping, Excel links, SAS links, and Box share links
    - [ ] Use saved HTML fixtures rather than live network calls
- [ ] Task: Harden archive acquisition script
    - [ ] Add fixture-based parser tests
    - [ ] Add checksum updates for existing local files and record verification state
    - [ ] Capture acquisition command, script version, redirect chain, and source page snapshot metadata
    - [ ] Add command documentation
- [ ] Task: Conductor - User Manual Verification 'Acquisition Workflow' (Protocol in workflow.md)

## Phase 3: Storage Decision

- [ ] Task: Write storage policy checklist
    - [ ] Compare Git LFS, GitHub release assets, and external object storage
    - [ ] Define restore workflow, checksum verification, and manifest location
- [ ] Task: Create final storage ADR
    - [ ] Update ADR 0001 from proposed to accepted after decision
    - [ ] Document how raw binaries are retrieved in CI or release workflows
- [ ] Task: Conductor - User Manual Verification 'Storage Decision' (Protocol in workflow.md)
