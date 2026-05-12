---
title: Downstream packaging plans
---

Packaging for R, Julia, C#, Go, and Power Platform stays thin and contract
driven. None of these surfaces should duplicate calculator formulas.

Rules:

- R should start with a thin wrapper over the shared CLI plus CSV file
  exchange, with Arrow/Parquet deferred until the shared file contract exists.
- R Markdown and Quarto examples should use synthetic fixture data and read
  back shared outputs only.
- Keep the R surface wrapper-only; do not reimplement formulas, adjustment
  logic, or validation rules in R.
- Treat CRAN packaging as deferred until the install posture, dependency
  checks, and package skeleton are stable.
- Julia should evaluate `jlrs` or a `ccall` wrapper.
- C# should prefer a stable ABI or secured service boundary.
- Go should prefer a C ABI wrapper or secured service boundary.
- Power Platform should use a custom connector or service boundary only.
- Release readiness depends on shared fixture parity and stable contract
  versioning.

See the canonical source in
[Conductor downstream-packaging-plans.md](../../../../conductor/downstream-packaging-plans.md).
