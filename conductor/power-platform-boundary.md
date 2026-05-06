# Power Platform Boundary

## Purpose

Power Platform should orchestrate calculator workflows, not contain calculator
logic.

## Boundary Rules

- Inputs should map to the public calculator contract.
- Outputs and errors should be structured for workflow apps.
- Calculation should happen in the C# service boundary.
- The calculation should happen in the C# service boundary, not in Power
  Platform formulas.
- Dataverse and Power Platform should remain orchestration and storage layers
  only.

## Integration Shape

- A Custom Connector or Azure Function can expose the service boundary.
- The connector should consume contract identifiers and fixture identifiers.
- Real-data workflows must remain behind the secured service boundary.
