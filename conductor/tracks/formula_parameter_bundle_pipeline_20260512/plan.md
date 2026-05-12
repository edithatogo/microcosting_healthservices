# Plan: Formula and Parameter Bundle Pipeline

## Phase 1: Bundle Format
- [ ] Task: Define formula and parameter bundle schema.
    - [ ] Include weights, thresholds, adjustments, formulas, provenance, and validation evidence.
    - [ ] Define stable serialization for reviewable diffs.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Bundle Format' (Protocol in workflow.md)

## Phase 2: Extraction and Loading
- [ ] Task: Implement extraction and bundle loading for one stream/year canary.
    - [ ] Add tests for extracted values and bundle-loaded calculator behavior.
    - [ ] Preserve source references to SAS lines, workbook sheets, or source tables where practical.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Extraction and Loading' (Protocol in workflow.md)

## Phase 3: Future-Year Workflow Docs
- [ ] Task: Document the end-to-end future formula incorporation workflow.
    - [ ] Link source scanning, manifests, bundles, validation gates, and year diffs.
    - [ ] Add a maintainer checklist for new IHACPA releases.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Future-Year Workflow Docs' (Protocol in workflow.md)
