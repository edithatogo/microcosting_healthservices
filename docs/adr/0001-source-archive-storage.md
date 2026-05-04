# ADR 0001: Source Archive Storage

## Status

Proposed

## Context

IHACPA calculator artifacts include large Excel, SAS, ZIP, and 7Z files. They are essential for provenance but can quickly make normal Git history large and difficult to clone.

## Decision

Do not commit raw IHACPA binaries to normal Git history by default. Commit acquisition scripts, manifests, checksums, extraction code, and documentation. Choose Git LFS, GitHub release assets, or external object storage before making raw binaries part of the durable project record.

## Consequences

The repository remains lightweight. Reproducibility depends on manifests, checksums, and a documented storage backend for raw artifacts.

