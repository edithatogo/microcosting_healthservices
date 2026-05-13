# Specification: Kotlin/Native Binding

## Overview
Provide a Kotlin/Native integration roadmap for enterprise data platforms
and native analytics stacks. Kotlin is the primary authoring surface; Java
compatibility is an interoperability requirement, not the preferred scaffold.
The Kotlin/Native surface should consume the shared Rust core through service, C ABI,
C ABI, or Arrow/Parquet file interop and must not duplicate formula logic.

## Functional Requirements
- Evaluate service boundary, C ABI over C ABI, and Arrow/Parquet file interop.
- Define Kotlin data classes with C ABI, service, and file-contract boundaries.
- Reuse shared golden fixtures and schema conformance tests.
- Document Kotlin/Native package publication only after stability gates are met.

## Strategy Notes

- Initial strategy: Arrow / Parquet file interop, selected to minimize binary
  packaging risk and native distribution complexity for the first native
  delivery.
- Fallback strategy: service boundary, for callers that need online
  request/response behavior or persistent hosting.
- Deferred strategy: C ABI, until ABI stability, memory
  ownership, and native packaging portability are proven.
- Kotlin-first API guidance: prefer immutable data classes, explicit nullability,
  schema/version fields, and thin adapters; use `BigDecimal` for values that
  must not absorb binary floating-point drift.

## Acceptance Criteria
- Kotlin/Native integration strategy is selected and documented.
- Kotlin/Native examples validate against shared fixtures.
- Formula logic remains single-sourced.
