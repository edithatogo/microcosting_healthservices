# Source Archive Policy

## Purpose

The IHACPA source archive is the provenance baseline for calculator fidelity. It should preserve raw calculator artifacts and describe how each artifact moves from raw source to extracted data, implementation behavior, and validation evidence.

## Storage Policy

Commit the durable provenance manifest to Git in a tracked location such as `data/provenance/ihacpa/sources.json`. Do not place the committed manifest inside ignored raw storage.

Temporary acquisition outputs may still live under `archive/ihacpa/raw/` during download and restore workflows, but that location is not the canonical project record.

Raw downloaded binaries should not be committed to normal Git history by default. Use one of:

- Git LFS for versioned binary artifacts when repository-level access is acceptable.
- GitHub release assets for immutable public snapshots.
- External object storage for larger or access-controlled archives.

The repository should commit scripts, the durable manifest, checksums, extraction code, validation evidence, and documentation. Raw binaries should only be committed after an explicit storage decision and a documented restore workflow.

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

The committed manifest should remain conservative about what it claims. If a link resolves to an HTML share page rather than a raw calculator file, record it as an acquisition gap rather than a completed binary download.

## Status Terms

Treat lifecycle states as separate axes rather than a single mutable status field:

- `acquisition.status`: `listed`, `downloaded`, `external-html-only`, `failed`
- `extraction.status`: `not-started`, `extracted`, `failed`
- `implementation.status`: `not-started`, `implemented`
- `validation.status`: `not-started`, `validated`, `failed`

This allows a single artifact to be, for example, downloaded but not extracted, or extracted but not yet validated.

For Box-hosted calculator links that only expose HTML share pages, set `acquisition.status` to `external-html-only` and keep the artifact marked as incomplete until a direct-download or manual retrieval path produces a verifiable binary.

## Restore Workflow

Any restore workflow should follow this order:

1. Read the committed provenance manifest from the tracked location.
2. Retrieve raw artifacts from the approved storage backend or acquisition cache.
3. Verify the SHA-256 checksum and checksum algorithm before extraction.
4. Confirm the artifact still matches the recorded redirected URL, content type, and acquisition status.
5. Only then run extraction or validation.

If an artifact is recorded as `external-html-only`, the restore workflow should not pretend the raw binary exists. It should either keep the item as a gap for manual follow-up or recover the direct file from a separate approved source before any extraction claim is made.

## Current Acquisition Notes

The IHACPA NWAU calculators page was used as the source of record for the initial archive pass. It listed calculator artifacts from 2026-27 back to 2013-14. Direct IHACPA-hosted Excel files and most SAS archives were downloadable.

The 2021-22 and 2022-23 SAS links resolved to Box HTML share pages instead of direct binary downloads. Those entries should remain marked as `external-html-only` until a direct-download or manually retrieved binary can be verified and restored.

Direct attempts to fetch those Box share URLs on 2026-05-10 returned HTTP 404, so there is no verified recoverable binary from the recorded links. The manifest should continue to represent those two entries as explicit gaps until a different approved source is found.

## Matrix Reference

- See [`IHACPA Source Archive Matrix`](./ihacpa-archive-matrix.md) for the year-by-year archive inventory.
- See [`IHACPA Tool Coverage Matrix`](./ihacpa-tool-coverage-matrix.md) for the feature-to-tool incorporation summary.
