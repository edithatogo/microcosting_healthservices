# Rust Acute 2025 Proof of Concept Status

This note records the state of the acute 2025 Rust proof of concept after
Phase 4 of `rust_acute_python_poc_20260510`.

## Validation Evidence

- The Rust core crate passes its contract tests with `cargo test --manifest-path rust/Cargo.toml -p nwau-core`.
- The Python binding scaffold and opt-in acute adapter pass the binding tests in `tests/test_rust_acute_binding.py`.
- The acute 2025 parity checks pass against the synthetic golden fixture pack at `tests/fixtures/golden/acute_2025/`.
- Failure reporting through `nwau_py.fixtures.assert_fixture_case_output()` includes fixture provenance and tolerance fields.

## Performance Notes

- The Rust workspace test run completed from a warm cache in 0.11 seconds on this machine.
- The Python parity and status-doc test run completed in 0.58 seconds on this machine.
- These numbers are local validation timings, not a benchmark claim.

## Known Limitations

- The Rust path is opt-in only and only covers the acute 2025 proof-of-concept row adapter.
- The Python calculator remains the default runtime path.
- The Rust bridge currently loads the local extension artifact from `rust/target` when the module is not installed.
- Non-Python language bindings are still roadmap items and are not shipped in this phase.
- The Rust core still expects resolved reference-row inputs; manifest and bundle resolution remain in Python.

## Rollback

If the Rust adapter needs to be disabled, the Python default `calculate_acute()` path remains available and does not depend on the Rust extension.
