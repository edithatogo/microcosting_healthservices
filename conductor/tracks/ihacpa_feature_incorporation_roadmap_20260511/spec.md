# Specification: IHACPA Feature Incorporation and Calculator Coverage Roadmap

## Overview

Build a complete feature inventory from the IHACPA source archive, map each
family and helper to the current executable surfaces, and close any remaining
implementation gaps with tests and parity evidence.

The repository already implements the major calculator families:

- `acute`
- `subacute`
- `ed`
- `outpatients`
- `mh`
- `adjust`

Adjustment logic already includes HAC, AHR, and complexity handling, but that
logic needs to be audited against the source corpus so the repo can clearly say
what is implemented, what is only documented, and what still needs work.

## Current State

- Raw IHACPA artifacts span the full archive from `2013-14` through `2026-27`.
- The codebase already has executable surfaces for the main calculator families.
- The `adjust` pipeline currently carries HAC, AHR, and complexity outputs.
- There is not yet a single inventory matrix that maps every archive family and
  helper to its implementation or gap status.

## Functional Requirements

- Inventory every calculator family, helper, and year-specific variant present in
  the source archive.
- Map each item to one of: implemented, documented-only, missing, or deferred.
- Verify whether complexity, HAC, and AHR should remain internal adjustment
  helpers or be surfaced more explicitly in the public calculator docs.
- Identify any calculator-year combinations or helper features that still lack
  parity coverage.
- Add tests that lock the inventory matrix and the chosen implementation status.
- Implement the missing pieces or add explicit follow-on gaps where the source
  material does not justify implementation yet.

## Non-Functional Requirements

- Keep calculator behavior explainable against the IHACPA source material.
- Avoid claiming support for a family or year until parity evidence exists.
- Preserve the current default runtime behavior while new surfaces are added.

## Acceptance Criteria

- A source-to-code feature matrix exists and is test-backed.
- Complexity, HAC, and AHR have an explicit status in the roadmap.
- Every archive family is classified as implemented, documented-only, missing,
  or deferred.
- Any missing implementation work is tracked with concrete follow-on tasks.

## Out of Scope

- Raw archive acquisition recovery.
- Power Platform or Power BI work.
- Changing the Rust-core migration roadmap unless the feature inventory proves a
  calculator family depends on it.
