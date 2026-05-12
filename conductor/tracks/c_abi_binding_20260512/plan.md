# Plan: C ABI Binding

## Phase 1: ABI Contract and Boundary Design
- [x] Task: Define the conservative ABI contract for versioning, ownership, and errors.
    - [x] Lock append-only POD structs, borrowed views, and runtime version queries.
    - [x] Document Arrow C Data Interface usage and the file-based Arrow boundary.
    - [x] Document unsupported Python-specific behavior and deferred features.
- [x] Task: Conductor - Automated Review and Checkpoint 'Phase 1: ABI Contract and Boundary Design' (Protocol in workflow.md)

## Phase 2: Prototype and Fixture Parity
- [x] Task: Implement a minimal C ABI prototype for one validated calculator.
    - [x] Add a committed header scaffold and Rust workspace crate for ABI compatibility checks.
    - [x] Keep shared golden fixture parity as the gate before any readiness claim.
    - [x] Keep the prototype conservative and fail closed with `UNIMPLEMENTED` on calculation calls.
    - [x] Add repository tests for the scaffold, memory ownership, error semantics, Arrow boundary, and publication posture.
- [x] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Prototype and Fixture Parity' (Protocol in workflow.md)
