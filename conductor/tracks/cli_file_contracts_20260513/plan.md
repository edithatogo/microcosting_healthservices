# Plan: CLI/File Contracts

## Phase 1: Command Contract
- [ ] Task: Define command names, arguments, stdout/stderr behavior, and exit codes.
    - [ ] Include schema, validate, run, explain, list, and diagnose commands.
    - [ ] Require `--json` for machine-readable automation.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Command Contract' (Protocol in workflow.md)

## Phase 2: File Contract
- [ ] Task: Define JSON manifest and Arrow/Parquet data contracts.
    - [ ] Include batch input, batch output, diagnostics, and provenance files.
    - [ ] Add round-trip validation fixtures.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: File Contract' (Protocol in workflow.md)

## Phase 3: Validation
- [ ] Task: Add tests for exit codes, schemas, fixtures, and fail-closed behavior.
    - [ ] Validate unsupported streams and years.
    - [ ] Validate schema mismatch handling.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Validation' (Protocol in workflow.md)
