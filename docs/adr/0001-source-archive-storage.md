# ADR 0001: Source Archive Storage

## Status

Accepted

## Context

IHACPA calculator artifacts include large Excel, SAS, ZIP, and 7Z files. They are essential for provenance but can quickly make normal Git history large and difficult to clone.

## Decision

Commit durable IHACPA provenance manifests, acquisition scripts, checksums, extraction code, and documentation to Git. Store raw IHACPA binaries outside normal Git history by default, using external object storage as the primary storage backend unless a later project decision explicitly chooses Git LFS or GitHub release assets for a narrower slice of artifacts.

The committed manifest location is part of the durable project record and should live outside ignored raw storage, for example under `data/provenance/ihacpa/`.

Any acquisition pass must record run context, source-page snapshot location, redirect information, checksum algorithm, checksum value, and artifact status. Any restore workflow must verify checksums before extraction or validation.

## Consequences

The repository remains lightweight while preserving auditability. Reproducibility depends on committed manifests, verified checksums, and a documented storage backend for raw artifacts.
