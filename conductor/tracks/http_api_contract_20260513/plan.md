# Plan: HTTP API Contract

## Phase 1: Resource Model
- [ ] Task: Define API resources and endpoint semantics.
    - [ ] Include calculators, schemas, validation, calculations, jobs, results, and evidence.
    - [ ] Define sync and async execution behavior.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Resource Model' (Protocol in workflow.md)

## Phase 2: OpenAPI Contract
- [ ] Task: Implement OpenAPI 3.1 specification.
    - [ ] Reference canonical schemas.
    - [ ] Add examples for pass, fail, and unsupported requests.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: OpenAPI Contract' (Protocol in workflow.md)

## Phase 3: Contract Tests
- [ ] Task: Validate OpenAPI and examples in CI.
    - [ ] Assert error and provenance consistency.
    - [ ] Assert unsupported streams fail closed.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Contract Tests' (Protocol in workflow.md)
