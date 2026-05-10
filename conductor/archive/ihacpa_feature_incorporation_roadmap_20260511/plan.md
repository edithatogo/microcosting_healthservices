# Plan: IHACPA Feature Incorporation and Calculator Coverage Roadmap

## Phase 1: Archive-to-Code Feature Inventory [checkpoint: 3a65282]

- [x] Task: Write tests for the feature inventory contract
    - [x] Verify the archive families are enumerated from the source corpus
    - [x] Verify complexity, HAC, and AHR are explicitly classified
    - [x] Verify the matrix includes implemented, documented-only, missing, and deferred states
    - [x] Verify the current calculator surfaces are listed in the matrix
- [x] Task: Inventory the source corpus
    - [x] Enumerate the calculator families present in the archive
    - [x] Record year-specific variants and historical naming changes
    - [x] Map helper-level features such as complexity, HAC, and AHR
    - [x] Record the current implementation status for each family
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Archive-to-Code Feature Inventory'

## Phase 2: Feature Gap Closure [checkpoint: f159207]

- [x] Task: Write tests for the feature incorporation contract
    - [x] Verify uncovered families or helpers fail clearly before implementation
    - [x] Verify the chosen status for complexity, HAC, and AHR is enforced
    - [x] Verify year-specific parity tests exist for the prioritized gaps
- [x] Task: Implement remaining feature surfaces and adapters
    - [x] Close any uncovered calculator families or year variants
    - [x] Consolidate helper behavior so feature naming matches the source corpus
    - [x] Decide whether complexity remains an adjustment helper or gets a named surface
    - [x] Add or update parity tests for the affected families
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Feature Gap Closure'

## Phase 3: Parity Matrix and Handoff [checkpoint: 9035348]

- [x] Task: Write tests for the final parity matrix
    - [x] Verify the matrix documents implemented, documented-only, missing, and deferred items
    - [x] Verify the matrix references the correct years and source artifacts
    - [x] Verify the matrix is reflected in the docs
- [x] Task: Publish the incorporation summary
    - [x] Update calculator docs with the final feature coverage matrix
    - [x] Record any deliberate deferrals and their rationale
    - [x] Synchronize the repository guidance with the final implementation state
- [x] Task: Conductor - Automated Review and Checkpoint via conductor-review, auto-fix, and auto-progress 'Parity Matrix and Handoff'
