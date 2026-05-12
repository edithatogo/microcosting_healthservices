# Specification: Polyglot Rust Core Roadmap

## Overview
Define the roadmap for turning the project into a proper polyglot library. The
target architecture is a shared Rust calculator core with thin bindings and
adapters for Python, R, Julia, TypeScript/WASM, C ABI, CLI/file workflows, web,
and Power Platform surfaces.

Python remains the current validated public runtime until each calculator
stream has Rust parity evidence. Rust becomes the default only when fixture
parity, packaging, documentation, and binding contracts are complete.

## Functional Requirements
- Define the Rust-core promotion lifecycle for each calculator stream:
  Python baseline, Rust canary, Rust opt-in, Rust default.
- Define the shared contract for Arrow-compatible batch inputs, outputs,
  diagnostics, provenance, and validation status.
- Coordinate existing binding tracks under a single sequencing model.
- Define how parameter bundles, coding-set registries, classifiers/groupers,
  and source manifests feed the Rust core.
- Define contract tests that every binding must pass.
- Define packaging and release expectations for Python wheels, Rust crates,
  WASM packages, C ABI artifacts, and future R/Julia packages.

## Non-Functional Requirements
- Formula logic must be single-sourced.
- Bindings must be thin wrappers around the shared core or CLI/file contract.
- Rust promotion must preserve traceability to IHACPA source materials.
- Unsupported or partially validated streams must stay opt-in or unavailable.
- Cross-language behavior must be fixture-gated and deterministic.

## Acceptance Criteria
- The roadmap identifies stream-by-stream Rust promotion gates.
- Binding tracks have clear dependency order and shared contract requirements.
- CI expectations are defined for Rust core, Python bindings, WASM, C ABI, and downstream binding validation.
- Documentation explains current Python-first status and intended polyglot end state without overclaiming.
