# Plan: Rust Crate Boundaries and HWAU Rename

## Phase 1: Boundary Design
- [ ] Task: Define target crate boundaries.
    - [ ] Document contracts, core, CLI, MCP, API, Python, .NET, and WASM crates.
    - [ ] Document C ABI as implementation boundary only.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Boundary Design' (Protocol in workflow.md)

## Phase 2: Rename Plan
- [ ] Task: Define NWAU-to-HWAU migration path.
    - [ ] Add compatibility aliases.
    - [ ] Add deprecation notes.
    - [ ] Add migration tests.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Rename Plan' (Protocol in workflow.md)

## Phase 3: Coordinated Implementation
- [ ] Task: Coordinate with active Rust implementation agents.
    - [ ] Avoid conflicting file edits.
    - [ ] Stage only planned rename changes after implementation stabilizes.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Coordinated Implementation' (Protocol in workflow.md)
