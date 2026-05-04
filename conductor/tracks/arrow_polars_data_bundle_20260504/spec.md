# Specification: Arrow and Polars Data Bundle Migration

## Goal

Move extracted calculator reference data toward Arrow/Parquet storage and Polars execution while preserving behavior.

## Requirements

- Arrow/Parquet should be the canonical persisted runtime data format.
- Polars should be introduced behind stable interfaces.
- pandas behavior should remain supported until parity fixtures prove replacement safety.
- JAX/XLA paths require benchmark evidence and explainable parity.

## Acceptance Criteria

- A pilot data bundle is represented in Arrow/Parquet with checksums.
- A pilot calculator path can consume the bundle without changing outputs.
- Migration rules are documented.
