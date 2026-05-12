# Pricing-year diff contract fixtures

This directory contains synthetic fixtures for the `funding-calculator diff-year <from-year> <to-year>` command.

## Files

- `pricing-year-diff.schema.json`: JSON Schema for the contract bundle.
- `pricing-year-diff.contract.json`: Contract document for pricing-year diff tooling.
- `examples/diff-year.markdown.md`: Synthetic markdown diff output.
- `examples/diff-year.json`: Synthetic JSON diff output.

## CLI

The command surface represented here is:

```bash
funding-calculator diff-year <from-year> <to-year>
```

The committed examples are synthetic and intended for contract tests, parsing checks, and reviewer guidance.

## Scope

These fixtures describe year-to-year comparison output only. They do not contain live reference data, downloaded artifacts, or production diff output.

## Rules

- Keep all examples synthetic.
- Do not add PHI, private study data, or operational extracts.
- Keep command naming aligned to `funding-calculator diff-year <from-year> <to-year>`.
- Keep diff summaries conservative and avoid dumping large tables by default.
