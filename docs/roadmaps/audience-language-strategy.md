# Audience and Language Strategy

The project should not try to support every language equally. The language
roadmap should be governed by two primary audiences and one rule: no adapter may
own formula logic.

## Primary audiences

### Researchers

Researchers need reproducibility, transparent evidence, and familiar analysis
workflows.

Priority surfaces:

- Python.
- R.
- CLI/file.
- Arrow/Parquet.
- Quarto/Jupyter documentation.
- Julia where existing binding work can be retained.

Conditional surfaces:

- SAS interoperability for parity and legacy institutional datasets.
- Stata interoperability for health-economics and econometric workflows.

### Enterprise engineers

Enterprise engineers need stable contracts, deployment boundaries, and release
evidence.

Priority surfaces:

- Rust crate.
- HTTP API.
- Python binding.
- TypeScript/WASM for browser or edge deployment.
- C#/.NET for Power Platform and Microsoft enterprise integration.
- MCP and OpenAI tool adapters for agentic workflows.

Conditional surfaces:

- TypeScript/WASM for GitHub Pages demos and optional web delivery.
- Power Platform where service boundaries are approved.

## Deprioritized by default

These should not block Rust Core GA:

- Scala/Spark.
- Swift.
- MATLAB.
- Go.
- Standalone C language support.
- SQL/DuckDB as an active surface.
- Additional language bindings without a named audience, sponsor, and test
  owner.

## Promotion criteria

A language or surface can move forward only when it has:

- A clearly named audience.
- A maintainer or owner.
- A thin-binding design.
- Contract tests against canonical schemas.
- Parity fixtures.
- Documentation and examples.
- Packaging and release evidence.

## Recommended strategy

The immediate implementation strategy should be:

1. Rust Core GA.
2. Canonical domain schemas.
3. CLI/file contracts.
4. HTTP API contract.
5. MCP contract.
6. OpenAI tool adapter.
7. HWAU terminology and state/local pricing registry.
8. Parallel national, state, local, and discounted valuation outputs.
9. Conditional languages only after evidence and demand.
