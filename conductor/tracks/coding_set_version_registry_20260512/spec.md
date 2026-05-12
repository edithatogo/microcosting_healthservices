# Specification: Coding-Set Version Registry

## Overview
Create a machine-readable registry for coding and classification sets used by IHACPA pricing years, including AR-DRG, AECC, UDG, Tier 2, AMHCC, ICD-10-AM, ACHI, and ACS.

## Functional Requirements
- Record coding-set names, versions, release dates, implementation dates, licensing/redistribution constraints, and applicable pricing years.
- Link pricing-year manifests to coding-set registry entries.
- Add validators that reject incompatible coding-set versions for a selected pricing year.
- Document where users must obtain licensed classification products.

## Non-Functional Requirements
- Do not redistribute licensed coding products unless permitted.
- Registry entries must distinguish public metadata from restricted code lists or groupers.
- Version compatibility must be explicit and testable.

## Acceptance Criteria
- Registry includes all classification families currently relevant to the package.
- Pricing-year validators can resolve expected coding-set versions.
- Docs explain public versus licensed/restricted artifacts.
