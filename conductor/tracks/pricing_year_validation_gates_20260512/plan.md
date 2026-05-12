# Plan: Pricing-Year Validation Gates

## Phase 1: Status Model
- [ ] Task: Define validation statuses and allowed transitions.
    - [ ] Document required evidence for each transition.
    - [ ] Add manifest fields for status and evidence references.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Status Model' (Protocol in workflow.md)

## Phase 2: Gate Implementation
- [ ] Task: Implement `nwau validate-year` and CI validation checks.
    - [ ] Test missing source, missing extraction, missing fixture, and invalid transition cases.
    - [ ] Ensure docs/API support matrices use manifest status.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Gate Implementation' (Protocol in workflow.md)

## Phase 3: Documentation
- [ ] Task: Document validation policy and support-claim rules.
    - [ ] Add maintainer guidance for advancing a pricing year.
    - [ ] Add examples of acceptable evidence.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Documentation' (Protocol in workflow.md)
