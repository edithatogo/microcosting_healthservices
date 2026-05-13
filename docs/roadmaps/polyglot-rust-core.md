# Polyglot Rust Core Roadmap

This roadmap documents the current Python-first state, the intended Rust-core
target state, and the sequencing tracks that govern the transition.

## Current state

- Python remains the validated runtime path for published calculator behavior.
- Rust is an opt-in target, not the default runtime.
- Public documentation should describe implemented behavior and separate it
  from future work and validation evidence.

## Target state

- A shared Rust calculator core becomes the single source of formula logic.
- Thin bindings and adapters expose that core to Python, Rust, R, Julia,
  C#/.NET, Go, TypeScript/WASM, Kotlin/Native, C ABI, SQL/DuckDB, SAS interop,
  CLI/file workflows, web surfaces, and Power Platform orchestration.
- Additional FOSS-facing roadmap surfaces include Kotlin/Native, Scala/Spark,
  Swift, Stata, and MATLAB. These are contract/file/service consumers, not
  independent formula implementations.
- Python remains supported while parity evidence is incomplete.
- Rust becomes the default runtime only after fixture parity, packaging,
  documentation, and binding contracts are complete.

## Roadmap tracks

| Track family | Track link | Why it matters |
| --- | --- | --- |
| Binding | [Python Rust Binding Stabilization](../../conductor/tracks/python_rust_binding_stabilization_20260512/spec.md) | Defines the opt-in Python boundary over the Rust core and the fallback rules while parity is still in progress. |
| Abstraction | [Abstraction Doctrine Enforcement](../../conductor/tracks/abstraction_doctrine_enforcement_20260512/spec.md) | Establishes the canonical kernel boundary so formulas, adapters, and docs stay aligned. |
| Source-manifest | [Reference Data Manifest Schema](../../conductor/tracks/reference_data_manifest_schema_20260512/spec.md) | Defines the year-scoped manifest shape that records sources, gaps, provenance, and validation status. |
| Formula-bundle | [Formula and Parameter Bundle Pipeline](../../conductor/tracks/formula_parameter_bundle_pipeline_20260512/spec.md) | Provides the extraction, versioning, and validation pipeline for formula and parameter bundles. |
| Validation-gate | [Pricing-Year Validation Gates](../../conductor/tracks/pricing_year_validation_gates_20260512/spec.md) | Prevents unsupported support claims until the required source and fixture evidence exists. |

## Sequencing guidance

1. Lock the abstraction boundary first so formulas stay single-sourced.
2. Make source manifests and formula bundles explicit before widening adapter
   coverage.
3. Stabilize the Python binding over the Rust core while Rust remains
   opt-in.
4. Keep validation gates conservative so docs never outrun the evidence.

## Documentation rule

This roadmap is a documentation integration artifact. It should be read as a
status and sequencing guide, not as proof that the Rust core or any downstream
binding is complete.
