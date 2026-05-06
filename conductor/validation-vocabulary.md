# Validation Vocabulary

## Core Terms

`Archived` means source material exists in the project archive or approved external storage.

`Extracted` means project tooling has parsed source material into project-usable data, such as Arrow, Parquet, JSON, or structured metadata.

`Implemented` means project code contains calculator behavior for a calculator, pricing year, or adjustment.

`Validated` means behavior has been checked against trusted source logic or trusted reference output and the evidence is recorded in a manifest or validation registry.

`Fixture manifest` means a JSON record that declares a fixture pack's calculator, pricing year, service stream, parity type, source basis, tolerance, rounding policy, privacy classification, and payload metadata.

`Fixture pack` means a manifest plus its resolved payload files, treated as the unit of cross-language validation.

`Fixture runner` means the Python, C#, web, or other tool that loads a fixture manifest and executes the same fixture pack against an implementation.

`Cross-language ready` means a fixture pack or manifest uses runner-neutral field names, explicit types, and payload formats that can be consumed by Python, C#, and web tooling without translation.

`Fixture pack validated` means a fixture pack has been loaded by the shared reader, its manifest and payloads have passed schema checks, and the evidence is recorded.

## Parity Types

`Source parity` means implementation logic has been compared against source logic such as SAS programs, Excel formulas, compiled references, or Python reference files.

`Output parity` means implementation outputs match trusted reference outputs for defined fixtures.

`Regression parity` means existing known-good outputs remain stable across refactors and dependency changes.

`Cross-engine parity` means Python, C#, web, and any generated calculation engines produce equivalent outputs for the same golden fixtures.

`Fixture parity` means an implementation produces the expected outputs for a validated fixture pack using the declared tolerance and rounding policy.

`Manifest parity` means a fixture manifest can be parsed and validated by all supported runners without runner-specific translation.

## Evidence-Backed Claims

Any validation claim should be backed by a structured record with at least these fields:

- Calculator name.
- Pricing year.
- Service stream.
- Claim type, such as source parity, output parity, regression parity, cross-engine parity, fixture parity, or manifest parity.
- Source basis, including the source artifact IDs and checksums used for the claim.
- Fixture pack identifier, fixture manifest identifier, or validation bundle identifier.
- Cross-language readiness flag when the pack is intended for more than one runner.
- Tolerance or comparison rule.
- Rounding policy.
- Run timestamp.
- Command, workflow, or pipeline identifier.
- Reviewer or approver, when human sign-off is required.
- Result summary and linked evidence location.

Prefer precise claims such as "2024 acute output-parity validated against fixture pack `acute-2024-v3`" or "fixture manifest `acute-2024-v3` is cross-language ready" rather than broad year-level support claims.

## Claims Policy

Do not use broad year-level support language unless the support type is stated and the evidence record is available.

If SAS, Excel, and another reference source disagree, document the disagreement and identify which source is treated as authoritative for the affected behavior.
