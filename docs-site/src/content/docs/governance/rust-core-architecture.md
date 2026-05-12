---
title: Rust core architecture
---

Rust is the intended future calculator core, but Python remains the current validated runtime path until fixture parity is proven calculator by calculator.

The architecture follows the repo-wide contract boundary:

- Arrow-compatible batch input and output is the primary kernel interface.
- Formula logic stays in the core, not in delivery adapters.
- Parameter models, input/output schemas, reference loading, and provenance
  stay separate from presentation layers.

## Binding status

The Rust extension is an optional delivery surface, not the default runtime.
Python remains the validated public path until a calculator has fixture parity
and release evidence recorded for the Rust implementation.

| Calculator status | Meaning |
| --- | --- |
| Validated | The Python implementation is the published public answer for that calculator. |
| Experimental | The Rust path exists, but it is opt-in and may fall back to Python if the extension is missing or incomplete. |

At present, acute 2025 is the experimental Rust-backed calculator named in the
docs. Other calculators remain Python-backed until their parity records are
complete.

## Packaging posture

The binding ships as an optional Python extension wheel, not as a Rust-first
distribution. Wheel claims must stay aligned with the supported CPython and OS
matrix in the release policy, and source fallback must remain available when a
wheel is not published for a target platform.

## Generated reference strategy

This generated reference strategy keeps public docs aligned with the actual implemented contract. The intended stack is:

- Starlight pages for the current public explanation of behavior.
- Public calculator contract pages that define the runtime-neutral fields.
- Rust API docs once the workspace exists and the core crate is implemented.
- Python docs for the current validated adapter and command-line surface.
- WASM docs only if a browser delivery surface is actually introduced.

Generated docs must not claim default runtime status, fixture parity, or
language-surface readiness that has not been validated.

## Public contract surfaces

These public contract surfaces should be documented in the same place that release and validation status are explained so maintainers can trace behavior without duplicating formula logic.

- Starlight is the public front door for the current user-facing contract.
- The public calculator contract names the stable fields that adapters may use.
- Fixture packs and validation records remain the evidence layer for parity
  claims.
- Adapter pages should describe how Python, Rust, and future surfaces consume
  the contract, not re-implement calculator math.

See the source ADR in
[docs/adr/0007-rust-core-architecture-and-calculator-abstraction.md](../../../../../docs/adr/0007-rust-core-architecture-and-calculator-abstraction.md).
