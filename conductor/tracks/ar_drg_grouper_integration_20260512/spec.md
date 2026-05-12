# Specification: AR-DRG Grouper Integration

## Overview
Define an integration path for deriving AR-DRGs from ICD-10-AM/ACHI/ACS-coded admitted episode data using a licensed external grouper or user-supplied grouping service. The package should not reimplement proprietary grouping logic unless legally and technically permissible.

## Functional Requirements
- Define a pluggable grouper interface for admitted acute episodes.
- Support user-supplied external grouper command, service, or file-exchange integration.
- Validate grouper version compatibility with selected pricing year.
- Capture provenance for derived AR-DRG outputs, including grouper version, coding-set version, timestamp, and input hash.
- Allow workflows where AR-DRG is precomputed and validated rather than derived inside the package.

## Non-Functional Requirements
- Keep proprietary grouping logic outside the repository unless licensing permits inclusion.
- Never silently group with an incompatible version.
- Preserve deterministic audit trails for grouped outputs.

## Acceptance Criteria
- A clear interface exists for precomputed DRGs and external-grouper-derived DRGs.
- Validation rejects mismatched grouper/coding-set/pricing-year combinations.
- Docs explain supported and unsupported grouper workflows.

## Source Evidence
- IHACPA AR-DRGs: https://www.ihacpa.gov.au/admitted-acute-care/ar-drg-classification-system
- IHACPA admitted acute care: https://www.ihacpa.gov.au/health-care/classification/admitted-acute-care
