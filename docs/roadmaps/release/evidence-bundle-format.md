# Release Evidence Bundle Format

> Parallel-agent notice: release claims should reference this evidence bundle
> format. Do not mark a stream or surface GA without the required evidence.

## Required bundle contents

- Release identifier.
- Git commit and tag.
- Package names and versions.
- Supported streams and years.
- Supported jurisdictions.
- Supported surfaces.
- Source manifests and checksums.
- Formula and parameter bundle versions.
- Schema versions.
- Fixture results.
- Python parity report.
- SAS/Excel parity report where applicable.
- Coverage report.
- SBOM.
- Security scan summary.
- Provenance manifest.
- Known limitations.
- Rollback instructions.

## Status rule

If any required evidence is missing, the relevant stream, jurisdiction, or
surface cannot be `ga`.
