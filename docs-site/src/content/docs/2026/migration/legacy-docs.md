---
title: Legacy docs migration
slug: 2026/migration/legacy-docs
---

The original repository documentation lived in markdown files at the project
root and under `conductor/`.

This page records the migration path:

* Starlight is now the public docs surface.
* Versioned docs are published from the Starlight site.
* Legacy docs entry points are no longer authoritative.
* Legacy references remain in the repository for provenance and project
  governance, but they are no longer the primary user-facing documentation
  surface.
* The remaining root and Conductor markdown files are now governance and
  provenance references, not the docs front door.
* Rust migration status is tracked separately from the legacy-docs migration note so the site can explain that Rust is still opt-in and not the default runtime.

## Current rule

Use the Starlight site for the public docs front door. Treat the older
markdown entry points as provenance, not the primary user experience.
