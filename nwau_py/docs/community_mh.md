# Community Mental Health Calculator

## Overview

Community mental health care is the non-admitted mental health stream priced
through IHACPA's NWAU calculator framework. It is distinguished from admitted
mental health by AMHCC classification prefix ``"2"``.

## Supported Years

| Year | SAS Source | Pricing Status |
|------|-----------|----------------|
| 2021-22 (NEP21) | NWAU21_CALCULATOR_MH.sas | Shadow |
| 2022-23 (NEP22) | NWAU22_CALCULATOR_MH.sas | Shadow |
| 2023-24 (NEP23) | NWAU23_CALCULATOR_MH.sas | Shadow |
| 2024-25 (NEP24) | NWAU24_CALCULATOR_MH.sas | Shadow |
| 2025-26 (NEP25) | NWAU25_CALCULATOR_MH.sas | Active |

## Pricing Status

- **Shadow pricing** (NEP21-NEP24): Community mental health data was collected
  and calculated but not funded on an activity basis.
- **Active pricing** (NEP25+): Community mental health is priced for
  activity-based funding.

## Input Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| ``AMHCC`` | str | Yes | AMHCC classification code (must start with ``"2"`` for community) |
| ``SC_PAT_PUB`` | int | Yes | Service contacts with consumer present (public funding sources only) |
| ``SC_NOPAT_PUB`` | int | Yes | Service contacts without consumer present (public funding sources only) |

## Output

| Column | Description |
|--------|-------------|
| ``NWAU{year_suffix}`` | Calculated NWAU (e.g. ``NWAU25`` for 2025-26) |

## Caveats and Limitations

1. **No golden validation fixtures exist** for any community mental health
   year. See ``fixture_gaps.md`` for details.
2. The community calculator currently applies the service-contact formula
   without adjustment factors (specialist paediatric, indigenous, remoteness)
   that are applied in the combined mental health calculator. These adjustments
   are relevant only for the admitted substream.
3. AMHCC version differences across pricing years are not yet tracked in the
   contract schema.
4. The community NWAU does not apply private patient deductions.

## Usage

```python
from nwau_py.calculators import CommunityMHParams, calculate_community_mh

result = calculate_community_mh(
    df,
    CommunityMHParams(),
    year="2025",
)
```
