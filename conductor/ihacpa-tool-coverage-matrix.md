# IHACPA Tool Coverage Matrix

This matrix summarizes which archive families and year ranges are incorporated
into the tool surface today.

## Tool Coverage

| Family | Archive years present | Current tool surface | Incorporated status | Notes |
| --- | --- | --- | --- | --- |
| Acute admitted | 2013-14 through 2026-27 | `nwau_py.calculators.acute` and opt-in `calculate_acute_rust_2025` | implemented, with a 2025 Rust canary | Python remains the default runtime path |
| Subacute admitted | 2013-14 through 2026-27 | `nwau_py.calculators.subacute` | implemented | Year-aware loader is in the Python surface |
| Emergency department | 2013-14 through 2026-27 | `nwau_py.calculators.ed` | implemented | Covers AECC and UDG branches |
| Non-admitted / outpatient | 2013-14 through 2026-27 | `nwau_py.calculators.outpatients` | implemented | Covers the non-admitted calculator family |
| Mental health | 2021-22 through 2026-27 | `nwau_py.calculators.mh` | implemented | Covers admitted and community mental health variants |
| Adjustment helpers | 2022-23 through 2026-27 | `nwau_py.calculators.adjust` | implemented | HAC, AHR, and complexity are internal helper outputs |
| Archive provenance | 2013-14 through 2026-27 | `archive/ihacpa/raw/manifest.json` and provenance helpers | implemented | The manifest is the canonical source record |
| SAS HTML-only gaps | 2021-22 and 2022-23 | not incorporated | gap recorded | These entries remain explicit follow-on work |

## Summary

- Implemented tool surfaces: 6
- Explicit gaps still not incorporated: 2 archive entries
- Partial implementation: 1 Rust-backed acute canary

The tool surface is family-complete for the major calculator modules, but
NEP26 support is documentation-visible rather than parity-validated unless
tests prove it. Acute coverage should be read with the classification split in
mind: admitted acute uses AR-DRG v12.0 and non-admitted uses Tier 2 v10.0.
The archive still carries two explicit Box-hosted SAS gaps and the Rust path
remains opt-in.
