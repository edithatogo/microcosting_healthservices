# Polyglot Rust Core roadmap contract

This directory defines synthetic, versioned contract fixtures for the Polyglot Rust Core roadmap workstream.

## Contents

- `polyglot-rust-core-roadmap.schema.json`: JSON Schema for the roadmap contract bundle.
- `polyglot-rust-core-roadmap.contract.json`: Contract manifest describing the versioned surfaces, rules, and artifact expectations.
- `examples/validation.pass.json`: Synthetic pass example covering Arrow-compatible batch I/O, diagnostics, provenance, binding conformance, ABI expectations, and fixture gates.
- `examples/validation.fail.json`: Synthetic fail example covering the same surfaces with explicit contract breaches.

## Scope

The bundle is roadmap-only and metadata-only. It exists to pin the intended contract shape before implementation work lands.

The contract explicitly covers:

- Arrow-compatible batch input and output envelopes.
- Diagnostics payloads and severity conventions.
- Provenance metadata for synthetic artifacts.
- Validation status semantics.
- Binding conformance expectations.
- ABI boundary expectations.
- Fixture gate rules for synthetic examples.

## Rules

- Keep all files synthetic and versioned.
- Do not include proprietary IHACPA content, licensed tables, or production payloads.
- Do not embed executable core logic, only contract statements and examples.
- Keep the ABI boundary descriptive, not implementational.
- Treat fixture gates as metadata for allowed synthetic inputs and outputs only.
