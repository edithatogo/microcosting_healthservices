# Specification: Modernization Foundation

## Track Description

Establish the modernization foundation for calculator fidelity, validation, source archiving, web delivery, and Power Platform interoperability.

## Background

The project currently implements IHACPA NWAU calculator logic in Python with pandas-oriented modules and a CLI. The product direction is to accurately reflect IHACPA calculators using all available source material: Excel workbooks, SAS archives, compiled or Python reference artifacts, extracted tables, and supporting files.

The project should mature toward a stronger multi-target architecture that can support:

- A Python calculation library with high-confidence parity tests.
- A GitHub Pages-hosted web application.
- A Power Platform application backed by a C# calculation engine.
- A source archive and validation workflow covering all available IHACPA calculator years and service streams.

## Goals

- Establish a repeatable source acquisition and manifest workflow for IHACPA calculator artifacts.
- Introduce project tooling foundations for Python 3.10-3.14, uv, Codecov, ty, Hypothesis, mutmut, Scalene, Renovate, and Vale.
- Define strict boundaries between calculator formulas, parameters, schemas, data loading, provenance, CLI, and future UI/API layers.
- Define a path from pandas legacy behavior toward Polars, Arrow-backed data, Pydantic validation, and carefully justified JAX/XLA compute paths.
- Prepare architectural seams for a GitHub Pages web app and a Power Platform/C# calculation engine without compromising source fidelity.
- Improve documentation so calculator provenance, validation status, and implementation behavior are transparent.

## Non-Goals

- Rewrite all calculator implementations in this track.
- Replace pandas with Polars in one broad change.
- Claim validation for any pricing year that has not been checked against trusted reference behavior.
- Build the full web application or full Power Platform app in this track.
- Commit large raw IHACPA binary archives without a deliberate repository storage decision.

## Requirements

- Source downloads must be represented in a machine-readable manifest with year, type, service stream, URL, local path, byte count, and acquisition status.
- The project must distinguish raw source archives from extracted, normalized, and validated data.
- Calculator behavior must remain deterministic for a given input, pricing year, parameter model, and reference data bundle.
- New architecture documentation must identify Python, web, and C# calculation-engine boundaries.
- CI design must cover Python 3.10, 3.11, 3.12, 3.13, and 3.14.
- Coverage should remain above 80% in the short term and progress toward above 90% as calculator abstractions stabilize.
- Documentation must distinguish archived, extracted, implemented, and validated status.

## Acceptance Criteria

- PR 122 is merged and verified locally.
- IHACPA calculator source acquisition has a manifest covering all available page-listed years and service stream files.
- Any inaccessible external downloads are recorded with source URL and status.
- A tooling migration plan exists for uv, Codecov, ty, Hypothesis, mutmut, Scalene, Renovate, and Vale.
- An architecture plan exists for calculator core abstractions and future web/C# surfaces.
- The first implementation phase can begin without needing to rediscover product direction.
