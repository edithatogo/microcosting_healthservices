# Reference Generation

## Purpose

This document defines how generated reference material should be surfaced for
the public docs and adapter ecosystem.

## Rules

- public calculator contracts remain the source of truth for runtime-neutral
  schema surfaces.
- Generated docs should explain implemented behavior, not imply parity or
  runtime support that has not been validated.
- Rust API docs should describe the core crate and adapter crates once the
  workspace is stable enough to publish them.
- Python docs should continue to document the current validated adapter and CLI.
- WASM or browser docs should only appear when the browser surface is actually
  implemented.

## Ownership

- Starlight owns the public narrative and governance views.
- The public calculator contract owns the runtime-neutral schema and error
  model.
- Rustdoc, Python docs, and generated client docs own the surface-specific API
  details.

## Release Discipline

- Generated reference docs must not claim default runtime status or validation
  status on their own.
- Any generated docs that summarize behavior should link back to the relevant
  validation record or fixture pack.
