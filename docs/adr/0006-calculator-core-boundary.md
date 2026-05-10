# ADR 0006: Calculator Core Boundary

## Status

Proposed

## Context

The project needs Python library support, a GitHub Pages web app, and a Power
Platform app backed by a secure calculation boundary. Shared behavior must
remain faithful to IHACPA sources while the long-term core shifts toward Rust.

## Decision

Define calculator behavior around explicit contracts: parameter models, input
schemas, output schemas, pricing-year metadata, reference data manifests, and
formula/provenance metadata. UI, CLI, Python, Rust, C#, web, and Power Platform
adapters should depend on these contracts rather than embedding
calculator-specific assumptions.

Treat Arrow-compatible batch input/output as the preferred kernel boundary.
Formula logic lives in the core; adapters may validate, translate, and format,
but must not duplicate calculation behavior or source lookup logic.

## Consequences

The project can build multiple delivery surfaces while preserving shared golden
tests and traceability. Rust can become the future source of truth without
requiring a repo-wide behavioral rewrite.
