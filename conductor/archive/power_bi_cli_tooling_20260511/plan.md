# Plan: Power BI and Power Platform CLI Tooling and Delivery

## Phase 1: CLI and SOTA Requirements Baseline

- [x] Task: Write tests for CLI/tooling contract
    - [x] Verify track file set exists
    - [x] Verify spec captures `pac`, `az`, `powerbi`, and `pacx` status
    - [x] Verify PATH and bootstrap concerns are explicit
    - [x] Verify plan requires no formula logic in Power Platform or Power BI artifacts
- [x] Task: Record current and SOTA command surfaces
    - [x] Document required Power Platform solution/pipeline commands
    - [x] Document required Power BI workspace/report commands
    - [x] Record unsupported/legacy tooling decisions (`pacx` unavailable path)
    - [x] Confirm command contract for CLI discovery (path and version checks)
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'CLI and SOTA Requirements Baseline' (Protocol in workflow.md)

## Phase 2: Bootstrap and Environment Hardening

- [x] Task: Write tests for bootstrap command contract
    - [x] Verify bootstrap script exists
    - [x] Verify bootstrap script validates all expected binaries
    - [x] Verify bootstrap script emits explicit remediation guidance
- [x] Task: Implement CLI bootstrap tooling
    - [x] Add `scripts/bootstrap-power-platform-powerbi-cli.sh`
    - [x] Add `pac` PATH repair and version checks
    - [x] Add `powerbi` presence checks and help smoke tests
    - [x] Add optional checks for `az` and optional Power BI auth readiness
- [x] Task: Add canonical command reference pages
    - [x] Add docs for command matrix and bootstrap usage
    - [x] Record version expectations and minimum supported CLI versions
    - [x] Note `pacx` replacement decision and rationale
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Bootstrap and Environment Hardening' (Protocol in workflow.md)

## Phase 3: Power Platform Surface and Power BI Delivery Readiness

- [x] Task: Write tests for surface-command readiness
    - [x] Verify surface docs are referenced from tracks and registry
    - [x] Verify solution + report delivery paths are split by contract (not implementation)
    - [x] Verify secure service-boundary contract is referenced before any orchestration implementation
- [x] Task: Define solution and reporting command workflow
    - [x] Record command split and service handoff points in [`delivery-workflow.md`](./delivery-workflow.md)
    - [x] Define when `pac solution` and `powerbi` are used versus service API calls
    - [x] Define environment and tenant/tenant-independent defaults for local usage
    - [x] Add migration notes from manual export/import to ALM-aware workflow
- [x] Task: Add starter pipeline contracts and folder layout
    - [x] Create command examples in `conductor/` for ALM/promotion path
    - [x] Document repository layout for Power BI and Power Platform artifacts in [`delivery-workflow.md`](./delivery-workflow.md)
    - [x] Confirm no production data or PHI is written by bootstrap tooling
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Power Platform Surface and Power BI Delivery Readiness' (Protocol in workflow.md)

## Phase 4: Verification and Handoff

- [x] Task: Write tests for end-to-end CLI bootstrap and checks
    - [x] Verify `./scripts/bootstrap-power-platform-powerbi-cli.sh` can run in a clean shell
    - [x] Verify `pac` and `powerbi` are available after script completion
    - [x] Verify the track updates existing registry docs and remains importable by conductor tooling
- [x] Task: Complete command documentation
    - [x] Publish the final status of CLI tools and known constraints in the track docs
    - [x] Update `conductor/tracks.md` with dependency order and gating
    - [x] Update registry/test coverage for this new track
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Verification and Handoff' (Protocol in workflow.md)
