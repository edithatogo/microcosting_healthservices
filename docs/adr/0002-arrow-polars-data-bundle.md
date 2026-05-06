# ADR 0002: Arrow and Polars Data Bundle Boundary

## Status

Accepted

## Context

The calculator stack needs a dataframe-neutral bundle boundary for extracted
reference data so downstream adapters can share the same manifest and payload
contract without depending on pandas-specific behavior.

## Decision

Persist extracted calculator reference data as Arrow/Parquet bundles with a
versioned manifest that records bundle identity, pricing year, source artifact
reference, checksum, row counts, backend neutrality, and provenance.

Keep the bundle layer dataframe-neutral. Python adapters may return pandas or
Polars dataframes, but the bundle contract itself must remain engine-agnostic
and use explicit manifest metadata rather than hidden source lookup behavior.

Use pandas only as an adapter detail while the migration is in progress. The
Polars reader is a pilot consumer of the same bundle contract, not a separate
contract surface.

## Consequences

The same bundle can be consumed by Python, future C#, and web tooling without
changing the persisted contract. Future migration work can focus on adapter
implementations instead of revisiting bundle metadata or payload shape.
