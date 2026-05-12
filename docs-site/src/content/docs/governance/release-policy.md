---
title: Release policy
---

Release notes and registry entries should identify the calculator, pricing
year, parity type, and evidence record used for validation.

For Rust-backed or browser-backed artifacts, include the crate version,
workspace lockfile revision, and any binding package version.

## Rust-backed packaging

Rust-backed Python delivery is published as an optional wheel for `nwau_py`,
not as a replacement for the validated Python package.

- The wheel should expose the same Python entry points as the validated
  package.
- If the extension cannot load, `nwau_py.rust_bridge` should continue to fall
  back to Python behavior rather than changing the public contract.
- Wheel builds should use `maturin` once the binding workflow lands.
- Wheel publishing should target the repo's supported CPython matrix
  (`3.10` through `3.14`) on Linux, macOS, and Windows, with source builds kept
  as the fallback for combinations that are not published.
- Release notes should state whether a calculator is Python-only,
  Rust-experimental, or Rust-validated.

GitHub Actions must pass before a release claim is treated as ready to merge
or publish.

See the canonical source in [Conductor release-policy.md](../../../../conductor/release-policy.md).
