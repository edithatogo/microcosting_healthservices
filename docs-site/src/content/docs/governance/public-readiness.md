---
title: Public readiness
---

This page captures the public-facing contributor, security, and citation
guidance that should remain true even while Rust work is still in progress.

## Contributor path

Use the current Python and docs workflow as the baseline contributor gate.
When Rust lands, add the Rust checks without removing the existing Python and
docs gates.

- Synchronize the environment with the committed lockfile.
- Run the Python quality gates used by the repository today.
- Run the docs-site build and link validation before publishing docs changes.
- Add `cargo fmt`, `cargo clippy`, and `cargo test` only once the Rust
  workspace exists.

## Security guidance

Public examples, screenshots, and docs content must stay synthetic or
de-identified.

- Do not encourage patient-level uploads in GitHub Pages or docs-site flows.
- Do not log sensitive identifiers in examples or workflows.
- Keep real-data workflows behind a secured service boundary.

## Citation guidance

Validation claims should cite the fixture pack, source artifact, or validation
record that supports the claim.

- Prefer explicit calculator, year, and fixture identifiers.
- Avoid broad year-level claims when the evidence is calculator-specific.
- Use provenance notes to explain which source material is authoritative for a
  given behavior.
