---
title: Kotlin/Native binding
description: Governance rules for the native Kotlin binding boundary.
---

# Kotlin/Native binding

The Kotlin/Native binding is a downstream adapter over the public calculator
contract. It must not become a second formula engine.

## Boundary

- Use Kotlin/Native for native request, response, diagnostics, and error models.
- Use C ABI, Arrow/Parquet file contracts, or service calls to reach the shared
  calculator core.
- Keep formula logic, reference tables, coding maps, and adjustment rules in the
  shared core or versioned data layer.
- Treat Java/JVM integration as deferred and outside this track.

## Validation

- Validate all examples against the same golden fixtures used by the core.
- Fail closed on schema version, calculator identifier, pricing year, or column
  contract drift.
- Preserve provenance for source contract path, checksum, retrieved date, and
  transport used.
- Keep negative fixtures that prove publication overclaims and formula
  duplication are rejected.

## Publication gates

Kotlin/Native artifact publication remains private until:

- The native target matrix is explicit.
- C ABI ownership and memory-safety rules are versioned.
- File-contract interchange has round-trip fixture coverage.
- CI can reproduce the artifact and attach provenance.
- Documentation states that the adapter is boundary-only.

No JVM runtime, Maven publication, or Gradle build is required by this track.
