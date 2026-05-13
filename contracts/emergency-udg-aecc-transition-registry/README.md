# Emergency UDG/AECC transition registry contract fixtures

This directory contains synthetic fixtures for the Emergency UDG/AECC transition registry contract.

## Contents

- `emergency-udg-aecc-transition-registry.schema.json`: JSON Schema for the contract bundle.
- `emergency-udg-aecc-transition-registry.contract.json`: Contract document describing version windows, stream compatibility, diagnostics, and the no-proprietary-payload boundary.
- `examples/versioned-transition-registry.json`: Synthetic registry snapshot with UDG and AECC transition metadata.
- `examples/validation-pass.json`: Synthetic compatibility validation success example.
- `examples/validation-fail.json`: Synthetic compatibility validation failure example.
- `examples/diagnostics.json`: Synthetic diagnostics report covering missing classification and metadata-only checks.
- `examples/no-proprietary-payload-boundary.json`: Synthetic boundary declaration for restricted-content exclusion.

## Scope

These fixtures are metadata only. They do not contain UDG tables, AECC tables, mapping tables, source code rows, grouper payloads, patient data, or operational extracts.

Use them to exercise parsing, year compatibility checks, stream compatibility checks, provenance handling, and local reference workflows without embedding restricted content.

## Rules

- Keep all examples synthetic.
- Do not add licensed UDG or AECC table content, code rows, or grouper outputs.
- Do not add PHI, private study data, or operational extracts.
- Do not silently translate UDG to AECC unless a committed official or validated local mapping reference is supplied.
- Keep proprietary payload boundaries explicit in both contract and examples.
