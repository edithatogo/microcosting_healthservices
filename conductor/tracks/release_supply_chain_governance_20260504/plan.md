# Plan: Release and Supply-Chain Governance

## Phase 1: Release Model

- [ ] Task: Write checks for release metadata
    - [ ] Validate package version, data bundle version, source checksum set, and validation status
    - [ ] Validate evidence-backed parity records for release claims
    - [ ] Record lockfile revision used for the build
    - [ ] Verify release notes can identify calculator behavior changes
- [ ] Task: Define release policy
    - [ ] Distinguish code releases from data bundle releases
    - [ ] Define when validation status changes require release notes
    - [ ] Note dependency on the Python Tooling and CI Modernization track
- [ ] Task: Conductor - User Manual Verification 'Release Model' (Protocol in workflow.md)

## Phase 2: Supply-Chain Controls

- [ ] Task: Write CI checks for source and dependency integrity
    - [ ] Verify source checksums before extraction
    - [ ] Verify dependency lockfiles and pinned tool versions
    - [ ] Ensure provenance manifests are read from the tracked location, not ignored raw storage
    - [ ] Ensure locked installs are used in release validation
- [ ] Task: Add supply-chain governance plan
    - [ ] Define SBOM generation
    - [ ] Define signed release artifacts
    - [ ] Define Renovate package rules for calculator-impacting dependencies
- [ ] Task: Conductor - User Manual Verification 'Supply-Chain Controls' (Protocol in workflow.md)
