# Fixture Gaps: Community Mental Health Calculator

## Summary

Community mental health currently has no golden validation fixtures checked in.
The existing ``tests/test_mh.py`` coverage relies on synthetic in-memory data
from ``_load_weights()`` rather than official IHACPA calculator outputs.

That means the repository has an executable mental health calculator, but it
does not yet have a verified source bundle to use as a parity oracle for the
community mental health stream.

## Official-source fixture availability

| Year | Stream | Fixture status | Notes |
|------|--------|-----------------|--------|
| NEP21 (2021-22) | Community MH | Missing | No official MH fixture pack has been extracted or validated. |
| NEP22 (2022-23) | Community MH | Shadow source only | An AMHCC shadow Excel workbook exists, but there is no validated output fixture. |
| NEP23 (2023-24) | Community MH | Missing | No official MH fixture pack has been extracted or validated. |
| NEP24 (2024-25) | Community MH | Missing | No official MH fixture pack has been extracted or validated. |
| NEP25 (2025-26) | Community MH | Missing | First active-pricing year in this track, but no official output fixture has been extracted yet. |

## Shadow pricing versus active pricing

The NEP22 workbook should be treated as a shadow-pricing reference, not an
active-pricing validation source.

- Shadow pricing material is useful for understanding field shape, workbook
  structure, and historical calculator behavior.
- Active pricing material is the correct parity target for final calculator
  validation because it reflects the production pricing year that the repository
  is expected to reproduce.
- Do not infer active-pricing correctness from shadow workbook numbers unless a
  matching official output fixture has been extracted and checked against the
  same input bundle.

## Safe validation caveats

- Do not treat synthetic test data as evidence of parity with IHACPA source
  outputs.
- Do not backfill missing fixtures with approximations, copied rows, or locally
  generated expectations.
- If only shadow-pricing material is available, limit validation to structural
  checks such as schema loadability, required column presence, and deterministic
  row handling.
- Numerical parity claims should be reserved for official-source fixtures from
  the relevant pricing year.

## Next steps

1. Extract official IHACPA calculator outputs for NEP25, the first active-pricing year in this track.
2. Build a fixture pack from that official source bundle using the existing
   golden-pack layout as the template.
3. Register community mental health as a supported service stream in
   ``nwau_py/fixtures.py`` once the fixture pack exists.
