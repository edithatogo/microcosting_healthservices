# Specification: Emergency Code Mapping Pipeline

## Overview
Define a pipeline for versioned emergency classification mappings. Emergency records may contain source fields that need to be converted into UDG or AECC-compatible classification codes depending on pricing year and stream. The pipeline must be table-driven, versioned, and provenance-aware.

## Functional Requirements
- Define mapping-bundle schema for emergency classification source fields, UDG outputs, AECC outputs, and pricing-year applicability.
- Support official or user-supplied mapping tables with checksums and provenance.
- Add mapping diagnostics for unknown, unmapped, deprecated, or invalid source codes.
- Add strict rules that prevent UDG/AECC crosswalk use without a declared mapping source.
- Support dry-run mapping summaries for data-quality review.

## Non-Functional Requirements
- Do not invent mappings where official/source-backed mappings are unavailable.
- Mapping behavior must be deterministic and diffable by version.
- Preserve raw source fields and mapped output fields for auditability.

## Acceptance Criteria
- Mapping bundles can represent at least one UDG-era and one AECC-era example.
- Tests cover mapped, unmapped, invalid, and version-incompatible cases.
- Docs explain how to add future emergency mapping tables.

## Source Evidence
- IHACPA AECC: https://www.ihacpa.gov.au/health-care/classification/emergency-care/aecc
- IHACPA UDG: https://www.ihacpa.gov.au/health-care/classification/emergency-care/udg
