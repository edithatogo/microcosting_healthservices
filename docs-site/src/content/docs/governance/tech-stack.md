---
title: Tech stack
---

The project currently uses Python for calculator implementation, a committed
Rust workspace scaffold for the core migration track, and Starlight for the
public docs site. Starlight is versioned and deployed as a static site with
link validation.

The current docs-site baseline pins `astro` 6.3.1, `@astrojs/starlight`
0.39.2, and `starlight-versions` 0.9.0.

Versioning is surfaced in the docs through the `/versions/` index and the
pricing-year page set beneath it.

Recommended Starlight extensions for this repository are intentionally minimal:

- `starlight-links-validator`
- `starlight-versions`

Consider `starlight-openapi` only if the public calculator contract becomes a
published OpenAPI surface. Consider `starlight-typedoc` only if a TypeScript
binding surface becomes part of the public docs. Leave Algolia DocSearch out
unless Pagefind becomes insufficient.

The repository’s public calculator contract page is the right place to anchor
future OpenAPI generation because it already documents the versioning,
required fields, and error model.

The companion JSON Schema lives at `/contracts/public-calculator-contract.v1.schema.json`.

See the canonical source in [Conductor tech-stack.md](https://github.com/edithatogo/microcosting_healthservices/blob/master/conductor/tech-stack.md).
