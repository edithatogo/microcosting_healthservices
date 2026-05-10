# ADR 0007: Rust Core Architecture and Calculator Abstraction

## Status

Proposed

## Context

The project needs a long-lived calculator architecture that can preserve the
current validated Python behavior while moving the actual formula engine toward
a Rust core. The existing Python, Arrow/Polars, C#, web, and Power Platform
surfaces should become adapters around a shared batch-oriented contract rather
than independent calculation engines.

## Decision

Treat Rust as the intended future source of truth for calculator formulae and
deterministic kernel logic, with Python remaining the production and
validation baseline until parity is proven calculator by calculator.

Use Arrow-compatible batch input and output as the primary kernel contract.
Keep formula logic, parameter models, input/output schemas, reference loading,
and provenance handling separate from delivery adapters.

Adapters may provide scalar helpers for testing or formula clarity, but they
must not duplicate formula logic or perform hidden source lookup behavior.
Promotion from Python-default to Rust-backed behavior must require explicit
fixture parity and validation evidence.

## Consequences

The repository can evolve toward Rust-first calculation while preserving the
current Python runtime as the authoritative comparison path. Language-specific
surfaces remain thin and easier to validate against shared fixtures.
