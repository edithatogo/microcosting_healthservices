---
title: Reference generation
---

Generated reference material should describe the contract that is actually
implemented, not promise future parity or runtime support.

Rules:

- public calculator contracts remain the source of truth for runtime-neutral schema surfaces.
- Rust API docs should appear once the Rust workspace is stable enough to publish them.
- Python docs should continue to describe the current validated adapter and command-line surface.
- WASM or browser docs should only appear when the browser surface is actually implemented.

Generated docs that summarize behavior should link back to the relevant validation record or fixture pack.

See the canonical source in
[Conductor reference-generation.md](../../../../conductor/reference-generation.md).
