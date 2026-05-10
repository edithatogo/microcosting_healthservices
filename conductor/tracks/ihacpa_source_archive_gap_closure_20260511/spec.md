# Specification: IHACPA Source Archive Gap Closure and Restore Validation

## Overview

Validate the IHACPA source archive against the committed manifest, recover the
remaining source gaps if a direct or approved retrieval path exists, and keep
the archive record truthful when a raw binary cannot be recovered.

The current archive inventory is large enough to support feature work, but it is
not yet fully closed:

- `archive/ihacpa/raw/manifest.json` contains 94 entries.
- 92 entries are `downloaded`.
- 2 entries are `box-html-only` SAS pages for `2021-22` and `2022-23`.
- Every entry marked `downloaded` currently has a corresponding file on disk.

## Current State

- The archive spans `2013-14` through `2026-27`.
- The durable manifest exists and is tracked in Git.
- The restore policy already distinguishes downloaded artifacts from HTML-only
  provenance gaps.
- The only unresolved source gaps are the two Box-hosted SAS pages.

## Functional Requirements

- Verify the committed manifest matches the on-disk archive tree.
- Attempt to recover the direct binary or an approved verifiable copy for the
  `2021-22` and `2022-23` SAS entries.
- If recovery succeeds, update the manifest and restore notes with the verified
  path, checksum, content type, and acquisition context.
- If recovery does not succeed, keep the entries explicitly recorded as gaps
  rather than pretending the raw binary exists.
- Normalize the source-archive terminology so the manifest, docs, and tests
  describe gaps consistently.
- Document the restore workflow for future acquisition passes.

## Non-Functional Requirements

- Do not change calculator logic in this track.
- Keep source-provenance claims conservative and auditable.
- Preserve the distinction between downloaded binaries and recorded gaps.

## Acceptance Criteria

- Every manifest entry is accounted for as downloaded or explicitly gap
  recorded.
- Every downloaded entry has a matching on-disk file.
- The two Box-hosted SAS entries are either recovered and verified or remain
  documented gaps with a clear restore note.
- Source archive documentation and tests reflect the final state.

## Out of Scope

- Calculator implementation changes.
- Feature parity work in calculator modules.
- Reclassifying unresolved HTML-only pages as downloaded without verification.
