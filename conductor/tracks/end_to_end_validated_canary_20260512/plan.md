# Plan: End-to-End Validated Canary

## Phase 1: Canary Selection and Source Bundle
- [ ] Task: Select stream/year and assemble source manifest.
    - [ ] Confirm SAS and Excel source availability or explicit gaps.
    - [ ] Record URLs, hashes, retrieval dates, and source authority.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Canary Selection and Source Bundle' (Protocol in workflow.md)

## Phase 2: Formula and Fixture Evidence
- [ ] Task: Extract formula/parameter bundle and create parity evidence.
    - [ ] Record SAS parity and Excel formula parity.
    - [ ] Add fixture parity report with tolerance and rounding policy.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Formula and Fixture Evidence' (Protocol in workflow.md)

## Phase 3: Cross-Engine Canary
- [ ] Task: Validate Python baseline, Rust canary, and CLI/Arrow output.
    - [ ] Run shared fixtures across surfaces.
    - [ ] Record conformance results and residual caveats.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Cross-Engine Canary' (Protocol in workflow.md)

## Phase 4: Documentation and Template Extraction
- [ ] Task: Publish canary lifecycle docs and future-year template guidance.
    - [ ] Add Starlight docs page.
    - [ ] Convert lessons into reusable implementation checklist.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 4: Documentation and Template Extraction' (Protocol in workflow.md)
