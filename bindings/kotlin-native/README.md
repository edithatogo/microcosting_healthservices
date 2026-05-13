# Kotlin/Native binding scaffold

This scaffold is Kotlin/Native-first. It is intended for consumers who want
Kotlin ergonomics without a Native runtime dependency.

## Boundary

- Kotlin/Native should call the shared Rust core through a C ABI, service, or
  file/Arrow boundary.
- Kotlin code may define request/response envelopes and diagnostics adapters.
- Formula logic remains in the Rust core or shared calculator contract.

## Non-goals

- No Native runtime dependency.
- No Kotlin/Native-authored binding.
- No C ABI bridge as the initial path.
- No Kotlin/Native package publication claim.

## Build note

Kotlin/Native avoids a Native runtime artifact. Kotlin build tools may still need
a compiler toolchain during development, depending on the chosen build system.
The product boundary should not require Java or a JVM.
