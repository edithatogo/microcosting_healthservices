# ADR 0003: Arrow and Polars Migration

## Status

Proposed

## Context

The current implementation uses pandas broadly. The target stack prefers Polars and Arrow-backed data for performance, cross-library compatibility, and cleaner data bundle boundaries.

## Decision

Migrate in phases. Use Arrow/Parquet as the canonical persisted data bundle format, introduce Polars behind stable interfaces, and protect each migration with source and output parity fixtures.

## Consequences

The project avoids a broad behavioral rewrite while making the desired data architecture explicit.

