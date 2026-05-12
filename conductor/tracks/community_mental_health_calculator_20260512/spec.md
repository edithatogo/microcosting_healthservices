# Specification: Community Mental Health Calculator Support

## Overview
Add first-class support for community mental health care where IHACPA calculator materials include community mental health, including prior AMHCC shadow material and current 2025-26 calculator listings.

## Functional Requirements
- Inventory annual community mental health and AMHCC shadow calculator artifacts.
- Define a separate module/API surface from admitted mental health.
- Add input schema requirements and output columns for community mental health calculations.
- Add validation fixtures from official calculator outputs where available.
- Add documentation explaining AMHCC versioning and transition from shadow pricing to active pricing.

## Non-Functional Requirements
- Keep admitted and community mental health behavior separate unless source material proves shared logic.
- Mark shadow-pricing years distinctly from actively priced years.
- Avoid using licensed/non-redistributable classification material unless permitted.

## Acceptance Criteria
- Community mental health appears as a distinct calculator stream in docs and validation status.
- API/CLI planning clearly identifies required inputs and outputs.
- At least one official-source fixture is identified or a gap record explains why it is unavailable.

## Source Evidence
- IHACPA NWAU calculators: https://www.ihacpa.gov.au/what-we-do/national-weighted-activity-unit-nwau-calculators
- IHACPA mental health care and AMHCC: https://www.ihacpa.gov.au/what-we-do/development-australian-mental-health-care-classification
