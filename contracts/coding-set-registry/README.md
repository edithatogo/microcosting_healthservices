# Coding-set registry contract fixtures

This directory contains synthetic fixtures for the coding-set registry contract.

## Contents

- `coding-set-registry.schema.json`: JSON Schema for the contract bundle.
- `coding-set-registry.contract.json`: Contract document describing the registry surface, metadata-only entries, and compatibility validation outputs.
- `examples/registry-entries.json`: Synthetic registry entry listing.
- `examples/compatibility-validation.pass.json`: Synthetic compatibility validation success example.
- `examples/compatibility-validation.fail.json`: Synthetic compatibility validation failure example.

## Scope

These fixtures are metadata only. They do not contain licensed code tables, code rows, patient data, or production registry extracts.

Use them to exercise parsing, compatibility checks, and review workflows without embedding copyrighted table content.

## Rules

- Keep all examples synthetic.
- Do not add licensed code tables, code values, or live registry exports.
- Do not add PHI, private study data, or operational extracts.
- Keep compatibility examples focused on registry metadata and support windows only.
