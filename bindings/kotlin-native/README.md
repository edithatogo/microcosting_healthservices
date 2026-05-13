# Kotlin/Native binding scaffold

This scaffold is Kotlin/Native-first. It is intended for consumers who want
Kotlin ergonomics without a JVM runtime dependency.

## Boundary

- Kotlin/Native should call the shared Rust core through a C ABI, service, or
  file/Arrow boundary.
- Kotlin code may define request/response envelopes and diagnostics adapters.
- Formula logic remains in the Rust core or shared calculator contract.

## Non-goals

- No JVM runtime dependency.
- No Java-authored binding.
- No duplicated formula implementation.
- No Kotlin/Native artifact publication claim.

## Build note

Kotlin/Native avoids a JVM runtime artifact. Kotlin build tools still need a
compiler toolchain during development, depending on the chosen build system. The
product boundary should not require Java or a JVM.
