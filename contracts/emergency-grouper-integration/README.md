# Emergency Grouper Integration contract fixtures

This directory contains synthetic fixtures for the Emergency Grouper Integration contract.

## Contents

- `emergency-grouper-integration.schema.json`: JSON Schema for the contract bundle.
- `emergency-grouper-integration.contract.json`: Contract document describing precomputed output manifests, local-only grouper/service references, compatibility diagnostics, and the no-proprietary-payload boundary.
- `examples/precomputed-output-manifest.json`: Synthetic manifest for precomputed emergency classification outputs.
- `examples/external-local-grouper-service-reference.json`: Synthetic local-only reference for a user-supplied grouper or service.
- `examples/compatibility-diagnostics.json`: Synthetic diagnostics report covering version and boundary checks.
- `examples/no-proprietary-payload-boundary.json`: Synthetic boundary declaration that excludes proprietary payloads and restricted grouper content.

## Scope

These fixtures are metadata only. They do not contain proprietary grouper logic, licensed tables, patient data, production extracts, or implementation details for emergency classification.

Use them to exercise parsing, pricing-year compatibility checks, provenance handling, local reference workflows, and boundary validation without embedding restricted content.

## Rules

- Keep all examples synthetic.
- Do not add proprietary grouper logic, licensed tables, or production outputs.
- Do not add PHI, private study data, or operational extracts.
- Do not silently translate between UDG and AECC unless the manifest explicitly declares the source provenance.
- Keep external grouper and service references as local-only placeholders or metadata-only descriptors.
