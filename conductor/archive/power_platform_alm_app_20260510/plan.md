# Plan: Power Platform ALM App Setup and Delivery

## Phase 1: SOTA Requirements and ALM Architecture

- [x] Task: Write tests for the ALM requirements contract
    - [x] Verify the track files exist
    - [x] Verify the spec captures Microsoft Learn ALM requirements
    - [x] Verify the spec distinguishes current state, target state, and out-of-scope items
    - [x] Verify the track registry includes the new Power Platform track
    - [x] Verify Phase 1 wording continues to satisfy `tests/test_power_platform_alm_app_track.py`
- [x] Task: Research the current Power Platform ALM baseline
    - [x] Record the Microsoft Learn guidance for solutions, managed environments, and source control
    - [x] Record the Microsoft Learn guidance for pipelines, solution checker, and developer tooling
    - [x] Record the current limitations of native Dataverse Git integration
    - [x] Record why the deprecated ALM Accelerator is not the target path
    - [x] Record the SOTA references, assumptions, and concrete requirements baseline directly in `spec.md`
- [x] Task: Document the ALM architecture decision
    - [x] Choose the solution shape for the app surface
    - [x] Choose the source-control and promotion path
    - [x] Define the secure service boundary for any real-data workflows
    - [x] Record the toolchain assumptions for `pac`, `az`, `pacx`, and equivalents
    - [x] Add a Phase 1 decision summary block that can be reviewed without external browsing
    - [x] Add a concise accepted/blocked tooling choices section
- [x] Task: Conductor - Automated Review and Checkpoint 'SOTA Requirements and ALM Architecture' via conductor-review, auto-fix, and auto-progress 'SOTA Requirements and ALM Architecture'

## Phase 2: Toolchain and Environment Bootstrap

- [x] Task: Write tests for the toolchain bootstrap contract
    - [x] Verify the repo records the Power Platform toolchain prerequisites
    - [x] Verify the repo records the environment and auth prerequisites
    - [x] Verify the repo records the rejected `pacx` path and supported ALM command
- [x] Task: Implement the phase-2 bootstrap command
    - [x] Add `scripts/bootstrap-power-platform-alm.sh`
    - [x] Enforce explicit `command -v pac` and `command -v az` discovery checks
    - [x] Add optional install/upgrade flags for minimum versions `pac >= 1.35.0` and `az >= 2.70.0`
    - [x] Keep default behavior deterministic and non-destructive for CI checks
- [x] Task: Add the lightweight prerequisite and auth note
    - [x] Add `scripts/bootstrap-power-platform-alm-checks.md`
    - [x] Record the no-credentials-in-repo rule for bootstrap and auth steps
    - [x] Document why `pacx` is rejected in this track
    - [x] Reference the canonical bootstrap command from the track spec
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Toolchain and Environment Bootstrap' (Protocol in workflow.md)

## Phase 3: Power Platform Solution and Orchestration App

- [x] Task: Write tests for the solution and app scaffold contract
    - [x] Verify the solution scaffold exists
    - [x] Verify the app surface is contained in the solution
    - [x] Verify environment variables and connection references are documented
    - [x] Verify the app stays orchestration-only
- [x] Task: Create the Power Platform solution
    - [x] Create the solution shell and supporting Dataverse artifacts
    - [x] Add the app surface to the solution
    - [x] Add any required custom connector or service-boundary configuration
    - [x] Add environment variables and connection references
- [x] Task: Wire the app to the secure service boundary
    - [x] Define the request/response contract used by the app
    - [x] Configure the connector or service call pattern
    - [x] Document the no-formula-logic rule for the app layer
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Power Platform Solution and Orchestration App'

## Phase 4: ALM Automation and Delivery

- [x] Task: Write tests for the ALM automation contract
    - [x] Verify pack/unpack and import/export commands are documented
    - [x] Verify the pipeline configuration exists
    - [x] Verify solution checker or equivalent validation is part of the workflow
    - [x] Verify the chosen GitHub or Azure DevOps promotion path is recorded
- [x] Task: Implement the build and promotion workflow
    - [x] Add solution pack/unpack automation
    - [x] Add solution checker validation
    - [x] Add the deployment workflow for dev/test/prod promotion
    - [x] Add any GitHub Actions, Azure DevOps, or pipeline configuration required by the chosen path
- [x] Task: Validate the end-to-end ALM flow
    - [x] Run the documented build and validation commands
    - [x] Verify the solution can be promoted through the chosen ALM path
    - [x] Update the docs with the final toolchain and workflow status
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'ALM Automation and Delivery'
