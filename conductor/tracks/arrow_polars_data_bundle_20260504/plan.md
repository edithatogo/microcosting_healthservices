# Plan: Arrow and Polars Data Bundle Migration

## Phase 1: Bundle Format

- [ ] Task: Write tests for Arrow/Parquet bundle metadata
    - [ ] Verify schema, checksum, source artifact reference, and pricing year
    - [ ] Verify bundle loading errors are actionable
- [ ] Task: Define runtime data bundle format
    - [ ] Add manifest structure
    - [ ] Add extraction target layout
- [ ] Task: Conductor - User Manual Verification 'Bundle Format' (Protocol in workflow.md)

## Phase 2: Polars Pilot

- [ ] Task: Write parity tests for one calculator data path
    - [ ] Compare pandas and Polars outputs on golden fixtures
    - [ ] Cover nulls, categorical codes, and numeric precision
- [ ] Task: Implement Polars pilot behind an interface
    - [ ] Keep pandas fallback
    - [ ] Avoid broad calculator rewrites
- [ ] Task: Conductor - User Manual Verification 'Polars Pilot' (Protocol in workflow.md)

## Phase 3: JAX Evaluation

- [ ] Task: Write benchmark and parity criteria for JAX/XLA candidates
    - [ ] Define when acceleration is useful
    - [ ] Define traceability requirements
- [ ] Task: Evaluate one isolated calculation path
    - [ ] Compare speed, memory, and output parity
    - [ ] Record decision in ADR 0004
- [ ] Task: Conductor - User Manual Verification 'JAX Evaluation' (Protocol in workflow.md)

