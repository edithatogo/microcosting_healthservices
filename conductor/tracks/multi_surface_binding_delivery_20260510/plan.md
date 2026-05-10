# Plan: Multi-Surface Binding and Delivery Roadmap

## Phase 1: Binding Matrix and Adapter Contract

- [ ] Task: Write tests for binding matrix coverage
    - [ ] Verify Python, R, Julia, C#, Rust, Go, and TypeScript are covered
    - [ ] Verify each surface is classified as implemented, planned, deferred, or advisory
    - [ ] Verify adapters are documented as thin wrappers over the Rust core
- [ ] Task: Create the binding matrix
    - [ ] Record recommended tools and risks for each language
    - [ ] Define stable ABI, Arrow, WASM, and service-boundary options
    - [ ] Record sequencing after Rust/Python parity
- [ ] Task: Conductor - Automated Review and Checkpoint 'Binding Matrix and Adapter Contract' (Protocol in workflow.md)

## Phase 2: TypeScript/WASM and GitHub Pages Delivery

- [ ] Task: Write tests for browser delivery boundaries
    - [ ] Verify GitHub Pages remains synthetic/demo-only
    - [ ] Verify TypeScript/WASM plans consume generated or shared contracts
    - [ ] Verify no real-data upload workflow is introduced
- [ ] Task: Document TypeScript and GitHub Pages delivery
    - [ ] Define wasm-bindgen or wasm-pack evaluation criteria
    - [ ] Define fixture-backed browser parity workflow
    - [ ] Update web architecture and docs-site guidance
- [ ] Task: Conductor - Automated Review and Checkpoint 'TypeScript/WASM and GitHub Pages Delivery' (Protocol in workflow.md)

## Phase 3: Streamlit and Service/API Delivery

- [ ] Task: Write tests for hosted delivery boundaries
    - [ ] Verify Streamlit is documented as a Python-hosted analyst surface
    - [ ] Verify service/API pathways preserve public contracts and privacy rules
- [ ] Task: Document Streamlit and service delivery
    - [ ] Define local/demo Streamlit workflow and data constraints
    - [ ] Define secure service boundary options for real-data workflows
    - [ ] Define observability and logging limits for sensitive fields
- [ ] Task: Conductor - Automated Review and Checkpoint 'Streamlit and Service/API Delivery' (Protocol in workflow.md)

## Phase 4: R, Julia, C#, Go, and Power Platform Packaging Plans

- [ ] Task: Write tests for downstream packaging guidance
    - [ ] Verify R, Julia, C#, and Go plans name binding options and blockers
    - [ ] Verify Power Platform consumes a service or custom connector only
- [ ] Task: Document downstream packaging plans
    - [ ] Evaluate extendr for R, jlrs or Julia ccall for Julia, and ABI or service wrappers for C# and Go
    - [ ] Define package/versioning expectations for each surface
    - [ ] Define when each surface can claim parity or release readiness
- [ ] Task: Conductor - Automated Review and Checkpoint 'R, Julia, C#, Go, and Power Platform Packaging Plans' (Protocol in workflow.md)
