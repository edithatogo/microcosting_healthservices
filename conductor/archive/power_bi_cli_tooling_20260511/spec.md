# Specification: Power BI and Power Platform CLI Tooling and Delivery

## Overview

Create a tracked CLI-first path for Power Platform ALM and Power BI delivery that is immediately usable from this repository's tooling workflows.

This track covers both command-line capability and delivery surface boundaries:
- Power Platform solution-oriented workflow (`pac`): environments, solution pack/unpack, solution checker, pipelines.
- Power BI delivery workflow (`powerbi`): workspace, dataset, and report operations needed for analytics surface.
- Integration boundary: Power Platform and Power BI call the calculator system through a secure service API; no formula logic is placed in low-code artifacts.

## Current State

- `az` is installed.
- `pac` is installed through `.dotnet/tools` and PATH repair is handled in the bootstrap script when needed.
- `powerbi` CLI is installed through npm.
- `pacx` does not appear in discoverable dotnet/npm packages in this environment.
- Reusable CLI bootstrap script exists at `./scripts/bootstrap-power-platform-powerbi-cli.sh`.

## Handoff Status (Phase 4, 2026-05-11)

- CLI bootstrap is finalized and includes required discovery, version checks, PATH repair, and remediation guidance for `pac`, `powerbi`, and `az`.
- `pacx` is explicitly rejected as the implementation path; the track is standardized on `pac`, `az`, and `powerbi`.
- `pac` and `powerbi` are the supported command surfaces for the ALM and Power BI delivery split documented in this track.
- The track is documentation-complete for handoff into artifact-level implementation and remains aligned to the service-boundary rule (no formula logic in CLI surfaces).

## SOTA Command-Surface Baseline (Phase 1, 2026-05-11)

### Power Platform (`pac`) Command Contract

- `Path` checks must validate command discovery (`command -v pac`, `command -v az`, `command -v powerbi`) and repair shell pathing to `~/.dotnet/tools` when needed.
- The bootstrap command must validate all required command groups below as hard preconditions for this track.

### Power Platform CLI (`pac`) Command Contract

- `pac auth create` / `pac auth list`
  - Contract: establish and review authenticated identities for tenant/environment operations.
  - Minimum checks: command returns exit code 0 and prints identity or status metadata.
- `pac org list`
  - Contract: discover tenant/Dataverse environments before solution operations.
  - Minimum checks: command returns non-empty environment list for valid tenant context.
- `pac solution list`
  - Contract: enumerate available solutions in current organization context.
- `pac solution pack`
  - Contract: create zip for controlled ALM movement.
- `pac solution unpack`
  - Contract: produce deterministic source-controlled solution tree from managed/unmanaged zip.
- `pac solution import`
  - Contract: push solution artifacts into a target environment.
- `pac solution checker run`
  - Contract: validate solution quality and produce checker report artifacts before promotion.
- `pac pipeline list`
  - Contract: surface pipeline-aware promotion metadata/IDs for scripted handoff.

### Power BI CLI (`powerbi`) Command Contract

- `powerbi login`
  - Contract: establish Power BI service context before workspace/report operations.
  - Minimum checks: returns authenticated user and workspace scope information.
- `powerbi workspace list`
  - Contract: discover target workspaces for report/dataset operations.
- `powerbi dataset list`
  - Contract: discover datasets and confirm workspace-to-dataset mapping.
- `powerbi dataset import`
  - Contract: import dataset artifacts for downstream BI delivery.
- `powerbi dataset get` / `powerbi dataset refresh`
  - Contract: read dataset metadata and trigger required refreshes as needed.
- `powerbi report list`
  - Contract: enumerate deployed reports for release bookkeeping.
- `powerbi report export` / `powerbi report import`
  - Contract: move report artifacts between environments and environments of record.

### Azure CLI (`az`) Command Contract

- `az version`
  - Contract: verify Azure CLI availability and major version compatibility.
- `az account show`
  - Contract: confirm active tenant/subscription context used by downstream tooling.
- `az account set`
  - Contract: switch subscription context before promotion steps.
- `az account list`
  - Contract: list accessible subscriptions/environments for planning.

### CLI Discovery and Bootstrap Contract

- CLI availability check must use shell discovery (for example `command -v pac`, `command -v az`, `command -v powerbi`) with explicit remediation guidance.
- Command-version checks (`pac --version`, `az --version`, `powerbi --version`) must run in a single verification step.
- PATH guardrails must repair executable discovery for locally installed `pac` binaries via `~/.dotnet/tools`.

### Tooling Decision Record: `pacx`

- Decision: Do not use `pacx` for this track.
- Rationale: `pacx` is not currently discoverable in this environment's supported package sources, and the track targets a supported, current Microsoft toolchain (`pac`, `az`, `powerbi`) for traceable ALM and BI delivery.
- Implementation fallback: use `pac` solution and checker commands with repository-stored command recipes.

## Objectives

1. Guarantee all required CLI tooling commands are installable and verifiable in this repo.
2. Ensure the CLI bootstrap is repeatable and tracked (install checks, PATH guardrails, version checks).
3. Align Power BI and Power Platform delivery paths with existing ALM and service-boundary constraints.
4. Prepare a clean handoff into solution/report artifact implementation.

## Functional Requirements

## Command Matrix and Version Contract

The track uses a **Command matrix** that is split by CLI domain (`pac`, `powerbi`, and `az`) and enforced by automated bootstrap validation.

- The bootstrap script must validate all required command groups below and treat failed checks as hard failures:

Power Platform (`pac`)
1. `pac --help`
2. `pac auth --help`
3. `pac solution --help`
4. `pac solution checker --help`

Power BI (`powerbi`)
1. `powerbi --help`
2. `powerbi workspace --help`
3. `powerbi dataset --help`
4. `powerbi report --help`

Azure CLI (`az`)
1. `az --version`
2. `az version`

Minimum supported versions tracked for deterministic environments:

- `pac`: `>= 1.35.0`
- `powerbi`: `>= 1.0.0`
- `az`: `>= 2.70.0`

Tooling bootstrap guidance must include explicit PATH recovery steps when `pac` is installed under `~/.dotnet/tools` but not discoverable by `command -v`.

## Bootstrap Contract

- Recovery command:
  - `./scripts/bootstrap-power-platform-powerbi-cli.sh`
- The script must run a deterministic verification block with version checks and command-matrix smoke checks in one flow.
- Expected persistent PATH fix guidance when `pac` is present but undiscoverable:

```
PATH is missing dotnet tools location for pac discovery: ~/.dotnet/tools
Added dotnet tools to PATH for this shell.
If pac remains unavailable after bootstrap, run:
  echo 'export PATH="$PATH:~/.dotnet/tools"' >> ~/.zshrc
  source ~/.zshrc
```

- Define a canonical Power Platform CLI command matrix for:
  - auth bootstrap and environment targeting,
  - solution pack/unpack/import,
  - solution checker invocation,
  - pipeline-aware promotion steps.
- Define a canonical Power BI CLI command matrix for:
  - workspace listing/discovery,
  - dataset import/export helpers,
  - report and embed operations required by downstream analytics.
- Add a repository bootstrap mechanism that:
  - checks for required tools,
  - installs missing CLI components where safe,
  - fixes PATH for locally installed `pac` binaries,
  - confirms tool versions in a single command.
- Capture and track that unsupported/legacy tooling (`pacx`) is excluded from implementation.
- Keep the implementation strategy and code path explicit in Conductor and docs:
  - Power Platform uses solution-based ALM,
  - Power BI reporting remains delivery-oriented,
  - both remain orchestration surfaces that call the service boundary.

## Non-Functional Requirements

- Use official Microsoft tooling (`pac`, `az`, `powerbi`) or clearly documented equivalents.
- Keep command execution deterministic for CI and docs examples.
- Avoid embedding credentials in files; rely on env vars/CLI auth.
- Maintain compatibility with the existing `conductor-review` checkpoint protocol.

## Acceptance Criteria

- A CLI bootstrap command/script exists in-repo and can be used to recover from missing tools.
- Tooling is documented with explicit commands and expected outputs.
- `pac` and `powerbi` commands are discoverable on PATH after bootstrap.
- The track includes a phased rollout from capability discovery → bootstrap → artifact workflow prep.
- Track remains aligned with Power Platform ALM/Power BI reporting boundaries and no-calculation duplication rule.

## Phase 3 Deliverable

- Define `pac` and `powerbi` command surfaces as separate delivery layers:
  - `pac` owns solution lifecycle and ALM transitions.
  - `powerbi` owns workspace/report artifact deployment and catalog operations.
- Require secure service-boundary references in every deployment step before any orchestration
  implementation.
- Provide explicit repository layout guidance for solution assets, connector metadata,
  workspace and report manifests, and dataset/report deployment descriptors.
