# Parallelization Plan

## Purpose

This track is designed for six subagents working in parallel while preserving the calculator contract and validation boundaries.

## Dependencies

The following completed work is treated as prerequisite context:

- Public calculator API contract.
- Cross-language golden fixture runner.
- Release and supply-chain governance.
- Starlight documentation site.
- C# calculation engine architecture.
- Power Platform boundary documentation.
- Source archive and provenance policy.
- Validation vocabulary.

## Subagent Workstreams

1. Repository inventory and matrix schema.
   Owns current-state inspection, standards matrix structure, and artifact inventory.

2. Python, docs-site, and publication readiness.
   Owns pyOpenSci, PyPA, docs-site package metadata, JOSS, citation, contribution, and governance readiness.

3. R readiness.
   Owns rOpenSci, CRAN-style checks, `testthat`, `roxygen2`, `pkgdown`, `srr`, `pkgcheck`, reverse dependency checks, and R wrapper versus port recommendations.

4. Julia readiness.
   Owns Julia package structure, `Project.toml`, `[compat]`, `test/runtests.jl`, Documenter.jl, registry readiness, TagBot, and kernel-prototype recommendations.

5. C#, .NET, and Power Platform readiness.
   Owns .NET SDK pinning, solution/project layout, NuGet packaging, Source Link, deterministic builds, symbols, custom connectors, managed solutions, source-controlled solution files, and Power Platform ALM.

6. Health standards and community pathways.
   Owns ICD-10-AM, ACHI, ACS, AR-DRG, ICD-11, HL7 v2, FHIR R4/R5, IHE PAM/PDQ/PIX/PIXm/PDQm/PMIR, openEHR, CDA, health economics, health informatics, govtech, and public-sector contribution pathways.

## Write Ownership

- Standards matrix: Worker 1 owns the schema; workers 2 through 6 add rows for their domains.
- Decision matrix: Worker 1 owns consistency; workers 2 through 6 provide domain recommendations.
- Health standards guidance: Worker 6 owns the section.
- Publication and community guidance: Worker 2 owns scientific software readiness; Worker 6 owns health and government communities.
- C# and Power Platform sections: Worker 5 owns the section.
- Final Conductor plan and registry updates: parent agent owns integration.

## Merge Order

1. Inventory and schema.
2. Standards references.
3. Language and platform recommendations.
4. Health standards guidance.
5. Contribution and publication guidance.
6. Final dependency, validation, and Conductor consistency pass.

## Coordination Rules

- Workers must not broaden implementation or validation claims.
- Workers must distinguish implemented surfaces from planned surfaces.
- Workers must cite official or authoritative sources for external standards.
- Workers must preserve the shared public contract and golden fixtures as the parity gate.
- Workers must leave implementation of new languages or connectors to later tracks unless this track explicitly creates a follow-on roadmap item.
