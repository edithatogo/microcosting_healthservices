# Specification: Emergency Grouper Integration

## Overview
Define integration for deriving emergency classification outputs through an official, licensed, or user-supplied grouper/mapping service where available. This parallels the AR-DRG external-grouper pattern while preserving UDG/AECC transition semantics.

## Functional Requirements
- Define a pluggable emergency classifier interface for source emergency records.
- Support precomputed UDG/AECC inputs, external command integration, service integration, or file-exchange integration.
- Validate classifier version compatibility with pricing year and stream.
- Capture provenance for derived emergency classification outputs, including tool version, table version, timestamp, and input hash.
- Support no-op validation mode for users who provide precomputed official classifications.

## Non-Functional Requirements
- Do not embed restricted or proprietary grouping/mapping logic unless permitted.
- Never silently convert between UDG and AECC without declared source provenance.
- Keep tool errors and unmapped code diagnostics visible to users.

## Acceptance Criteria
- Interface covers precomputed and externally derived UDG/AECC outputs.
- Validation rejects incompatible tool/table/pricing-year combinations.
- Docs explain supported emergency classification integration workflows.

## Source Evidence
- IHACPA emergency care classification: https://www.ihacpa.gov.au/health-care/classification/emergency-care
