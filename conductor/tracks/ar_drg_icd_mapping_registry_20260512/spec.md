# Specification: AR-DRG ICD/ACHI/ACS Mapping Registry

## Overview
Add a roadmap capability for versioned mapping between ICD-10-AM diagnosis codes, ACHI intervention codes, ACS coding standards, and AR-DRG versions. AR-DRGs are derived from coded admitted-episode data using version-specific grouping logic and tables, so the project needs explicit version tracking and table provenance rather than treating AR-DRG as a simple input column.

## Functional Requirements
- Extend the coding-set registry with explicit relationships between ICD-10-AM, ACHI, ACS, and AR-DRG versions.
- Track mapping table families by AR-DRG version and effective pricing years.
- Represent version-specific code validity, diagnosis/intervention mapping, and grouping-table provenance where legally available.
- Support local references to licensed mapping tables without committing restricted content.
- Link admitted-acute input validation to the expected ICD-10-AM/ACHI/ACS and AR-DRG version set.

## Non-Functional Requirements
- Do not redistribute licensed IHACPA classification products unless permitted.
- Registry entries must distinguish public metadata, user-supplied licensed files, and derived validation fixtures.
- Mapping metadata must be strict enough to prevent mixing incompatible ICD-10-AM/ACHI/ACS and AR-DRG versions.

## Acceptance Criteria
- The roadmap defines how AR-DRG versions relate to ICD-10-AM/ACHI/ACS versions by pricing year.
- Admitted acute validation can identify incompatible coding-set combinations.
- Documentation explains which mapping/grouping assets users must supply locally.

## Source Evidence
- IHACPA admitted acute care: https://www.ihacpa.gov.au/health-care/classification/admitted-acute-care
- IHACPA AR-DRGs: https://www.ihacpa.gov.au/admitted-acute-care/ar-drg-classification-system
- IHACPA AR-DRG Version 12.0: https://www.ihacpa.gov.au/resources/ar-drg-version-120
