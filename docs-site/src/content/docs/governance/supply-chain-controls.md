---
title: Supply-chain controls
---

Dependency updates, signed artifacts, provenance controls, and Rust-specific
checks are part of the release posture for the project.

Rust releases should consider `cargo audit`, `cargo deny`, SBOM generation, and
artifact signing before the release claim expands.

GitHub Actions checks have passed before a release claim is treated as ready to
merge or publish.

See the canonical source in [Conductor supply-chain-controls.md](https://github.com/edithatogo/microcosting_healthservices/blob/master/conductor/supply-chain-controls.md).
