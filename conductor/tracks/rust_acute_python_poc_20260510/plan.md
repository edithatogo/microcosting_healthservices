# Plan: Rust Acute 2025 Proof of Concept with Python Bindings

## Phase 1: Rust Workspace and Kernel Contract [checkpoint: a6b3fc4]

- [x] Task: Write failing tests for Rust workspace expectations [d0ddb5d]
    - [x] Verify the Rust workspace files exist
    - [x] Verify Rust package metadata names the acute 2025 proof of concept
    - [x] Verify Python packaging can locate the binding scaffold
- [x] Task: Scaffold the Rust workspace [6df096a]
    - [x] Add core and Python binding crates with explicit responsibilities
    - [x] Add formatting, linting, and test entry points
    - [x] Document how the workspace maps to the architecture ADR
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Rust Workspace and Kernel Contract' (Protocol in workflow.md) [a6b3fc4]

## Phase 2: Acute 2025 Formula Kernel

- [x] Task: Write Rust formula tests [63b3348]
    - [x] Cover acute 2025 fixture rows and edge cases from the existing Python tests
    - [x] Cover parameter validation and numeric precision expectations
    - [x] Cover source-provenance metadata attached to formula behavior
- [~] Task: Implement the acute 2025 Rust kernel
    - [ ] Keep formula functions deterministic and free of hidden global state
    - [ ] Keep reference data access separate from formula execution
    - [ ] Preserve traceability to SAS and Python reference behavior
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Acute 2025 Formula Kernel' (Protocol in workflow.md)

## Phase 3: Python Binding and Adapter

- [ ] Task: Write Python binding tests
    - [ ] Verify Python can call the Rust-backed acute path
    - [ ] Verify the binding preserves input and output schema names
    - [ ] Verify the binding remains opt-in and does not replace default Python execution
- [ ] Task: Implement the Python binding adapter
    - [ ] Add PyO3/maturin build integration
    - [ ] Expose an explicit Rust-backed acute 2025 entry point
    - [ ] Add CLI or API opt-in wiring without changing current defaults
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Python Binding and Adapter' (Protocol in workflow.md)

## Phase 4: Parity, Performance, and Canary Documentation

- [ ] Task: Write parity and canary tests
    - [ ] Compare Rust-backed outputs against acute 2025 golden fixtures
    - [ ] Compare Rust-backed and Python-default outputs on the same fixture pack
    - [ ] Verify failure reports include fixture provenance and tolerance
- [ ] Task: Document Rust proof-of-concept status
    - [ ] Record validation evidence and known limitations
    - [ ] Record performance measurements without making unsupported claims
    - [ ] Document rollback and non-default runtime behavior
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Parity, Performance, and Canary Documentation' (Protocol in workflow.md)
