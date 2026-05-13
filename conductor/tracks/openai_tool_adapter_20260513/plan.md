# Plan: OpenAI Tool Adapter

## Phase 1: Adapter Boundary
- [ ] Task: Define OpenAI tool adapter scope.
    - [ ] Document why the domain API remains canonical.
    - [ ] Document why the calculator does not emulate an LLM endpoint.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Adapter Boundary' (Protocol in workflow.md)

## Phase 2: Tool Definitions
- [ ] Task: Generate tool definitions from canonical schemas.
    - [ ] Include calculate, validate, explain, list, schema, and evidence tools.
    - [ ] Add examples for successful, unsupported, and invalid requests.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Tool Definitions' (Protocol in workflow.md)

## Phase 3: Validation and Docs
- [ ] Task: Add adapter validation and documentation.
    - [ ] Assert outputs preserve diagnostics and provenance.
    - [ ] Add usage examples for agent workflows.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Validation and Docs' (Protocol in workflow.md)
