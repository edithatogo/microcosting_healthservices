# Source Archive Policy

## Purpose

The IHACPA source archive is the provenance baseline for calculator fidelity. It should preserve raw calculator artifacts and describe how each artifact moves from raw source to extracted data, implementation behavior, and validation evidence.

## Storage Policy

Commit durable provenance manifests to Git in a tracked location such as `data/provenance/ihacpa/sources.json`. Do not place committed manifests inside ignored raw storage.

Raw downloaded binaries should not be committed to normal Git history by default. Use one of:

- Git LFS for versioned binary artifacts when repository-level access is acceptable.
- GitHub release assets for immutable public snapshots.
- External object storage for larger or access-controlled archives.

The repository should commit scripts, manifests, checksums, extraction code, validation evidence, and documentation. Raw binaries should only be committed after an explicit storage decision and a documented restore workflow.

## Manifest Requirements

Each source artifact manifest entry should include:

- Manifest schema version and stable artifact identifier.
- Pricing year label and start year.
- Artifact type, such as Excel, SAS, support data, compiled reference, or documentation.
- Service stream.
- Source page URL.
- Original artifact URL.
- Final redirected URL.
- Local path or object-storage URI.
- File size in bytes.
- SHA-256 checksum, recorded alongside the checksum algorithm.
- Content type.
- Download timestamp.
- Acquisition run context, including script version or Git commit, invocation arguments, and source page snapshot location.
- Acquisition status.
- Notes for inaccessible or externally hosted assets.

## Status Terms

Treat lifecycle states as separate axes rather than a single mutable status field:

- `acquisition.status`: `listed`, `downloaded`, `external-html-only`, `failed`
- `extraction.status`: `not-started`, `extracted`, `failed`
- `implementation.status`: `not-started`, `implemented`
- `validation.status`: `not-started`, `validated`, `failed`

This allows a single artifact to be, for example, downloaded but not extracted, or extracted but not yet validated.

## Current Acquisition Notes

The IHACPA NWAU calculators page was used as the source of record for the initial archive pass. It listed calculator artifacts from 2026-27 back to 2013-14. Direct IHACPA-hosted Excel files and most SAS archives were downloadable. The 2021-22 and 2022-23 SAS links resolved to Box HTML share pages and require a direct-download workflow or manual retrieval.
