# Specification: Emergency UDG/AECC Transition Registry

## Overview
Add a roadmap capability for emergency care classification versioning and transition handling. Emergency care classification historically used Urgency Disposition Groups (UDG) and now uses the Australian Emergency Care Classification (AECC). The project needs explicit version, pricing-year, and stream compatibility metadata rather than treating emergency group codes as interchangeable.

## Functional Requirements
- Extend the coding-set registry with UDG and AECC version records.
- Track pricing-year applicability for UDG, AECC, and transitional/shadow periods.
- Represent emergency service versus emergency department stream compatibility.
- Add validation that rejects incompatible UDG/AECC codes for a selected pricing year.
- Document the transition from UDG to AECC and how users should supply source fields.

## Non-Functional Requirements
- Do not silently translate UDG to AECC unless an official mapping or validated local mapping is supplied.
- Preserve explicit provenance for any mapping table or grouper output.
- Keep emergency classification status separate from NWAU pricing validation status.

## Acceptance Criteria
- Registry records identify which pricing years expect UDG, AECC, or transitional handling.
- Emergency calculator validation can distinguish incompatible emergency classification inputs.
- Documentation explains UDG versus AECC and supported conversion paths.

## Source Evidence
- IHACPA AECC: https://www.ihacpa.gov.au/health-care/classification/emergency-care/aecc
- IHACPA UDG: https://www.ihacpa.gov.au/health-care/classification/emergency-care/udg
- IHACPA emergency care classification: https://www.ihacpa.gov.au/health-care/classification/emergency-care
