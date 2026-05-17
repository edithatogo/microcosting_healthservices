# Canonical Contract Schemas

This directory contains the *canonical* JSON Schema definitions for the MCHS (Micro-Costing Health Services) system. All surface contracts (CLI, HTTP API, MCP, OpenAI adapter) derive from these canonical schemas.

## Schema Set

| File | Schema | Description |
|---|---|---|
| `calculator.schema.json` | Calculator | Identifies a micro-costing calculator, its supported AR-DRG streams, financial years, and input/output schema references |
| `diagnostics.schema.json` | Diagnostics | Structured validation and error reporting with severity, code, path, and value |
| `provenance.schema.json` | Provenance | Metadata about data origin, schema version, generation timestamp, and input digest |
| `support-status.schema.json` | Support Status | Lifecycle status (active/deprecated/retired) for stream/year combinations |
| `evidence.schema.json` | Evidence Bundle | References to cost weights, data sources, methodology documents, and assumptions |

## Conventions

- All schemas use **JSON Schema draft/2020-12**.
- All `$id` values use the `https://mchs.example.org/schemas/` base URI.
- Cross-schema references use relative `$ref` URIs (e.g., `"$ref": "provenance.schema.json"`).
- Required fields are enforced via `"required"` arrays.
- `"additionalProperties": false` is set on all objects to ensure strict conformance.
- Examples are provided in `examples/` for both valid and invalid payloads.

## Design Principles

1. **Canonical first** — All surface contracts are generated or derived from these schemas.
2. **Conservative scope** — Only essential properties are defined; no speculative fields.
3. **No formula logic** — Schemas define data shapes only, not computation rules.
4. **Synthetic data** — All examples use fictitious values.
5. **Provenance everywhere** — Wherever data is tracked, provenance is referenceable.

## Usage

Clients should treat these schemas as the authoritative source of truth. Surface contracts (OpenAPI, MCP tools, CLI flags) should map to these canonical types. Validation of any input or output should use these schemas as the primary reference.
