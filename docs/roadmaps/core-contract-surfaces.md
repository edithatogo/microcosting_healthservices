# Core Contract Surfaces Roadmap

The Rust Core GA path requires stable contracts before more language surfaces
are added. The canonical order is:

1. Canonical domain schemas.
2. CLI/file contracts.
3. HTTP API contract.
4. MCP contract.
5. OpenAI tool adapter.

## Canonical domain schemas

These are the source of truth for every surface:

- Calculator request and response.
- Stream and pricing-year support status.
- Source manifest and formula/parameter bundle references.
- Coding-set and classifier references.
- Diagnostics, errors, and provenance.
- Batch input/output schemas.
- Evidence bundle and release status.

The canonical schemas should be JSON Schema and OpenAPI-compatible. Arrow and
Parquet schemas should be derived from the same contract rather than maintained
separately.

## CLI/file contracts

The CLI/file layer is the first stable execution boundary because it is
auditable, batch-friendly, and useful for both researchers and enterprise
engineers.

Required commands:

- `mchs schema`
- `mchs validate`
- `mchs run`
- `mchs explain`
- `mchs list-calculators`
- `mchs list-streams`
- `mchs list-years`
- `mchs diagnose`

Required guarantees:

- Stable exit codes.
- Machine-readable `--json` output.
- Documented stdin/stdout/stderr behavior.
- JSON manifest plus Arrow/Parquet batch data.
- Deterministic diagnostics and provenance.

## HTTP API contract

The project should expose a domain API rather than pretending to be an LLM API.

Recommended resources:

- `GET /v1/calculators`
- `GET /v1/calculators/{calculator_id}`
- `GET /v1/schemas/{schema_name}`
- `POST /v1/validate`
- `POST /v1/calculations`
- `POST /v1/jobs`
- `GET /v1/jobs/{job_id}`
- `GET /v1/jobs/{job_id}/results`
- `GET /v1/evidence/{release_id}`

The API contract should be OpenAPI 3.1, generated from or validated against the
canonical domain schemas.

## MCP contract

MCP should be agent-facing and schema-driven. It should not define calculator
truth.

Recommended tools:

- `mchs.list_calculators`
- `mchs.get_schema`
- `mchs.validate_input`
- `mchs.calculate`
- `mchs.explain_result`
- `mchs.get_evidence`

Recommended resources:

- Calculator schemas.
- Support-status matrix.
- Evidence bundles.
- Public documentation links.

## OpenAI adapter

OpenAI compatibility should be a thin adapter over MCP/API tools, not the
canonical interface.

Recommended approach:

- Publish OpenAI tool definitions generated from canonical schemas.
- Support Responses-style tool use through the API/MCP adapter.
- Avoid exposing `/v1/chat/completions` or `/v1/responses` as if the calculator
  were an LLM.
- Keep model prompts and orchestration outside the calculator core.

## Audience-driven surface priorities

Researchers need reproducible batch workflows:

- Python.
- R.
- Julia.
- CLI/file.
- Arrow/Parquet.
- Quarto/Jupyter tutorials.
- SAS/Stata interop where validation, health-economics, or legacy workflows
  justify them.

Enterprise engineers need stable integration boundaries:

- Rust crate.
- HTTP API.
- Python binding for platform teams.
- TypeScript/WASM where GitHub Pages demos or web embedding require it.
- C#/.NET where Power Platform and Microsoft enterprise integration justify it.
- MCP/OpenAI adapters for agent integration.

Deferred or no-new-development languages should remain visible in the roadmap
but should not receive implementation work until user demand, maintainer
capacity, and core contract maturity justify them.
