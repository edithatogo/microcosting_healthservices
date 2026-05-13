# Plan: Canonical Contract Foundation

This track fans out to 4 surface contracts in parallel (depth-2 subagents).
The canonical schemas are the dependency that all surface tracks require.

## Phase 1: Schema Inventory [sequential — must complete first]
- [ ] Task: Inventory existing calculator, manifest, evidence, diagnostics, and provenance schemas.
    - [ ] Identify canonical and derived schemas.
    - [ ] Identify missing pass and fail fixtures.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Schema Inventory' (Protocol in workflow.md)

## Phase 2: Canonical Schema Set + Surface Fan-Out [depth-2 parallel]
- [ ] Task: Implement versioned JSON Schema contracts.
    - [ ] Add calculator request and response schemas.
    - [ ] Add diagnostics, errors, provenance, support-status, and evidence schemas.
    - [ ] Add derivation notes for OpenAPI and Arrow/Parquet.
- [ ] Task (parallel subagents): Define surface contracts from canonical schemas.
    - [ ] Subagent B2: CLI/File contract — commands, exit codes, manifests, examples.
    - [ ] Subagent B3: HTTP API OpenAPI 3.1 — endpoints, sync/async, examples.
    - [ ] Subagent B4: MCP contract — tools, resources, examples.
    - [ ] Subagent B5: OpenAI tool adapter — tool definitions, examples, boundary docs.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Canonical Schema Set and Surface Fan-Out' (Protocol in workflow.md)

## Phase 3: Contract Validation
- [ ] Task: Add schema validation tests.
    - [ ] Add pass fixtures.
    - [ ] Add fail-closed fixtures.
    - [ ] Assert adapters cannot redefine formula logic.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Contract Validation' (Protocol in workflow.md)
