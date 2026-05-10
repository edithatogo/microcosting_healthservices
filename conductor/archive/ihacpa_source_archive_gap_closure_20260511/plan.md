# Plan: IHACPA Source Archive Gap Closure and Restore Validation

## Phase 1: Archive Completeness Baseline

- [x] Task: Write tests for archive completeness and gap contract
    - [x] Verify the manifest contains 94 entries
    - [x] Verify 92 entries are downloaded and 2 are explicitly gap-recorded
    - [x] Verify every downloaded manifest entry exists on disk
    - [x] Verify the restore policy still treats HTML-only Box pages as gaps
- [x] Task: Record the current source archive inventory
    - [x] Document the year range from `2013-14` through `2026-27`
    - [x] Document the artifact families represented in the archive
    - [x] Record the remaining Box-hosted SAS pages as the only unresolved gaps
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Archive Completeness Baseline'

## Phase 2: Gap Recovery or Explicit Gap Recording

- [x] Task: Write tests for gap recovery and manifest updates
    - [x] Verify recovered artifacts update checksum and acquisition metadata
    - [x] Verify unrecoverable artifacts remain explicitly marked as gaps
    - [x] Verify restore notes explain the approved follow-up path
- [x] Task: Attempt recovery of the Box-hosted SAS artifacts
    - [x] Recover the `2021-22` SAS binary if a direct or approved path exists
    - [x] Recover the `2022-23` SAS binary if a direct or approved path exists
    - [x] Capture the acquisition context for any successful recovery
    - [x] Keep unrecoverable entries conservative and auditable
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Gap Recovery and Recording'

## Phase 3: Restore Workflow and Documentation

- [x] Task: Write tests for restore workflow documentation
    - [x] Verify the restore workflow matches the archive policy
    - [x] Verify the manifest and docs use the same gap terminology
    - [x] Verify the archive completeness summary remains accurate
- [x] Task: Update archive guidance and manifest notes
    - [x] Synchronize `conductor/source-archive.md` with the final archive state
    - [x] Record the recovered artifact paths or explicit gap notes
    - [x] Capture the validation steps used for the archive inventory
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Restore Workflow and Documentation'
