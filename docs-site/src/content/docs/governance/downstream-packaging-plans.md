---
title: Downstream packaging plans
---

Packaging for R, Julia, C#, Go, Power Platform, and the TypeScript/WASM
browser demo stays thin and contract driven. None of these surfaces should
duplicate calculator formulas.

Rules:

- R should start with a thin wrapper over the shared CLI plus CSV file
  exchange, with Arrow/Parquet deferred until the shared file contract exists.
- R Markdown and Quarto examples should use synthetic fixture data and read
  back shared outputs only.
- Keep the R surface wrapper-only; do not reimplement formulas, adjustment
  logic, or validation rules in R.
- Treat CRAN packaging as deferred until the install posture, dependency
  checks, and package skeleton are stable.
- Julia should start with a thin CLI/file wrapper, using CSV for the executable
  prototype and `DataFrames.jl` plus `Arrow.jl` around the target interchange
  workflow once the shared Arrow contract exists. Treat C ABI, `ccall`, and
  `jlrs` as later options only if native embedding becomes necessary.
- C ABI consumers should use a stable C boundary or a secured service
  boundary. Any native integration must document ownership, allocator
  responsibilities, and error translation before it is embedded in an
  institution's runtime.
- C# should prefer a stable ABI or secured service boundary.
- Go should prefer a C ABI wrapper or secured service boundary.
- Power Platform should use a custom connector or service boundary only.
- The TypeScript/WASM browser demo should stay synthetic, browser-only, and
  wrapper-only. Use WASM as the runtime target, keep Node limited to build and
  developer tooling, and keep browser bundle size under a practical demo
  budget.
- Browser privacy limits apply: do not treat the client as a trusted data
  store, do not cache patient-level data, and keep any telemetry synthetic only.
- Keep all formula and validation logic in the shared engine; do not duplicate
  calculator rules in TypeScript just to make the browser demo easier.
- Release readiness depends on shared fixture parity, stable contract
  versioning, and Arrow-boundary consistency across all downstream surfaces.
- For C ABI consumers, keep fixture parity with the shared engine, preserve
  Arrow as the boundary for tabular exchange where possible, and avoid formula
  duplication in the native wrapper.

See also the C ABI consumer guide in
[tutorials/c-abi-consumers](../tutorials/c-abi-consumers.mdx).

See the canonical source in
[Conductor downstream-packaging-plans.md](../../../../conductor/downstream-packaging-plans.md).
