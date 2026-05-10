# Plan: IHACPA Source Archive Gap Closure and Restore Validation

## Phase 1: Archive Completeness Baseline

- [ ] Task: Write tests for archive completeness and gap contract
    - [ ] Verify the manifest contains 94 entries
    - [ ] Verify 92 entries are downloaded and 2 are explicitly gap-recorded
    - [ ] Verify every downloaded manifest entry exists on disk
    - [ ] Verify the restore policy still treats HTML-only Box pages as gaps
- [ ] Task: Record the current source archive inventory
    - [ ] Document the year range from `2013-14` through `2026-27`
    - [ ] Document the artifact families represented in the archive
    - [ ] Record the remaining Box-hosted SAS pages as the only unresolved gaps
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Archive Completeness Baseline'

## Phase 2: Gap Recovery or Explicit Gap Recording

- [ ] Task: Write tests for gap recovery and manifest updates
    - [ ] Verify recovered artifacts update checksum and acquisition metadata
    - [ ] Verify unrecoverable artifacts remain explicitly marked as gaps
    - [ ] Verify restore notes explain the approved follow-up path
- [ ] Task: Attempt recovery of the Box-hosted SAS artifacts
    - [ ] Recover the `2021-22` SAS binary if a direct or approved path exists
    - [ ] Recover the `2022-23` SAS binary if a direct or approved path exists
    - [ ] Capture the acquisition context for any successful recovery
    - [ ] Keep unrecoverable entries conservative and auditable
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Gap Recovery and Recording'

## Phase 3: Restore Workflow and Documentation

- [ ] Task: Write tests for restore workflow documentation
    - [ ] Verify the restore workflow matches the archive policy
    - [ ] Verify the manifest and docs use the same gap terminology
    - [ ] Verify the archive completeness summary remains accurate
- [ ] Task: Update archive guidance and manifest notes
    - [ ] Synchronize `conductor/source-archive.md` with the final archive state
    - [ ] Record the recovered artifact paths or explicit gap notes
    - [ ] Capture the validation steps used for the archive inventory
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Restore Workflow and Documentation'
