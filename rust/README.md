# Rust Acute 2025 Workspace

This workspace is the acute 2025 Rust proof-of-concept scaffold.

## Crate Responsibilities

- `nwau-core` holds the acute 2025 calculation kernel, schema contracts, and
  deterministic formula code.
- `nwau-py` provides the PyO3/maturin binding scaffold that will surface the
  Rust-backed acute path to Python.

## Commands

- `cargo fmt`
- `cargo clippy --all-targets --all-features -- -D warnings`
- `cargo test`

## Architecture Mapping

This workspace implements the Rust-first core direction recorded in ADR 0007.
It is a scaffold only; the Python package remains the default validated path
until Rust parity is explicitly recorded.
