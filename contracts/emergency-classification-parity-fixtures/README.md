# Emergency classification parity fixtures contract

Synthetic, metadata-only contract fixtures for emergency classification parity checks across UDG and AECC versions.

These examples describe fixture manifests, local-only official placeholders, compatibility diagnostics, downstream emergency NWAU behavior, and no-proprietary-payload boundaries. They do not contain licensed tables, raw official payloads, patient data, or classifier internals.

## Contents

- `emergency-classification-parity-fixtures.schema.json`: JSON Schema for the contract bundle.
- `emergency-classification-parity-fixtures.contract.json`: Contract document describing the fixture manifest, local-only official fixture placeholder, compatibility diagnostics, downstream NWAU behavior summary, and the no-proprietary-payload boundary.
- `examples/synthetic-fixture-manifest.json`: Synthetic fixture manifest with raw source fields, expected class result, downstream NWAU behavior, and provenance.
- `examples/local-official-fixture-placeholder.json`: Local-only placeholder for a licensed official fixture.
- `examples/compatibility-diagnostics.json`: Synthetic compatibility diagnostics report for UDG/AECC version alignment, transition authority, and boundary checks.
- `examples/downstream-emergency-nwau-behavior-summary.json`: Synthetic downstream NWAU behavior summary for the declared pricing year.
- `examples/no-proprietary-payload-boundary.json`: Synthetic boundary declaration that excludes proprietary payloads and restricted outputs.

## Scope

These fixtures are metadata only. They do not contain proprietary mapping tables, raw official reference payloads, patient data, production extracts, or implementation logic.

Use them to exercise parsing, family/version compatibility checks, transition-year behavior, downstream emergency NWAU summaries, and local reference workflows without embedding restricted content.

## Rules

- Keep all examples synthetic.
- Do not add proprietary classifier payloads, licensed tables, or production outputs.
- Do not add PHI, private study data, or operational extracts.
- Do not silently infer UDG or AECC crosswalks unless the fixture explicitly declares the family, version, and transition authority.
- Keep external official references as local-only placeholders or metadata-only descriptors.
