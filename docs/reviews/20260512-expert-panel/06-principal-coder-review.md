# Simulated Principal Coder Review

## Role

Hands-on code reviewer focused on implementation detail, maintainability,
library ergonomics, and reducing future refactor cost.

## Findings

1. The repo needs less prose-only contract and more executable contract.
   Markdown is useful, but tests should enforce the contract.

2. Add narrow modules before broad abstractions.
   Start with `nwau_py.contracts`, `nwau_py.manifests`,
   `nwau_py.validation`, and `nwau_py.provenance`.

3. CLI commands should be thin and scriptable.
   Avoid interactive commands. Emit JSON and Markdown for audit outputs.

4. Do not let bindings own domain types independently.
   Generate or derive binding schemas from a shared contract wherever possible.

5. Keep docs examples tested.
   Tutorials should use checked snippets or fixture-backed scripts.

## Concrete Code Tasks

- Add Pydantic or equivalent models for manifests and evidence records.
- Add JSON Schema export for public contracts.
- Add `nwau validate-year --json`.
- Add `nwau diff-year --format json|markdown`.
- Add a `tests/contracts/` suite.
- Add denied-path tests for restricted classification artifacts.

## Priority Recommendation

Build the smallest executable contract layer and CLI validation commands before
any new calculator surface.
