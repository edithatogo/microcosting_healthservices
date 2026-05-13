# Emergency code mapping pipeline contract fixtures

This directory contains synthetic fixtures for the Emergency Code Mapping Pipeline contract.

## Contents

- `emergency-code-mapping-pipeline.schema.json`: JSON Schema for the contract bundle.
- `emergency-code-mapping-pipeline.contract.json`: Contract document describing the mapping bundle manifest, dry-run summaries, diagnostics, local-only references, and the no-proprietary-payload boundary.
- `examples/mapping-bundle-manifest.json`: Synthetic versioned manifest with UDG and AECC bundle metadata.
- `examples/dry-run-mapping-summary.json`: Synthetic dry-run summary covering mapped, unmapped, deprecated, invalid, and version-incompatible records.
- `examples/diagnostics.json`: Synthetic diagnostics report for provenance, source-field, and boundary checks.
- `examples/local-only-external-mapping-placeholder.json`: Synthetic local-only placeholder for an external mapping table or service.
- `examples/no-proprietary-payload-boundary.json`: Synthetic boundary declaration that excludes proprietary payloads and restricted mappings.

## Scope

These fixtures are metadata only. They do not contain source tables, proprietary mapping payloads, code rows, patient data, production extracts, or implementation logic.

Use them to exercise parsing, version compatibility checks, provenance handling, dry-run summaries, and local reference workflows without embedding restricted content.

## Rules

- Keep all examples synthetic.
- Do not add proprietary mapping tables, code rows, or production mapping outputs.
- Do not add PHI, private study data, or operational extracts.
- Do not silently invent crosswalks between UDG and AECC outputs.
- Keep external mapping references as local-only placeholders or metadata-only descriptors.
