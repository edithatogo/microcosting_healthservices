# Source Archive Policy

## Purpose

The IHACPA source archive is the provenance baseline for calculator fidelity. It should preserve raw calculator artifacts and describe how each artifact moves from raw source to extracted data, implementation behavior, and validation evidence.

## Storage Policy

Raw downloaded binaries should not be committed to normal Git history by default. Use one of:

- Git LFS for versioned binary artifacts when repository-level access is acceptable.
- GitHub release assets for immutable public snapshots.
- External object storage for larger or access-controlled archives.

The repository should commit scripts, manifests, checksums, extraction code, and documentation. Raw binaries should only be committed after an explicit storage decision.

## Manifest Requirements

Each source artifact manifest entry should include:

- Pricing year label and start year.
- Artifact type, such as Excel, SAS, support data, compiled reference, or documentation.
- Service stream.
- Source page URL.
- Original artifact URL.
- Final redirected URL.
- Local path or object-storage URI.
- File size in bytes.
- SHA-256 checksum.
- Content type.
- Download timestamp.
- Acquisition status.
- Notes for inaccessible or externally hosted assets.

## Status Terms

- `listed`: The artifact appears on an official source page.
- `downloaded`: The artifact was downloaded and checksumed.
- `external-html-only`: The source URL returned an HTML share page rather than the binary artifact.
- `extracted`: Project tooling parsed relevant tables, formulas, or metadata.
- `implemented`: Calculator logic exists in project code.
- `validated`: Output or source parity checks have been performed and recorded.

## Current Acquisition Notes

The IHACPA NWAU calculators page was used as the source of record for the initial archive pass. It listed calculator artifacts from 2026-27 back to 2013-14. Direct IHACPA-hosted Excel files and most SAS archives were downloadable. The 2021-22 and 2022-23 SAS links resolved to Box HTML share pages and require a direct-download workflow or manual retrieval.

