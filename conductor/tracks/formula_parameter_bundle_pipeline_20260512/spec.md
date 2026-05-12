# Specification: Formula and Parameter Bundle Pipeline

## Overview
Build a formal pipeline for extracting, normalizing, versioning, and validating future IHACPA formulae and parameters from official calculators, technical specifications, workbooks, and data tables.

## Functional Requirements
- Define a versioned bundle format for formulas, weights, thresholds, adjustments, and stream-specific parameters.
- Add extraction steps from supported official formats such as SAS, Excel, CSV/XLSX tables, and manifest-linked artifacts.
- Add bundle provenance and validation evidence references.
- Add bundle loaders used by calculator modules instead of hidden globals.
- Add tests that compare bundle-loaded behavior to golden fixtures.

## Non-Functional Requirements
- Bundle changes must be reviewable and diffable.
- Formula representation must preserve traceability to source lines, sheets, or tables where practical.
- New bundles must remain unvalidated until fixture evidence passes.

## Acceptance Criteria
- At least one stream/year can load parameters from a versioned bundle.
- Bundle diffs identify formula and parameter changes.
- Docs explain how to add a future IHACPA release from source discovery through validation.
