# ADR 0004: JAX/XLA Use Criteria

## Status

Proposed

## Context

JAX/XLA may help with vectorized numerical calculation, batching, and acceleration, but calculator traceability is more important than raw speed.

## Decision

Use JAX/XLA only where benchmarks show value and where the calculation remains explainable against IHACPA source behavior. Keep deterministic reference implementations and golden fixtures for every accelerated path.

## Consequences

JAX can be adopted without making calculator behavior opaque.

