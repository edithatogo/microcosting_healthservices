# Specification: Power Platform ALM App Setup and Delivery

## Overview

Create a solution-based Power Platform ALM app and delivery workflow for this repository. The track must start with a SOTA requirements review grounded in current Microsoft Learn guidance, then create the actual Power Platform solution/app surface, and finally wire it into a repeatable ALM pipeline using the relevant Microsoft and Azure tooling.

The intent is not to move calculator logic into Power Platform. The intent is to create an orchestration surface and solution packaging workflow that can promote, validate, and manage Power Platform artifacts while keeping calculation logic behind a secure service boundary.

## Current State

- The repository already documents Power Platform as orchestration-only, not as the calculator core.
- A tracked Power Platform scaffold now exists under [`power-platform/solution/`](../../../power-platform/solution/).
- A service-boundary contract now exists under [`power-platform/connectors/service-boundary-contract.md`](../../../power-platform/connectors/service-boundary-contract.md).
- `az` is installed locally, but `pac` and `pacx` are not currently present.
- Microsoft Learn now recommends solutions, managed environments, source control, pipelines, and solution checker as the ALM baseline.
- Native Dataverse Git integration is currently Azure DevOps-oriented, so the track must explicitly decide whether to mirror to Azure DevOps or use a GitHub-compatible pack/unpack pipeline path.
- The deprecated ALM Accelerator path must not be treated as the target implementation.
- Source control should remain the single source of truth for the solution artifacts.

## SOTA Research Basis

The track must use current first-party Microsoft guidance as the source of truth, including:

- Power Platform ALM overview and solution-based lifecycle guidance.
- Git integration and source-control guidance for Dataverse solutions.
- Power Platform developer tools and `pac` CLI reference.
- Pipeline guidance and solution checker checks.
- Managed environment and Dataverse prerequisites.

Key requirements inferred from current guidance:

- ALM should be solution-based, not ad hoc app export/import.
- Source control should remain the single source of truth.
- Development, test, and production environments should be explicit and managed.
- Managed solutions should be used for downstream promotion.
- A secure service boundary is required for any real-data orchestration.
- App artifacts must remain inside a solution so pack/unpack and promotion are repeatable.

## SOTA References, Assumptions, and Baseline Requirements

This Phase 1 baseline records the SOTA requirements and assumptions directly in the track so the architecture can be reviewed without external browsing.

### First-Party Reference Set

- Microsoft Learn ALM guidance establishes solutions as the required application lifecycle unit for Power Platform delivery.
- Microsoft Learn environment governance guidance establishes managed environments as the preferred operational baseline for controlled enterprise delivery.
- Microsoft Learn validation guidance establishes solution checker as the standard quality gate for solution validation before promotion.
- Microsoft Learn developer tooling guidance establishes `pac` as the supported CLI baseline for solution export, unpack, pack, import, and checker automation.
- Microsoft Learn and current product behavior indicate native Dataverse Git integration is Azure DevOps-oriented rather than GitHub-native.

### Phase 1 Assumptions

- The repo remains GitHub-hosted and GitHub remains the day-to-day source control system for solution artifacts.
- The app remains orchestration-only and must not host calculator formula logic.
- Dataverse remains a runtime/configuration platform, not the primary authored source-control representation.
- `pacx` should be treated as deprecated or unavailable for this track unless a later phase proves a supported replacement scenario.
- Real-data operations must cross a secure service boundary into an external service layer rather than run sensitive business logic inside the app.

### Concrete Requirements Baseline

- Solution-based ALM: all app, flow, table, connector, connection reference, and environment variable assets must live inside a solution-based Power Platform ALM app structure.
- Managed environments: development, test, and production environments should be explicit, governed, and compatible with managed-environment controls.
- Managed solution promotion: downstream environments receive managed solutions; unmanaged customization is limited to the authoring environment.
- Solution checker: validation must include solution checker before promotion is treated as releasable.
- Dataverse source-control limits: native Dataverse Git integration is Azure DevOps-oriented, so GitHub delivery must rely on solution export plus `pac` pack/unpack rather than assuming direct GitHub-native Dataverse sync.
- `pacx` deprecation baseline: the track must not depend on `pacx`; the supported CLI baseline is `pac` plus any required surrounding automation.
- Service-boundary rule: the app can orchestrate requests, capture inputs, and present results, but calculation logic and sensitive execution remain behind the secure service boundary.

## Phase 1 Decision Summary

> Phase 1 Decision Summary
>
> - Chosen ALM unit: solution-based Power Platform ALM app, not loose app export/import.
> - Chosen environment model: managed environments for governed dev, test, and production separation.
> - Chosen validation gate: solution checker is mandatory in the promotion workflow.
> - Chosen source-control path: GitHub remains the source of truth for unpacked solution assets.
> - Chosen Dataverse sync model: use `pac` export/pack/unpack automation instead of depending on native Dataverse Git integration.
> - Dataverse limitation recorded: native integration is Azure DevOps-oriented and does not define the GitHub path for this track.
> - `pacx` decision: blocked as a dependency for this track because the supported baseline is `pac` and `pacx` should not anchor the workflow.
> - Service-boundary decision: Power Platform stays orchestration-only and invokes external secured services for business logic and sensitive processing.
> - Architecture consequence: the next phases should scaffold a solution workspace, environment variables, connection references, and deployment automation around the chosen `pac`-driven path.

## Accepted and Blocked Tooling Choices

- Accepted: `pac` as the supported Power Platform CLI baseline.
- Accepted: `az` as the supporting Azure authentication and environment-access tool where required by surrounding automation.
- Accepted: GitHub-based source control for unpacked solution artifacts.
- Blocked: `pacx` as a required dependency for this track baseline.
- Blocked: assuming GitHub-native Dataverse Git integration.
- Blocked: deprecated ALM Accelerator as the target delivery model.

## Target State

- A Power Platform solution scaffold exists in the repo with a documented source-control layout.
- The scaffold contains an ALM-oriented app surface contract and the supporting tables, flows, environment variables, connection references, and connectors needed for orchestration.
- The scaffold can be unpacked, reviewed, packed, imported, and promoted through a documented pipeline.
- The track chooses a supported ALM path for source control and deployment, and documents why that path was chosen.
- `pac`, `az`, and any additional required Power Platform tooling are installed or explicitly evaluated and replaced with a documented equivalent if `pacx` is unavailable or unsupported.
- The phase-2 bootstrap command is recorded as `./scripts/bootstrap-power-platform-alm.sh`, with prerequisite notes in `./scripts/bootstrap-power-platform-alm-checks.md`.
- The workflow uses managed solutions, solution checker, and repeatable build/deploy steps.
- The phase-3 scaffold documents the solution identity, app surface contract, environment variables, connection references, and secure service boundary layout.

## Functional Requirements

- Research and record the current Microsoft-recommended ALM requirements for Power Platform solutions.
- Decide the implementation path for source control and deployment, taking into account that native Dataverse Git integration is Azure DevOps-oriented today.
- Create the actual Power Platform solution and ALM app surface in a solution-aware layout.
- Add any supporting Dataverse tables, environment variables, connection references, and connectors required by the app.
- Install and configure `pac`, `az`, and any other relevant tools needed for solution pack/unpack, solution checker, auth, and deployment.
- Evaluate `pacx` if it is available and useful; if not, document the equivalent supported toolchain.
- Add a repeatable source-control workflow for unpacking, editing, packing, and validating the solution.
- Add pipeline automation for validation and promotion.
- Keep the app orchestration-only and ensure any real-data operation stays behind the secure service boundary.

## Phase 2 Bootstrap Contract

- Canonical bootstrap command: `./scripts/bootstrap-power-platform-alm.sh`
- Canonical auth-readiness check: `./scripts/bootstrap-power-platform-alm.sh --check-auth`
- Default behavior must be verification-only and non-destructive.
- Optional remediation must be explicit and flag-gated (`--install-missing`, `--upgrade`).
- Minimum supported versions:
  - `pac >= 1.35.0`
  - `az >= 2.70.0`
- CLI discovery must use `command -v pac` and `command -v az`.
- `pacx` is a documented reject path for this track and must not be substituted for `pac` in CI, docs, or local recipes.
- Bootstrap guidance must keep credentials out of the repository and refer operators to shell-based `az login` and `pac auth create`.

## Non-Functional Requirements

- Do not implement calculator formula logic in Power Platform.
- Prefer official Microsoft-supported tooling and current docs over deprecated accelerator paths.
- Preserve GitHub as the repo source of truth unless the track explicitly decides that a mirrored Azure DevOps repo is required for native Dataverse Git integration.
- Use managed environments and managed solutions where they are required by the chosen ALM path.
- Keep the repo consistent with Conductor's autonomous review-and-checkpoint workflow.

## Acceptance Criteria

- A SOTA ALM requirements summary exists in the track artifacts.
- The chosen ALM path is documented, including any Azure DevOps or GitHub tradeoffs.
- The bootstrap command and prerequisite note exist at `./scripts/bootstrap-power-platform-alm.sh` and `./scripts/bootstrap-power-platform-alm-checks.md`.
- A Power Platform solution scaffold exists in the repository.
- The ALM app surface exists inside the solution and is wired to the secure service boundary rather than embedding calculation logic.
- Tooling setup is documented for `pac`, `az`, and any additional supported helper tools.
- Pack/unpack and import/export steps are documented and validated.
- Pipeline automation exists or is explicitly scoped and sequenced for the next phase.
- The track ends with automated `conductor-review` checkpointing and auto-advance.

## Out of Scope

- Implementing calculator logic inside Power Platform.
- Reintroducing the deprecated ALM Accelerator as the target workflow.
- Claiming native Git integration support that the current Microsoft docs do not provide.
- Shipping production data flows without the required secure service boundary.

## Phase 3 Scaffold Contract

- Source-control home: [`power-platform/solution/`](../../../power-platform/solution/)
- Solution identity contract: [`solution-manifest.md`](../../../power-platform/solution/solution-manifest.md)
- App surface contract: [`app-surface.md`](../../../power-platform/solution/app-surface.md)
- Environment variables: [`environment-variables.md`](../../../power-platform/solution/environment-variables.md)
- Connection references: [`connection-references.md`](../../../power-platform/solution/connection-references.md)
- Secure service boundary: [`power-platform/connectors/service-boundary-contract.md`](../../../power-platform/connectors/service-boundary-contract.md)
- ALM workflow contract: [`alm-workflow.md`](../../../power-platform/solution/alm-workflow.md)
