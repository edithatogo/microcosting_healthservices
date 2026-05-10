# Specification: Multi-Surface Binding and Delivery Roadmap

## Overview

Define the staged delivery plan for surfacing the Rust core through language bindings and user-facing application surfaces once the Rust/Python proof of concept is stable.

## Current State

- Python package and CLI exist.
- GitHub Pages static demo and Starlight docs exist.
- C# and Power Platform boundaries are documented but not implemented.
- R, Julia, Go, and TypeScript bindings do not exist.

## Requirements

- Create a binding matrix for Python, R, Julia, C#, Rust, Go, and TypeScript.
- Treat all language packages as adapters over the Rust core, not independent calculation engines.
- Prefer Arrow-compatible table exchange and a stable ABI or service boundary where native bindings are not mature enough.
- Define TypeScript/WebAssembly delivery for synthetic GitHub Pages demos.
- Define Streamlit delivery for Python-hosted analyst workflows.
- Define Power Platform delivery through a custom connector or service boundary only.
- Preserve privacy boundaries: GitHub Pages must remain synthetic/demo-only.
- Document sequencing so non-Python bindings do not block Rust/Python parity.

## Acceptance Criteria

- A binding and delivery matrix exists with recommended toolchains, maturity, risks, and sequencing.
- Web, Streamlit, Power Platform, and docs-site surfaces have explicit delivery responsibilities.
- TypeScript/WASM and GitHub Pages plans use synthetic fixtures only.
- Power Platform remains orchestration-only and consumes service/custom connector contracts.
- Future binding implementation tracks can be created without re-deciding architecture.

## Out of Scope

- Implementing all bindings.
- Shipping a production Power Platform solution.
- Enabling browser upload of sensitive patient-level data.
