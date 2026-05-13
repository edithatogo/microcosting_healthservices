# Support Status Matrix

> Parallel-agent notice: this file defines shared status vocabulary for all
> agents. Do not invent alternate statuses in implementation or docs.

## Canonical statuses

| Status | Meaning |
| --- | --- |
| `unsupported` | The project does not support this stream, year, jurisdiction, or surface. |
| `blocked` | Support is desired but blocked by missing source, licence, parity, implementation, or release evidence. |
| `planned` | Work is planned but not implemented. |
| `canary` | Experimental implementation exists for limited synthetic or internal fixtures. |
| `opt_in` | Users may explicitly enable the surface or stream; it is not default. |
| `release_candidate` | Release evidence is complete enough for final validation before GA. |
| `ga` | Supported by default for the declared scope. |
| `no_new_development` | Roadmap entry is retained, but active implementation is paused unless reprioritized. |
| `historical` | Prior work or context retained for traceability, not an active product commitment. |

## Required dimensions

Every support declaration should identify:

- Calculator stream.
- Pricing or financial year.
- Jurisdiction.
- Surface or language.
- Runtime path.
- Source/evidence bundle.
- Validation status.
- Release status.
- Known limitations.

## Fail-closed rules

- Missing source evidence is `blocked`, not inferred support.
- Missing parity evidence is `blocked` or `canary`, not GA.
- Deferred language surfaces are `no_new_development`.
- Prior SQL/DuckDB references are `historical` unless reprioritized.
- Public docs must show the narrowest truthful status.
