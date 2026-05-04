# Validation Vocabulary

## Core Terms

`Archived` means source material exists in the project archive or approved external storage.

`Extracted` means project tooling has parsed source material into project-usable data, such as Arrow, Parquet, JSON, or structured metadata.

`Implemented` means project code contains calculator behavior for a calculator, pricing year, or adjustment.

`Validated` means behavior has been checked against trusted source logic or trusted reference output and the evidence is recorded in a manifest or validation registry.

## Parity Types

`Source parity` means implementation logic has been compared against source logic such as SAS programs, Excel formulas, compiled references, or Python reference files.

`Output parity` means implementation outputs match trusted reference outputs for defined fixtures.

`Regression parity` means existing known-good outputs remain stable across refactors and dependency changes.

`Cross-engine parity` means Python, C#, web, and any generated calculation engines produce equivalent outputs for the same golden fixtures.

## Evidence-Backed Claims

Any validation claim should be backed by a structured record with at least these fields:

- Calculator name.
- Pricing year.
- Service stream.
- Claim type, such as source parity, output parity, regression parity, or cross-engine parity.
- Source basis, including the source artifact IDs and checksums used for the claim.
- Fixture set identifier or validation bundle identifier.
- Tolerance or comparison rule.
- Run timestamp.
- Command, workflow, or pipeline identifier.
- Reviewer or approver, when human sign-off is required.
- Result summary and linked evidence location.

Prefer precise claims such as "2024 acute output-parity validated against fixture bundle `acute-2024-v3`" rather than broad statements like "supports 2024".

## Claims Policy

Do not use broad language such as "supports 2024" unless the support type is stated and the evidence record is available.

If SAS, Excel, and another reference source disagree, document the disagreement and identify which source is treated as authoritative for the affected behavior.
