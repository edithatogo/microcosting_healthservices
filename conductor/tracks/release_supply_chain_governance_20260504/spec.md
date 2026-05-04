# Specification: Release and Supply-Chain Governance

## Goal

Make releases reproducible, auditable, and resistant to accidental calculator behavior drift.

## Requirements

- Release artifacts should include package version, calculator data bundle version, validation status, and source checksums.
- Dependency updates should be reviewable and should not silently change calculator outputs.
- Release workflows should support SBOM generation, signed artifacts, and pinned tool versions.
- CI should verify source artifact checksums before extraction or validation.

## Acceptance Criteria

- Release policy distinguishes code releases, data bundle releases, and validation-status changes.
- Supply-chain controls are documented and represented in CI or release plans.
- Renovate rules are aligned with calculator validation requirements.
