# Plan: Abstraction Doctrine Enforcement

## Phase 1: Doctrine Definition
- [ ] Task: Define the ports-and-adapters abstraction doctrine.
    - [ ] Document allowed dependencies between kernels, bundles, registries, adapters, bindings, apps, and docs.
    - [ ] Document forbidden patterns such as duplicated formula logic in bindings or Power Platform apps.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Doctrine Definition' (Protocol in workflow.md)

## Phase 2: Enforcement Checks
- [ ] Task: Add tests or static checks for high-risk abstraction violations.
    - [ ] Detect formula-like implementation in app, docs-demo, and binding surfaces where practical.
    - [ ] Check that new classifier/grouper integrations declare version and provenance metadata.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Enforcement Checks' (Protocol in workflow.md)

## Phase 3: Contributor and Roadmap Integration
- [ ] Task: Update contributor docs and roadmap references.
    - [ ] Add review checklist items for new years, coding sets, groupers, bindings, and apps.
    - [ ] Link architecture doctrine from relevant roadmap tracks and docs pages.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Contributor and Roadmap Integration' (Protocol in workflow.md)
