---
title: Source archive
slug: 2026/governance/source-archive
---

IHACPA raw archives are tracked with durable provenance and checksum metadata.
Generated artifacts stay out of version control.
Historical pricing specifications are tracked separately from calculator
artifacts, price weights, and NHCDC/costing evidence.

See the canonical source in [Conductor source-archive.md](https://github.com/edithatogo/microcosting_healthservices/blob/master/conductor/source-archive.md).

## Archive summary

* Manifest entries: 94
* Downloaded entries: 92
* Explicit gaps: 2 `box-html-only` pages
* Pricing specifications: 2012-13 through 2026-27
* Calculator artifacts: 2013-14 through 2026-27
* Price weights: tracked in the year-specific source bundles and spec tables
* NHCDC / costing evidence: tracked as separate costing-study evidence, not as calculator support
* 2026-27 NEP26 is present in the documentation set and the listed calculators are treated as available references only; parity validation is not claimed here unless test evidence is added.

## Historical coverage boundaries

| Artifact family | Coverage | Notes |
| --- | --- | --- |
| Pricing specifications | 2012-13 through 2026-27 | 2012-13 is the foundational ABF year and should be treated as a source-record year, not as proof of a public calculator artifact. |
| Calculator artifacts | 2013-14 through 2026-27 | Public calculator downloads are recorded separately from pricing specifications. |
| Price weights | 2013-14 through 2026-27 | Price weights are part of the pricing specification record and do not imply executable support by themselves. |
| NHCDC / costing evidence | Pre-2012-13 through 2026-27 | Useful for costing-study provenance and historical context, but not a calculator support claim. |
| Validation status | Per artifact and pricing year | Support claims should follow the recorded validation state, not the presence of a PDF or report alone. |

## Explicit gaps

| Year | Status | Notes |
| --- | --- | --- |
| 2021-22 | `box-html-only` | SAS page is recorded but the recorded Box URL now returns 404. |
| 2022-23 | `box-html-only` | SAS page is recorded but the recorded Box URL now returns 404. |

## Community mental health source status

| Pricing year | Status | Notes |
| --- | --- | --- |
| 2021-22 | Shadow-pricing inventory | Community MH SAS templates, price weights, and costing references are inventoried; no official golden fixture is checked in. |
| 2022-23 | Shadow-pricing inventory | AMHCC shadow workbook and associated price-weight references are inventoried; no official golden fixture is checked in. |
| 2023-24 | Shadow-pricing inventory | Community MH SAS artifacts and price-weight references are inventoried; no official golden fixture is checked in. |
| 2024-25 | Shadow-pricing inventory | Community MH SAS artifacts and price-weight references are inventoried; no official golden fixture is checked in. |
| 2025-26 | Active-pricing inventory | Community MH is separated from admitted MH in the contract surface; official-source fixture extraction remains a recorded gap. |
| 2026-27 | Shadow-pricing inventory | NEP26 community MH workbook and raw SAS archive are recorded as source artifacts; parity validation is not claimed. |

## Policy

* Keep the archive manifest truthful about what was actually downloaded.
* Record missing source material as an explicit gap rather than implying it is
  available.
* Distinguish documentation coverage from validation parity.
* State classification-version impacts explicitly when source records change.
* Use the archive matrices and coverage pages to explain the gap between source
  completeness and executable coverage.
