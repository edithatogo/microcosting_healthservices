# Kotlin/Native Binding Roadmap

This roadmap defines Kotlin/Native as the preferred Kotlin surface for native
consumers. The binding is a thin adapter over shared contracts; it does not own
formula logic, reference data, or adjustment rules.

## Scope

- Provide Kotlin/Native request, response, diagnostics, and error models.
- Call the shared Rust core through a C ABI when native in-process execution is
  justified.
- Support Arrow/Parquet file interchange for reproducible batch validation.
- Support a service boundary when native linking is inappropriate.
- Keep Java/JVM integration outside this track.

## Strategy comparison

| Strategy | Strengths | Risks | Decision |
| --- | --- | --- | --- |
| C ABI | Native runtime boundary, thin Rust-core access, and good fit for mobile or desktop native clients. | Requires strict ownership, symbol, and memory-safety rules. | Initial native strategy after ABI contract review. |
| Arrow/Parquet file interop | Reproducible, inspectable, and strong for batch costing studies and golden fixtures. | Slower than in-process calls and less ergonomic for interactive APIs. | Initial validation and batch strategy. |
| Service boundary | Strong versioning, diagnostics, and centralized operations. | Requires service hosting and network availability. | Fallback for online request/response use. |

## Contract rules

- Kotlin/Native models must mirror the public calculator contract.
- Every example must validate against shared golden fixtures.
- The adapter must fail closed on schema version mismatch.
- Formula constants, thresholds, coding maps, and adjustment rules stay in the
  shared core or versioned reference-data layer.
- Publication is blocked until native target matrices and artifact provenance
  are documented.

## Build posture

This track does not require a JVM runtime, Maven publication, or a Gradle build
to be considered valid. Kotlin tooling choices can be revisited later, but the
published product boundary must remain native, service, or file-contract based.

## Acceptance gates

- Kotlin/Native scaffold exists and contains no formula implementation.
- Contract fixtures declare `surface: kotlin-native`.
- Shared validation covers pass and fail examples.
- Starlight documentation describes the native boundary and deferred JVM scope.
