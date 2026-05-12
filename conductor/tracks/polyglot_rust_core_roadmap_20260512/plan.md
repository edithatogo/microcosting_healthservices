# Plan: Polyglot Rust Core Roadmap

## Phase 1: Architecture and Sequencing
- [ ] Task: Define the polyglot architecture and Rust-core promotion lifecycle.
    - [ ] Specify Python baseline, Rust canary, Rust opt-in, and Rust default gates.
    - [ ] Define dependencies across reference-data bundles, coding-set registries, classifiers, and bindings.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Architecture and Sequencing' (Protocol in workflow.md)

## Phase 2: Shared Contract and Fixture Gates
- [ ] Task: Define shared cross-language contracts and binding conformance tests.
    - [ ] Specify Arrow-compatible batch schemas, diagnostics, errors, provenance, and validation status.
    - [ ] Define fixture gates every binding must pass before release.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Shared Contract and Fixture Gates' (Protocol in workflow.md)

## Phase 3: Packaging and Release Plan
- [ ] Task: Define packaging and release expectations for each surface.
    - [ ] Cover Python wheels, Rust crates, WASM/npm, C ABI artifacts, R, Julia, CLI/file interop, and docs demos.
    - [ ] Define which artifacts are published now, experimental, or future-only.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Packaging and Release Plan' (Protocol in workflow.md)

## Phase 4: Documentation Integration
- [ ] Task: Publish the polyglot roadmap in project and docs-site materials.
    - [ ] Explain current Python-first status and Rust-core target state.
    - [ ] Link binding, abstraction, source-manifest, formula-bundle, and validation-gate tracks.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 4: Documentation Integration' (Protocol in workflow.md)
