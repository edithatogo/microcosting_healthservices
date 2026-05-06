# Release Policy

## Purpose

Release artifacts must be reproducible, auditable, and resistant to accidental
calculator behavior drift.

## Release Types

- **Code release**: package code and helper logic.
- **Data bundle release**: bundled reference data, manifests, and checksums.
- **Validation-status release**: a change in parity, fixture, or validation
  status without a code change.

## Required Metadata

Every release should identify:

- Package version.
- Calculator data bundle version.
- Validation status.
- Source checksum set.
- Lockfile revision used for the build.
- Evidence-backed parity records for the release claim.

## Supply-Chain Controls

- Release workflows should run from a locked environment.
- Source artifact checksums must be verified before extraction or validation.
- SBOM generation should be available for published artifacts.
- Signed artifacts should be used where the distribution channel supports them.
- Renovate updates that touch calculator-impacting dependencies require review
  against the validation surface.

## Reviewer Rule

Do not merge a release that broadens a validation claim without a matching
manifest, fixture, or registry record that names the calculator, year, parity
type, fixture set, tolerance, and reviewer.
