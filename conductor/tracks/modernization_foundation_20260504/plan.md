# Plan: Modernization Foundation

## Phase 1: Source Archive and Provenance Baseline

- [ ] Task: Write tests for IHACPA source manifest parsing and status classification
    - [ ] Verify year, type, service stream, URL, local path, byte count, and status fields
    - [ ] Verify Box-hosted or inaccessible assets are recorded without being treated as validated downloads
- [ ] Task: Implement durable source archive metadata
    - [ ] Add a stable manifest schema for raw, extracted, implemented, and validated statuses
    - [ ] Document raw archive storage policy and whether large binaries belong in Git, Git LFS, releases, or external object storage
    - [ ] Record the current IHACPA acquisition results under project documentation or metadata
- [ ] Task: Conductor - User Manual Verification 'Source Archive and Provenance Baseline' (Protocol in workflow.md)

## Phase 2: Tooling and Quality Foundation

- [ ] Task: Write tests or CI checks for the supported Python/tooling matrix
    - [ ] Cover Python 3.10, 3.11, 3.12, 3.13, and 3.14 expectations
    - [ ] Verify dependency groups can be resolved by uv
- [ ] Task: Introduce modernization tooling
    - [ ] Configure uv dependency management
    - [ ] Configure Codecov coverage reporting
    - [ ] Replace mypy direction with ty
    - [ ] Add Hypothesis, mutmut, and Scalene entry points
    - [ ] Add Renovate configuration
    - [ ] Add Vale prose linting configuration
- [ ] Task: Conductor - User Manual Verification 'Tooling and Quality Foundation' (Protocol in workflow.md)

## Phase 3: Calculator Architecture Boundaries

- [ ] Task: Write tests for calculator boundary contracts
    - [ ] Verify parameter models, input schemas, output schemas, and pricing-year metadata can be validated independently
    - [ ] Verify reference-data resolution is explicit and deterministic
- [ ] Task: Define strict calculator abstractions
    - [ ] Separate orchestration, formulas, parameter models, schemas, reference data loading, provenance metadata, CLI, and future UI/API adapters
    - [ ] Define migration rules from pandas to Polars and Arrow-backed data
    - [ ] Define where JAX/XLA is acceptable and how parity remains explainable
- [ ] Task: Conductor - User Manual Verification 'Calculator Architecture Boundaries' (Protocol in workflow.md)

## Phase 4: Multi-Surface Delivery Architecture

- [ ] Task: Write architecture checks for future delivery surfaces
    - [ ] Verify the Python core can remain independent from web and C# adapters
    - [ ] Verify calculator metadata can describe capabilities for UI generation
- [ ] Task: Design GitHub Pages and Power Platform pathways
    - [ ] Define a GitHub Pages web-app architecture for static hosting and client-side or API-backed calculation workflows
    - [ ] Define a Power Platform app architecture with a C# calculation engine and shared test vectors
    - [ ] Define cross-language golden-test fixtures for Python and C# parity
- [ ] Task: Conductor - User Manual Verification 'Multi-Surface Delivery Architecture' (Protocol in workflow.md)

## Phase 5: Documentation System

- [ ] Task: Write documentation quality checks
    - [ ] Verify terminology for archived, extracted, implemented, and validated statuses
    - [ ] Verify source mapping documentation exists for each supported calculator family
- [ ] Task: Establish state-of-the-art documentation structure
    - [ ] Add API reference, concept guides, validation guides, source provenance guides, contributor workflows, and release/versioning guidance
    - [ ] Integrate Vale prose rules for conservative validation language
    - [ ] Document how to add and validate a new pricing year
- [ ] Task: Conductor - User Manual Verification 'Documentation System' (Protocol in workflow.md)
