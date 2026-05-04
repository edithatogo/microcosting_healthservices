# ADR 0001: Source Archive Storage

## Status

Accepted

## Context

IHACPA calculator artifacts include large Excel, SAS, ZIP, and 7Z files. They are essential for provenance but can quickly make normal Git history large and difficult to clone.

## Decision

Commit durable IHACPA provenance manifests, acquisition scripts, checksums, extraction code, and documentation to Git. The durable manifest should live in a tracked provenance path such as `data/provenance/ihacpa/sources.json`, not in ignored raw storage.

Store raw IHACPA binaries outside normal Git history by default, using external object storage as the primary storage backend unless a later project decision explicitly chooses Git LFS or GitHub release assets for a narrower slice of artifacts.

Transient acquisition output may still be written under `archive/ihacpa/raw/` during download runs, but that location is not the canonical project record.

Any acquisition pass must record run context, source-page snapshot location, redirect information, checksum algorithm, checksum value, and artifact status. Any restore workflow must verify checksums before extraction or validation.

Box-hosted links that only expose HTML share pages are acceptable as recorded provenance gaps, but they should be marked as `external-html-only` until a direct-download or manual retrieval path produces a verifiable raw artifact.

## Consequences

The repository remains lightweight while preserving auditability. Reproducibility depends on committed manifests, verified checksums, and a documented storage backend for raw artifacts.
