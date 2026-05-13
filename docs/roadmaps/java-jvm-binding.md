# Kotlin/JVM Binding Roadmap

Roadmap snapshot: 2026-05-13.

This document compares the candidate integration strategies for the Java/JVM
binding workstream and records the initial path, fallback, and guardrails. It
is roadmap-only: it does not introduce formula logic, and it does not claim a
production-ready binding.

## Scope

- Provide a Kotlin/JVM integration path for enterprise services, analytics
  jobs, and Kotlin-first consumers.
- Keep the shared Rust core as the only source of formula logic.
- Use the Kotlin/Java surface for transport, packaging, diagnostics, and host
  integration only.

## Comparison

| Strategy | Strengths | Costs | Best fit |
| --- | --- | --- | --- |
| Arrow / Parquet file interop | Lowest binary packaging risk: no JNI library distribution, no JVM-native symbol loading, and a contract that is easy to inspect, archive, and fixture-test. It works well across Kotlin and Java because both ecosystems already handle tabular and file-oriented data comfortably. | Slower than in-process calls and less ergonomic for fine-grained request/response flows. It adds file lifecycle management and is not ideal for synchronous interactive APIs. | Initial path for batch jobs, reproducible validation, and environments that need the safest cross-platform rollout. |
| Service boundary | Strong versioning and diagnostics; keeps the formula engine centralized; avoids native linking; and fits long-running JVM hosts that already call remote services. | Adds process and network hops, service availability requirements, and an operational surface to run and secure. | Fallback path when callers need online request/response behavior or a persistent endpoint. |
| JNI / JNA over C ABI | Lowest call overhead for in-process consumers and a natural fit for JVM applications that must embed the engine directly. | Highest binary packaging risk: native libraries, platform classifiers, ABI compatibility, memory ownership, and cross-platform build distribution all become first-order concerns. JNA reduces direct JNI code but does not remove the native packaging problem. | Deferred option for latency-sensitive embedding only after the ABI and packaging rules are stable. |

## Decision

Start with **Arrow / Parquet file interop** as the initial Kotlin/JVM strategy.

Use **service boundary** as the fallback when a caller needs online
request/response behavior, multi-step orchestration, or a persistent
endpoint.

Defer **JNI / JNA over C ABI** until the ABI, memory-ownership model, and
binary packaging rules are stable enough to justify native embedding.

## Why Arrow / Parquet file interop comes first

- It minimizes binary packaging risk by avoiding JNI or JNA artifact
  distribution in the first Java delivery.
- It keeps the calculator formulas in one place.
- It supports batch and offline usage without introducing a service runtime.
- It is the most predictable path for shared golden-fixture validation.
- It aligns with Kotlin and Java tooling that already understands immutable
  tabular models, schema evolution, and file-backed workflows.
- It keeps the initial maintenance burden low while the contract is still
  evolving.

## Kotlin-first API considerations

- Prefer immutable request and response models.
- Use Java records where the supported runtime baseline allows it; otherwise
  fall back to final POJOs with explicit constructors and accessors.
- Use Kotlin data classes for Kotlin-facing adapters, but keep them as thin
  wrappers over the shared contract rather than a separate model family.
- Preserve nullability explicitly in the API surface; avoid ambiguous
  optional fields where a required value would make contract drift harder to
  detect.
- Use `BigDecimal` for monetary or ratio values that must not inherit binary
  floating-point drift.
- Expose checked or well-typed failures for validation and contract problems;
  do not encode business-rule fallback logic inside exceptions.
- Keep time, locale, and encoding rules explicit so Kotlin and Kotlin callers
  observe the same serialized shape.
- Make schema and version fields first-class so Arrow / Parquet evolution can
  be negotiated without changing formula logic.

## No formula-logic duplication

- The Rust core remains the single source of formula logic.
- Kotlin-first models may mirror request and response shapes, but they may not
  reimplement calculator rules, adjustment logic, or fallback heuristics.
- The service layer may validate, route, authenticate, and translate payloads,
  but it may not become a second calculator.
- File interchange may serialize canonical inputs and outputs, but it may not
  introduce a parallel calculation path.

## Sequencing guidance

1. Stabilize the Arrow / Parquet contract and fixture-backed examples first.
2. Add service-boundary support for callers that need an always-on endpoint.
3. Promote JNI / JNA only after ABI stability, memory ownership, and binary
   packaging portability are proven.

## Validation rule

- Every Java or Kotlin example must validate against shared golden fixtures.
- A JVM binding that duplicates formula constants, thresholds, or adjustment
  rules is out of scope.
- Release claims for Maven or Gradle packaging should wait until the chosen
  contract is stable and parity evidence exists for the shared fixtures.
