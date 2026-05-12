# Pricing-year validation contract fixtures

This directory contains synthetic fixtures for the `funding-calculator validate-year <year>` command.

## Files

- `pricing-year-validation.schema.json`: JSON Schema for the contract bundle.
- `pricing-year-validation.contract.json`: Contract document for pricing-year validation gates.
- `examples/validate-year.pass.json`: Synthetic output showing a successful validation run.
- `examples/validate-year.fail.json`: Synthetic output showing a failed validation run.

## CLI

The command surface represented here is:

```bash
funding-calculator validate-year <year>
```

The committed examples are synthetic and intended for contract tests, parsing checks, and reviewer guidance.

## Scope

These fixtures describe validation-state reporting only. They do not contain live reference data, downloaded artifacts, or production validation output.

## Rules

- Keep all examples synthetic.
- Do not add PHI, private study data, or operational extracts.
- Keep command naming aligned to `funding-calculator validate-year <year>`.
