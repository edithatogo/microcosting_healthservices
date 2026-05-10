# ADR 0005: Web and Power Platform Delivery

## Status

Proposed

## Context

The project should eventually support a GitHub Pages-hosted web app and a Power
Platform app over a secure calculation boundary. The long-term calculation core
direction is Rust, not a C#-owned engine. The browser roadmap may also include
TypeScript/WebAssembly demo shells and a Python-hosted Streamlit surface, but
those remain adapters over the shared contract and fixture layer.

## Decision

Keep the GitHub Pages app static-first and safe for synthetic/demo data. Keep
the Power Platform app as an orchestration surface over an explicit secure
service boundary. Use shared golden fixtures to enforce parity between Python
and any future Rust-backed delivery surface. Use browser-side TypeScript/WASM
only for synthetic demos that consume shared contracts, never for real-data
calculation.

## Consequences

Delivery surfaces can evolve independently while sharing calculator contracts and validation evidence.
