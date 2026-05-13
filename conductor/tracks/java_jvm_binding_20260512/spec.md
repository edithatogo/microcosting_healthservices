# Specification: Kotlin/JVM Binding

## Overview
Provide a Kotlin-first JVM integration roadmap for enterprise data platforms
and JVM-based analytics stacks. Kotlin is the primary authoring surface; Java
compatibility is an interoperability requirement, not the preferred scaffold.
The JVM surface should consume the shared Rust core through service, JNI/JNA,
C ABI, or Arrow/Parquet file interop and must not duplicate formula logic.

## Functional Requirements
- Evaluate service boundary, JNI/JNA over C ABI, and Arrow/Parquet file interop.
- Define Kotlin data classes with Java-compatible JVM bytecode boundaries.
- Reuse shared golden fixtures and schema conformance tests.
- Document Gradle/Maven publication only after stability gates are met.

## Strategy Notes

- Initial strategy: Arrow / Parquet file interop, selected to minimize binary
  packaging risk and native distribution complexity for the first JVM
  delivery.
- Fallback strategy: service boundary, for callers that need online
  request/response behavior or persistent hosting.
- Deferred strategy: JNI / JNA over C ABI, until ABI stability, memory
  ownership, and native packaging portability are proven.
- Kotlin-first API guidance: prefer immutable data classes, explicit nullability,
  schema/version fields, and thin adapters; use `BigDecimal` for values that
  must not absorb binary floating-point drift.

## Acceptance Criteria
- JVM integration strategy is selected and documented.
- JVM examples validate against shared fixtures.
- Formula logic remains single-sourced.
