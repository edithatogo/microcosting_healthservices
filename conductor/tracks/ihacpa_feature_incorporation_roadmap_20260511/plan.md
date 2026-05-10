# Plan: IHACPA Feature Incorporation and Calculator Coverage Roadmap

## Phase 1: Archive-to-Code Feature Inventory

- [ ] Task: Write tests for the feature inventory contract
    - [ ] Verify the archive families are enumerated from the source corpus
    - [ ] Verify complexity, HAC, and AHR are explicitly classified
    - [ ] Verify the matrix includes implemented, documented-only, missing, and deferred states
    - [ ] Verify the current calculator surfaces are listed in the matrix
- [ ] Task: Inventory the source corpus
    - [ ] Enumerate the calculator families present in the archive
    - [ ] Record year-specific variants and historical naming changes
    - [ ] Map helper-level features such as complexity, HAC, and AHR
    - [ ] Record the current implementation status for each family
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Archive-to-Code Feature Inventory'

## Phase 2: Feature Gap Closure

- [ ] Task: Write tests for the feature incorporation contract
    - [ ] Verify uncovered families or helpers fail clearly before implementation
    - [ ] Verify the chosen status for complexity, HAC, and AHR is enforced
    - [ ] Verify year-specific parity tests exist for the prioritized gaps
- [ ] Task: Implement remaining feature surfaces and adapters
    - [ ] Close any uncovered calculator families or year variants
    - [ ] Consolidate helper behavior so feature naming matches the source corpus
    - [ ] Decide whether complexity remains an adjustment helper or gets a named surface
    - [ ] Add or update parity tests for the affected families
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Feature Gap Closure'

## Phase 3: Parity Matrix and Handoff

- [ ] Task: Write tests for the final parity matrix
    - [ ] Verify the matrix documents implemented, documented-only, missing, and deferred items
    - [ ] Verify the matrix references the correct years and source artifacts
    - [ ] Verify the matrix is reflected in the docs
- [ ] Task: Publish the incorporation summary
    - [ ] Update calculator docs with the final feature coverage matrix
    - [ ] Record any deliberate deferrals and their rationale
    - [ ] Synchronize the repository guidance with the final implementation state
- [ ] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Parity Matrix and Handoff'
