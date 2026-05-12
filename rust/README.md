# Rust Acute 2025 Workspace

This workspace is the acute 2025 Rust proof-of-concept scaffold.

## Crate Responsibilities

- `nwau-core` holds the acute 2025 calculation kernel, schema contracts, and
  deterministic formula code.
- `nwau-py` provides the PyO3/maturin binding scaffold that will surface the
  Rust-backed acute path to Python.

## Python Binding Package

- The compiled extension is exposed as `nwau_py._rust`.
- The native package targets Python 3.10+ via `abi3`, so a single wheel can be
  reused across supported CPython 3.10, 3.11, and 3.12 runtimes.
- This workspace does not replace the package-level pure-Python calculator
  fallback. If a matching wheel is not available for a platform, the optional
  Rust extension can be built from source with `maturin`, a Rust toolchain, and
  the local Python headers; callers can still use the default Python calculator
  path without opting into Rust.
- The exported Python API is intentionally narrow:
  - `kernel_label()`
  - `calculate_acute_2025_row(...)`
  - `__version__`

## Commands

- `cargo fmt`
- `cargo clippy --all-targets --all-features -- -D warnings`
- `cargo test`

## Architecture Mapping

This workspace implements the Rust-first core direction recorded in ADR 0007.
It is a scaffold only; the Python package remains the default validated path
until Rust parity is explicitly recorded.
