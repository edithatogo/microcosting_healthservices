# IHACPA Tool Coverage Matrix

This matrix separates historical pricing specifications, calculator artifacts,
price weights, NHCDC/costing evidence, and validation status. Historical
pricing specifications go back to 2012-13. Calculator artifacts are tracked
separately and should not be assumed for 2012-13 unless a source record
explicitly exists.

## Historical source matrix

| Artifact family | Earliest confirmed coverage | Current record | Validation status | Notes |
| --- | --- | --- | --- | --- |
| Pricing specifications | 2012-13 through 2026-27 | NEP determinations and national pricing model technical specifications | documented | 2012-13 is a foundational ABF year and stays caveated; it does not imply a public calculator artifact. |
| Calculator artifacts | 2013-14 through 2026-27 | Public calculator downloads, archive manifests, and executable calculator surfaces | implemented or gap-recorded by year | Use this row for public calculator support only. Do not infer 2012-13 support from pricing specs or costing evidence. |
| Price weights | 2013-14 through 2026-27 | Stream price-weight tables and year-specific constants | documented or fixture-backed by year | Price weights are distinct from executable calculators and distinct from NHCDC evidence. |
| NHCDC / costing evidence | pre-2012-13 through 2026-27 | NHCDC reports, cost report appendices, and costing-study references | documented | Useful for costing studies and provenance, but not calculator support on its own. |
| Validation status | per artifact and pricing year | discovered, archived, extracted, implemented, fixture-tested, validated, deprecated | explicit | Support claims should follow the recorded status, not the presence of a source file alone. |

## Executable calculator coverage

| Family | Archive years present | Current tool surface | Incorporated status | Notes |
| --- | --- | --- | --- | --- |
| Acute admitted | 2013-14 through 2026-27 | `nwau_py.calculators.acute` and opt-in `calculate_acute_rust_2025` | implemented, with a 2025 Rust canary | Python remains the default runtime path. |
| Subacute admitted | 2013-14 through 2026-27 | `nwau_py.calculators.subacute` | implemented | Year-aware loader is in the Python surface. |
| Emergency department | 2013-14 through 2026-27 | `nwau_py.calculators.ed` | implemented | Covers AECC and UDG branches. |
| Non-admitted / outpatient | 2013-14 through 2026-27 | `nwau_py.calculators.outpatients` | implemented | Covers the non-admitted calculator family. |
| Mental health | 2021-22 through 2026-27 | `nwau_py.calculators.mh` | implemented | Covers admitted and community mental health variants. |
| Adjustment helpers | 2022-23 through 2026-27 | `nwau_py.calculators.adjust` | implemented | HAC, AHR, and complexity are internal helper outputs. |
| Archive provenance | 2013-14 through 2026-27 | `archive/ihacpa/raw/manifest.json` and provenance helpers | implemented | The manifest is the canonical source record. |
| SAS HTML-only gaps | 2021-22 and 2022-23 | not incorporated | gap recorded | These entries remain explicit follow-on work. |

## Summary

- Historical pricing specifications recorded from 2012-13 onward
- Implemented executable calculator surfaces: 6
- Explicit gaps still not incorporated: 2 archive entries
- Partial implementation: 1 Rust-backed acute canary

The archive should be read as a layered record: pricing specs, price weights,
calculator artifacts, and NHCDC/costing evidence are separate things. Acute
coverage should be read with the classification split in mind: admitted acute
uses AR-DRG v12.0 and non-admitted uses Tier 2 v10.0. The archive still carries
two explicit Box-hosted SAS gaps and the Rust path remains opt-in.
