# Plan: Arrow and Polars Data Bundle Migration

## Phase 1: Bundle Contract

- [ ] Task: Write tests for Arrow/Parquet bundle metadata and boundary rules
    - [ ] Verify schema version, bundle identity, pricing year, source artifact reference, checksum, and backend-neutral declarations
    - [ ] Verify bundle loading failures are actionable and mention the violated contract
- [ ] Task: Define the dataframe-neutral runtime bundle contract
    - [ ] Add manifest structure with typed metadata and source provenance
    - [ ] Add extraction target layout for Arrow/Parquet payloads and schema files
    - [ ] Specify where pandas stays adapter-only and where Arrow is the canonical contract
- [ ] Task: Conductor - User Manual Verification 'Bundle Contract' (Protocol in workflow.md)

## Phase 2: Polars Pilot

- [ ] Task: Write parity tests for one calculator data path over the shared bundle contract
    - [ ] Compare current adapter output and Polars adapter output on the same Arrow/Parquet bundle
    - [ ] Cover nulls, categorical values, numeric precision, and schema preservation
- [ ] Task: Implement a Polars pilot behind the dataframe-neutral boundary
    - [ ] Keep pandas behavior available through the adapter layer only
    - [ ] Avoid broad calculator rewrites or hidden source-table conversions
- [ ] Task: Conductor - User Manual Verification 'Polars Pilot' (Protocol in workflow.md)

## Phase 3: Migration Guidance

- [ ] Task: Write migration rules for bundle consumers
    - [ ] Document bundle creation, validation, and loading responsibilities
    - [ ] Document how future engines can consume the same Arrow/Parquet bundle without changing the contract
- [ ] Task: Record the approved bundle boundary in the relevant ADR
    - [ ] Summarize why Arrow/Parquet is canonical
    - [ ] Summarize why the bundle layer stays dataframe-neutral
- [ ] Task: Conductor - User Manual Verification 'Migration Guidance' (Protocol in workflow.md)
