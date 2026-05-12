# Plan: Python Rust Binding Stabilization

## Phase 1: Binding Contract
- [ ] Task: Define the Python-to-Rust calculator boundary and fallback policy.
    - [ ] Document batch input/output schema and error mapping.
    - [ ] Mark validated and experimental calculators explicitly.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Binding Contract' (Protocol in workflow.md)

## Phase 2: Packaging and Tests
- [ ] Task: Add cross-platform maturin wheel build and parity tests.
    - [ ] Reuse golden fixtures for Python and Rust-backed paths.
    - [ ] Keep extension import failures diagnosable.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Packaging and Tests' (Protocol in workflow.md)
