# AR-DRG ICD/ACHI/ACS mapping registry contract fixtures

This directory contains synthetic fixtures for the AR-DRG ICD/ACHI/ACS mapping registry contract.

## Contents

- `ar-drg-icd-mapping-registry.schema.json`: JSON Schema for the contract bundle.
- `ar-drg-icd-mapping-registry.contract.json`: Contract document describing the registry surface, metadata-only records, license boundary, and external grouper references.
- `examples/versioned-mapping-registry.json`: Synthetic version-specific mapping registry records.
- `examples/license-boundary.json`: Synthetic license-boundary declaration.
- `examples/external-grouper-reference.json`: Synthetic external grouper reference manifest.

## Scope

These fixtures are metadata only. They do not contain licensed mapping tables, grouper logic, code rows, patient data, or production registry extracts.

Use them to exercise parsing, version compatibility checks, provenance handling, and local reference workflows without embedding restricted content.

## Rules

- Keep all examples synthetic.
- Do not add licensed tables, code values, or live registry exports.
- Do not add PHI, private study data, or operational extracts.
- Keep external grouper references as local placeholders or metadata-only descriptors.
