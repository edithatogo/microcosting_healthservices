# Validation Vocabulary

## Core Terms

`Archived` means source material exists in the project archive or approved external storage.

`Extracted` means project tooling has parsed source material into project-usable data, such as Arrow, Parquet, JSON, or structured metadata.

`Implemented` means project code contains calculator behavior for a calculator, pricing year, or adjustment.

`Validated` means behavior has been checked against trusted source logic or trusted reference output.

## Parity Types

`Source parity` means implementation logic has been compared against source logic such as SAS programs, Excel formulas, compiled references, or Python reference files.

`Output parity` means implementation outputs match trusted reference outputs for defined fixtures.

`Regression parity` means existing known-good outputs remain stable across refactors and dependency changes.

`Cross-engine parity` means Python, C#, web, and any generated calculation engines produce equivalent outputs for the same golden fixtures.

## Claims Policy

Do not use broad language such as "supports 2024" unless the support type is stated. Prefer precise claims such as "2024 acute is implemented and output-validated against fixture set X."

If SAS, Excel, and another reference source disagree, document the disagreement and identify which source is treated as authoritative for the affected behavior.

