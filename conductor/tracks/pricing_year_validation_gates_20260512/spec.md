# Specification: Pricing-Year Validation Gates

## Overview
Add strict gates that prevent future formulae, parameters, and coding sets from being treated as production-ready until required source, extraction, and fixture validation evidence exists.

## Functional Requirements
- Define validation statuses such as discovered, archived, extracted, implemented, fixture-tested, validated, and deprecated.
- Add checks that prevent docs/API metadata from claiming support beyond recorded validation status.
- Add `nwau validate-year <year>` to verify manifest completeness and fixture evidence.
- Add CI tests that fail on unsupported status transitions or missing evidence.

## Non-Functional Requirements
- Validation must be conservative and auditable.
- Status changes must be explicit in review diffs.
- Errors must identify the missing evidence needed to advance status.

## Acceptance Criteria
- Invalid support claims fail tests.
- A pricing year cannot be marked validated without fixture evidence.
- Documentation generated from manifests reflects validation status accurately.
