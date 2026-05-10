# Power Platform Boundary

## Purpose

Power Platform should orchestrate calculator workflows, not contain calculator
logic.

## Boundary Rules

- Inputs should map to the public calculator contract.
- Outputs and errors should be structured for workflow apps.
- Calculation should happen in a secured service boundary or Rust-backed core,
  not in Power Platform formulas.
- The calculation boundary must stay outside Power Platform.
- Dataverse and Power Platform should remain orchestration and storage layers
  only.

## Integration Shape

- A Custom Connector or Azure Function can expose the service boundary.
- The connector should consume contract identifiers and fixture identifiers.
- Real-data workflows must remain behind the secured service boundary.
- Power Platform should not duplicate formula logic or own pricing-year
  validation rules.

## Secure Delivery Contract References

- Power Platform solutions and reports must consume the shared runtime-neutral
  contract in [`public-api-contract.md`](./public-api-contract.md).
- Command handlers and connectors must pass contract metadata explicitly:
  `contract_version`, `calculator_id`, `pricing_year`, input payload, and a
  traceable fixture identifier for auditable payload lineage.
- Power Platform should never persist calculator math or output schema definitions
  inside tables, flows, or canvas logic.
- Data refresh and report orchestration must not bypass the service boundary for
  calculation operations.

## Delivery Surface Command Split

- Use `pac` for Power Platform lifecycle operations (environments, solution
  pack/unpack, checker, import/export, publish, ALM transitions).
- Use `powerbi` for reporting surface operations (workspace discovery, dataset or
  report import/export, and report operations).
- Keep both surfaces read-only with respect to calculation semantics: actual scoring
  calls must come through a secured service boundary.

## Repository Artifacts and Boundaries

- Repository artifacts for Power Platform and Power BI should be represented as
  declarative files tracked in source control and deployable by CLI operations.
- Do not place executable calculation logic in managed solution assets, Power BI
  reports, or dataset expressions.
