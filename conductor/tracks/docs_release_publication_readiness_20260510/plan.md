# Plan: Documentation, Release, and Public Readiness

## Phase 1: Starlight Architecture Content

- [ ] Task: Write docs-site tests for Rust roadmap content
    - [ ] Verify Starlight pages exist for Rust-core architecture and migration status
    - [ ] Verify docs distinguish current validated Python behavior from intended Rust behavior
- [ ] Task: Add public architecture docs
    - [ ] Add Rust-core architecture, migration, and binding roadmap pages
    - [ ] Link relevant Conductor governance docs into Starlight navigation
    - [ ] Preserve conservative validation language
- [ ] Task: Conductor - Automated Review and Checkpoint 'Starlight Architecture Content' (Protocol in workflow.md)

## Phase 2: API and Reference Generation Plan

- [ ] Task: Write tests for generated-reference planning
    - [ ] Verify OpenAPI, schema, or generated reference plans are linked from docs
    - [ ] Verify generated docs do not claim unsupported runtime parity
- [ ] Task: Document generated reference strategy
    - [ ] Define how public contracts, Rust API docs, Python docs, and WASM docs should surface
    - [ ] Evaluate Starlight OpenAPI or equivalent integration only where it supports real public contracts
    - [ ] Record documentation ownership for each language surface
- [ ] Task: Conductor - Automated Review and Checkpoint 'API and Reference Generation Plan' (Protocol in workflow.md)

## Phase 3: Release Notes, Provenance, and Validation Status

- [ ] Task: Write release-documentation tests
    - [ ] Verify release policy covers Rust crates, Python wheels, WASM packages, and binding artifacts
    - [ ] Verify validation status remains fixture-backed
- [ ] Task: Update release and validation docs
    - [ ] Define version relationships between package, core crate, data bundle, and binding packages
    - [ ] Define release-note requirements for calculator behavior changes
    - [ ] Document provenance and validation evidence expected for Rust-backed releases
- [ ] Task: Conductor - Automated Review and Checkpoint 'Release Notes, Provenance, and Validation Status' (Protocol in workflow.md)

## Phase 4: Public Repo Hygiene and Contributor Pathway

- [ ] Task: Write tests for public-readiness documentation
    - [ ] Verify contributor guidance names Python, docs, and future Rust quality gates
    - [ ] Verify security, citation, license, and contribution expectations are present or gap-recorded
- [ ] Task: Update public-readiness docs
    - [ ] Add or update contributor pathway, security policy recommendation, citation guidance, and validation vocabulary links
    - [ ] Record any unresolved public-readiness gaps as follow-on work
    - [ ] Confirm GitHub Pages documentation remains the public docs front door
- [ ] Task: Conductor - Automated Review and Checkpoint 'Public Repo Hygiene and Contributor Pathway' (Protocol in workflow.md)
