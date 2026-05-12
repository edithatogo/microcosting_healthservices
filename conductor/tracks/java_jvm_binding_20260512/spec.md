# Specification: Java/JVM Binding

## Overview
Provide a Java/JVM integration roadmap for enterprise data platforms and JVM-based analytics stacks. The JVM surface should consume the shared Rust core through service, JNI/JNA, C ABI, or Arrow/Parquet file interop and must not duplicate formula logic.

## Functional Requirements
- Evaluate service boundary, JNI/JNA over C ABI, and Arrow/Parquet file interop.
- Define Java/Kotlin-compatible request/response models.
- Reuse shared golden fixtures and schema conformance tests.
- Document Maven/Gradle publication only after stability gates are met.

## Acceptance Criteria
- JVM integration strategy is selected and documented.
- JVM examples validate against shared fixtures.
- Formula logic remains single-sourced.
