# Power BI and Power Platform Delivery Workflow

This document defines the Phase 3 split between Power Platform solution
operations and Power BI reporting operations, plus the intended repository layout
and service-boundary contract requirements.

## 1) CLI Surface Split

### 1.1 Power Platform Surface (`pac`)

Use `pac` for:

- Environment discovery and targeting.
- Solution source-control operations.
- Packing/unpacking managed and unmanaged solutions.
- Solution quality checks.
- Import/export/publish operations in ALM flows.

Preferred command family for service-oriented delivery:

- `pac auth create`
- `pac env list`
- `pac env select`
- `pac solution init`
- `pac solution unpack`
- `pac solution pack`
- `pac solution checker`
- `pac solution export`
- `pac solution import`

### 1.2 Power BI Surface (`powerbi`)

Use `powerbi` for:

- Workspace discovery and targeting.
- Dataset lifecycle and binding operations.
- Report and app artifact publishing.
- Report refresh and publication-readiness checks.

Preferred command family:

- `powerbi workspace list`
- `powerbi dataset list`
- `powerbi dataset get`
- `powerbi dataset import`
- `powerbi report list`
- `powerbi report import`
- `powerbi report get`
- `powerbi report export`

### 1.3 Shared Constraint

- Neither command surface performs calculator math.
- All scoring calls must go through a secured service boundary that validates the
  same inputs captured by the public contract.
- If a workflow step needs scoring output, it must call the service and consume
  its structured response; command tooling only deploys or reads artifacts.

## 2) Service-Boundary Contract References

- Contract source-of-truth: [`public-api-contract.md`](../../public-api-contract.md)
  (through the shared contract vocabulary and error model).
- Delivery boundary intent: [`power-platform-boundary.md`](../../power-platform-boundary.md)
  and [`downstream-packaging-plans.md`](../../downstream-packaging-plans.md).
- The service call contract must include contract identity fields and fixture
  provenance so operations are auditable without embedding patient-level data in
  deployment artifacts.

## 3) Migration Notes: Manual Import/Export -> ALM Workflow

- Stop treating solution import/export as source authority.
- Store deployment-relevant Power Platform source files in managed folders and use
  `pac solution pack/unpack` to generate deployment artifacts.
- Replace ad-hoc Power BI export files as the source of truth with manifest-tracked
  report and dataset files plus explicit CLI-driven deployment steps.
- Gate production promotion through command-logged environments (`dev` ->
  `test` -> `prod`) and service-boundary health checks.

## 4) Artifact Layout Guidance

Recommended repository layout for this track:

- `power-platform/solution/`  
  Checked-in solution source for ALM pack/unpack flows.
- `power-platform/connectors/`  
  Connector and custom connector metadata referenced by the orchestration
  solution.
- `power-platform/pipelines/`  
  Environment definitions and pipeline-ready command guidance.
- `power-platform/checker/`  
  Solution checker policies and baseline output snapshots.
- `power-bi/workspaces/`  
  Workspace metadata and environment target maps.
- `power-bi/reports/`  
  Report metadata and promoted report manifests (not raw production data).
- `power-bi/datasets/`  
  Dataset binding manifests and refresh policy metadata.

## 5) Data Governance Reminder

- No real patient-level or production-sensitive payload is committed by CLI
  bootstrap tooling.
- Deployment manifests should use synthetic fixtures or metadata-only payloads unless
  a specific governed data workflow is approved.
