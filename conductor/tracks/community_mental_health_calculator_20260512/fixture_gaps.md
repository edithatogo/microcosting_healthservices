# Fixture Gaps: Community Mental Health Calculator

## Summary

No golden validation fixtures currently exist for the community mental health
calculator stream. The existing ``tests/test_mh.py`` file uses synthetic mock
data produced in memory by ``_load_weights()`` rather than official IHACPA
calculator output.

## Gap Record

| Year | Stream | Golden Fixture | Reason |
|------|--------|----------------|--------|
| NEP21 (2021-22) | Community MH | Missing | No official MH golden fixtures have been extracted or validated |
| NEP22 (2022-23) | Community MH | Missing | AMHCC shadow Excel workbook exists but no validated output fixture |
| NEP23 (2023-24) | Community MH | Missing | No official MH golden fixtures have been extracted or validated |
| NEP24 (2024-25) | Community MH | Missing | No official MH golden fixtures have been extracted or validated |
| NEP25 (2025-26) | Community MH | Missing | No official MH golden fixtures have been extracted or validated |

## Next Steps

1. Extract official IHACPA calculator outputs from SAS runs for NEP25 (first
   active-pricing year).
2. Create synthetic fixture packs using ``tests/fixtures/golden/acute_2025/`` as
   a template, with a manifest, CSV inputs, and CSV expected outputs.
3. Register community mental health as a supported service stream in
   ``nwau_py/fixtures.py``.
