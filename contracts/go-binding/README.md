# Go binding contract fixtures

This directory contains synthetic metadata-only fixtures for the Go binding
workstream.

## Contents

- `go-binding.schema.json`: JSON Schema for the Go binding contract bundle.
- `go-binding.contract.json`: Contract document describing request/response
  structs, service and CLI/Arrow-file fallback, diagnostics, provenance,
  errors, fixture gates, and module readiness.
- `examples/cli-arrow.pass.json`: Synthetic CLI/Arrow-file primary pass
  example.
- `examples/service.pass.json`: Synthetic service-bound fallback pass example.
  example.
- `examples/diagnostics.pass.json`: Synthetic diagnostics pass example.
- `examples/binding.fail.json`: Synthetic binding failure example.
- `examples/diagnostics.fail.json`: Synthetic diagnostics failure example.

## Scope

These fixtures are metadata only. They do not include calculator logic,
generated code, production outputs, patient data, or licensed payloads.

The request and response shapes are aligned to the public calculator contract
and describe transport-specific fields for the Go binding surface only.

## Rules

- Keep all committed examples synthetic.
- Mirror the public calculator contract fields explicitly.
- Prefer CLI/Arrow-file first for portable batch and offline handoff; use the
  service boundary when a caller needs online request/response behavior.
- Keep diagnostics, provenance, and errors explicit and machine readable.
- Keep fixture gates local-only and user-supplied.
- Do not embed formula logic or duplicate calculator rules in the Go binding
  contract.
