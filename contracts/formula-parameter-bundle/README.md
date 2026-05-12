# Formula and parameter bundle contract fixtures

This directory contains synthetic fixtures for the `formula-parameter-bundle` contract.

## Files

- `formula-parameter-bundle.schema.json`: JSON Schema for the contract bundle.
- `formula-parameter-bundle.contract.json`: Contract document describing the bundle and diff surface.
- `examples/bundle.json`: Synthetic bundle example with formulas, weights, thresholds, adjustments, provenance, validation evidence, and status.
- `examples/bundle-diff.json`: Synthetic diff example between two bundle versions.

## Scope

These fixtures model a source-only formula and parameter bundle plus the diff view used to compare versions. They are synthetic only, do not contain production data, and do not claim calculator parity.

## Rules

- Keep all values synthetic.
- Do not add PHI, private study data, or operational extracts.
- Keep formulas, weights, thresholds, adjustments, provenance, validation evidence, and status fields aligned across the schema, contract, and examples.
- Keep the diff example focused on version-to-version change summary rather than large tables.
