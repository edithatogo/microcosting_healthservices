# Rust Crate Boundaries and HWAU Rename Plan

> Parallel-agent notice: Cline/deepseek may be editing Rust crates. This file
> is planning guidance only; do not bulk-rename crate code without coordinating
> with the active Rust implementation lane.

## Target crate boundaries

- `mchs-contracts`: canonical schemas, support status, diagnostics, errors,
  provenance, evidence models.
- `mchs-core`: Rust formula kernels, registries, HWAU outputs, valuation
  orchestration, stream/year support.
- `mchs-cli`: command-line and file execution surface.
- `mchs-mcp`: Rust-backed MCP server.
- `mchs-api`: HTTP API server or API contract implementation.
- `mchs-python`: Python binding.
- `mchs-dotnet`: .NET/C# binding or generated package boundary.
- `mchs-wasm`: optional TypeScript/WASM browser/demo surface.

## Rename policy

- Public generic APIs should use `hwau`.
- Australian source-specific aliases may use `nwau`.
- Existing `nwau-*` crates should not be blindly renamed while active Rust work
  is in progress.
- Rename should happen through compatibility shims, deprecation notes, and
  migration tests.

## No standalone C commitment

C ABI may exist as an implementation boundary where required, but standalone C
language support is not an active user-facing surface.
