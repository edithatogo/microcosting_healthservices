# Supply-Chain Controls

## Scope

This document captures the minimum controls expected by the release and
supply-chain governance track.

## Controls

1. Verify source checksums before extraction.
2. Keep provenance manifests in the tracked location, not ignored raw storage.
3. Use locked installs for build and validation jobs.
4. Record the lockfile revision, package version, data bundle version, and
   validation status in release artifacts.
5. Publish SBOMs and signed artifacts when the distribution channel supports
   them.
6. For Rust work, add `cargo audit` and `cargo deny` to the release review
   checklist before claims about published artifacts expand.
7. Do not claim a push or merge is ready until the relevant GitHub Actions checks have passed.
8. Review Renovate updates that touch runtime dependencies, toolchain
   dependencies, or GitHub Actions before merging.

## Evidence

Release notes and registry entries should name the calculator, year, parity
type, fixture set, tolerance, and reviewer for any validation claim that
changes release status.
