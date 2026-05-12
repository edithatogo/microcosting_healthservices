# Specification: Emergency Classification Parity Fixtures

## Overview
Create a validation fixture strategy for emergency classification behavior across UDG and AECC versions. Fixtures should prove classification compatibility, mapping behavior where allowed, and downstream emergency NWAU behavior for pricing years.

## Functional Requirements
- Define fixture schema for raw emergency source fields, expected UDG/AECC classification, pricing year, stream, and expected NWAU-relevant outputs.
- Support synthetic fixtures and user-supplied official/local reference fixtures.
- Track mapping table version, classifier version, pricing year, and validation status.
- Add tests that reject cross-version fixture reuse.

## Non-Functional Requirements
- Synthetic fixtures must avoid restricted mapping-table content unless redistributable.
- Local official fixtures must remain local-only or redacted unless licensed for redistribution.
- Fixtures must support both precomputed classification and derived classification workflows.

## Acceptance Criteria
- Fixture schema captures UDG/AECC version, source mapping version, pricing year, and stream.
- Tests prevent using UDG fixtures in AECC-only years and vice versa unless a declared transition mapping exists.
- Docs explain safe fixture creation and validation workflow.

## Source Evidence
- IHACPA AECC: https://www.ihacpa.gov.au/health-care/classification/emergency-care/aecc
- IHACPA UDG: https://www.ihacpa.gov.au/health-care/classification/emergency-care/udg
