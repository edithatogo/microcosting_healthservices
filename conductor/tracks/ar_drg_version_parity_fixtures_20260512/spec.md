# Specification: AR-DRG Version Parity Fixtures

## Overview
Create a validation fixture strategy for AR-DRG version-specific behavior. Because AR-DRGs vary by version and are derived from coded episode data, the project needs fixture sets that prove version-compatible behavior for admitted acute NWAU calculations and any grouper integration.

## Functional Requirements
- Define fixture schema for coded admitted episodes, expected AR-DRG, and expected NWAU inputs/outputs.
- Support synthetic fixtures and user-supplied licensed/reference fixtures.
- Track fixture provenance, coding-set version, grouper version, and pricing year.
- Add tests for version-specific changes and invalid cross-version reuse.

## Non-Functional Requirements
- Synthetic fixtures must not contain restricted code tables beyond permissible illustrative values.
- Reference fixtures derived from licensed products must be local-only or redacted unless redistributable.
- Fixtures must support both precomputed AR-DRG and external-grouper workflows.

## Acceptance Criteria
- Fixture schema captures ICD-10-AM/ACHI/ACS version, AR-DRG version, grouper version, and pricing year.
- Tests prevent reusing fixtures with incompatible versions.
- Docs explain how maintainers add safe synthetic and local licensed fixtures.

## Source Evidence
- IHACPA AR-DRGs: https://www.ihacpa.gov.au/admitted-acute-care/ar-drg-classification-system
- IHACPA AR-DRG Version 12.0: https://www.ihacpa.gov.au/resources/ar-drg-version-120
