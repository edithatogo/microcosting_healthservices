# ADR 0002: Calculator Core Boundary

## Status

Proposed

## Context

The project needs Python library support, a GitHub Pages web app, and a Power Platform app backed by a C# calculation engine. Shared behavior must remain faithful to IHACPA sources.

## Decision

Define calculator behavior around explicit contracts: parameter models, input schemas, output schemas, pricing-year metadata, reference data manifests, and formula/provenance metadata. UI, CLI, Python, and C# adapters should depend on these contracts rather than embedding calculator-specific assumptions.

## Consequences

The project can build multiple delivery surfaces while preserving shared golden tests and traceability.

