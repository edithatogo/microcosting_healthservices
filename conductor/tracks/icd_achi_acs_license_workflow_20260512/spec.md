# Specification: ICD-10-AM/ACHI/ACS Licensed Product Workflow

## Overview
Add a formal workflow for handling licensed classification products required for admitted acute grouping and validation, including ICD-10-AM, ACHI, ACS, AR-DRG definitions manuals, mapping tables, and grouper software.

## Functional Requirements
- Document which assets are public metadata versus licensed/restricted products.
- Add local-only paths and manifest references for user-supplied licensed products.
- Add checks that prevent restricted assets from being committed.
- Add setup docs for users who have legitimate access to licensed products.
- Add CI-safe tests using synthetic/minimal fixtures that do not contain restricted content.

## Non-Functional Requirements
- Repository must remain publishable without restricted classification products.
- Error messages must tell users what local asset is missing without exposing restricted content.
- Docs must be explicit that users are responsible for obtaining licenses where required.

## Acceptance Criteria
- Restricted asset patterns are ignored or guarded.
- Manifests can reference local licensed files without committing them.
- Documentation gives a safe setup path for licensed grouper/table users.

## Source Evidence
- IHACPA admitted acute care product and licence references: https://www.ihacpa.gov.au/health-care/classification/admitted-acute-care
