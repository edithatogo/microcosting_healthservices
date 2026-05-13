---
title: Kotlin/Native binding
slug: 2026/governance/kotlin-native-binding
---

# Kotlin/Native binding

This page defines the governance posture for the Kotlin/Native workstream. The
Kotlin/Native binding is a downstream adapter, not a new source of calculator truth. It
must consume the shared public calculator contract and present it in a
Kotlin-first form without changing the underlying semantics.

## Kotlin/Native strategy

* Keep the Kotlin/Native surface thin and contract driven.
* Prefer a small, explicit API over a broad object model.
* Treat implementation changes in the core calculator as upstream changes that
  the Kotlin/Native binding consumes, not redefines.
* Avoid claims about supported packaging, native integration, or language
  interop until those gates are documented.

The goal is a predictable adapter that fits existing native Kotlin ecosystems while
keeping the calculator rules centralized in the shared contract.

## Service boundary

The service boundary is the supported entrypoint for Kotlin callers while the
binding matures.

* Public service methods define the supported request and response surface.
* Transport details, orchestration helpers, and local implementation classes
  stay outside the public API.
* The Kotlin/Native binding may expose service-oriented calls, but it must not become a
  second calculator implementation.

This keeps the public surface stable enough for Kotlin application code while
allowing the underlying delivery shape to evolve.

## File boundary

The file boundary is the on-disk separation between generated glue, manual
compatibility code, and examples or fixtures.

* Keep generated adapter code in dedicated files so it can be refreshed
  without disturbing handwritten logic.
* Keep compatibility helpers separate from generated code.
* Do not mix API docs, transport adapters, and test fixtures in the same file
  unless the file is explicitly the package entrypoint.

Clear file boundaries make it easier to review changes and to prove which parts
of the binding are generated versus maintained by hand.

## C ABI and C ABI deferral

C ABI and C ABI are deliberately deferred. The docs should not promise native
bridges before the project is ready to own their maintenance burden.

* Do not expose C ABI or C ABI as required delivery paths for the Kotlin/Native binding.
* Treat native bridges as a later option, not the baseline integration model.
* Do not claim platform support that depends on native code until the build,
  packaging, and runtime matrix are explicitly validated.

For now, the binding should stay focused on a contract-backed Kotlin API and any
service boundary needed to reach it.

## Kotlin API and C ABI considerations

The Kotlin/Native surface should work for both Kotlin and Kotlin callers without forcing
either language into awkward patterns.

* Use package names and class names that are stable and predictable for Java
  code navigation.
* Keep nullability explicit so Kotlin callers can rely on type information
  instead of ambiguous runtime behavior.
* Prefer immutable request and response shapes where practical.
* Avoid overload sets that create ambiguity for Kotlin or complicate Kotlin/Native call
  sites.
* Surface errors in a way that is easy to distinguish from contract failures
  and simple to document in both languages.

The binding should read as a Kotlin API first, while remaining Kotlin-friendly by
default.

## Future Kotlin/Native package gating

Kotlin/Native and Kotlin/Native publication is future-gated.

Planned gates include:

* A release checklist that confirms the Kotlin/Native binding still matches the public
  calculator contract.
* Explicit versioning that follows the documented contract and release policy.
* Build and publish checks for the supported JDK levels and target artifacts.
* Separate documentation for preview, supported, and archived package states.

Until those gates are in place, the docs should describe the Kotlin/Native binding as a
governed workstream with a stable direction, not as a generally available
package promise.

## Related pages

* [Public calculator contract](./public-calculator-contract/)
* [Downstream packaging plans](./downstream-packaging-plans/)
* [Go binding](./go-binding/)
* [C#/.NET binding](./csharp-dotnet-binding/)
