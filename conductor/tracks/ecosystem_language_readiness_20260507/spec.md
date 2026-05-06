# Specification: Ecosystem Standards and Language Readiness

## Goal

Create an evidence-backed roadmap for external ecosystem readiness, language distribution, Power Platform implementation, and health-system interoperability standards.

The project already has strong Python, fixture, provenance, and documentation foundations. This track decides what is required to make those foundations credible to scientific software communities and useful across R, Python, Julia, .NET, Power Platform, and patient administration system integration contexts.

## Research Findings To Preserve

- Python is the only implemented calculator package surface today.
- The Starlight docs site is implemented as a separate npm-managed documentation surface.
- No R package, Julia package, C# project, .NET solution, or Power Platform solution artifact currently exists.
- The existing C# and Power Platform material is architecture and boundary documentation, not executable logic parity.
- Python packaging is modern and close to pyOpenSci readiness, but still has transitional files and governance gaps to assess.
- R and Julia ports should be deliberate interface decisions, not automatic rewrites.
- Health interoperability should prioritize Australian coding and funding context first, then PAS and API integration standards.

## Functional Requirements

- Produce a current-state matrix for each language and platform surface:
  - Python package and CLI.
  - Starlight documentation site.
  - C# calculation engine.
  - Power Platform adapter.
  - R package or wrapper.
  - Julia package or kernel proof of concept.
  - Additional candidate surfaces where justified.
- Assess each surface against ecosystem standards:
  - Python: pyOpenSci readiness, PyPA metadata/versioning, CI, testing, docs, governance, and scientific-software publication expectations.
  - R: rOpenSci, CRAN-style checks, `testthat`, `roxygen2`, `pkgdown`, `srr`, `pkgcheck`, and reverse-dependency readiness.
  - Julia: `Project.toml`, `[compat]`, `test/runtests.jl`, Documenter.jl, registry readiness, TagBot, and package artifact conventions.
  - .NET/C#: SDK pinning, solution/project layout, NuGet packaging, Source Link, deterministic builds, symbols, and shared fixture parity.
  - Power Platform: solution packaging, managed solution promotion, custom connector boundary, source-controlled solution files, and deployment pipelines.
  - Docs site: npm package metadata, Node/npm version pinning, GitHub Pages deployment, Starlight plugin governance, and link/search validation.
- Decide whether each non-Python language surface should be:
  - implemented now,
  - implemented as a thin wrapper,
  - prototyped later,
  - kept as documentation-only,
  - or rejected as out of scope.
- Define the minimum implementation bar for any approved language surface:
  - shared public contract,
  - shared golden fixtures,
  - package metadata,
  - CI,
  - docs,
  - versioning,
  - release artifacts,
  - and parity evidence.
- Establish whether C# is the calculation engine for Power Platform integration and define what must exist before that claim is made.
- Assess health and patient administration standards worth considering:
  - ICD-10-AM, ACHI, ACS, AR-DRG, and future ICD-11 watch items.
  - HL7 v2 ADT-style PAS feeds.
  - FHIR R4 as the practical API baseline, with R5 as a watch item.
  - IHE PAM, PDQ, PIX, PIXm, PDQm, and PMIR for identity, demographics, and patient administration workflows.
  - openEHR and CDA only where a future clinical repository or document-ingestion scope justifies them.
- Produce a prioritized implementation roadmap after the assessment.

## Non-Functional Requirements

- Recommendations must distinguish verified repository state from inferred future direction.
- External standards claims must cite official or authoritative sources in project documentation.
- Language ports must not fragment calculator truth. Shared fixtures and public contracts remain the parity gate.
- R, Julia, C#, and Power Platform work must not broaden validation claims without evidence-backed fixture parity.
- Any patient administration integration recommendation must respect privacy and data governance boundaries.

## Acceptance Criteria

- A standards matrix exists and covers Python, R, Julia, C#, Power Platform, docs-site, and health interoperability surfaces.
- The matrix identifies current repo artifacts, missing artifacts, package maturity, and recommended action for each surface.
- The roadmap records whether R and Julia should be wrappers, ports, prototypes, or deferred.
- The roadmap states whether C# currently implements Power Platform logic and what is needed before it does.
- The roadmap identifies health-funding and PAS interoperability standards to consider and separates near-term targets from watch-list items.
- Project documentation explains which scientific community standards are relevant, including pyOpenSci, rOpenSci, Julia package norms, and publication/community options such as JOSS where appropriate.
- Guardrail tests verify the new roadmap files and track registry entries.

## Out of Scope

- Implementing a full R package.
- Implementing a full Julia package.
- Implementing the C# engine.
- Implementing a Power Platform solution package.
- Implementing HL7, FHIR, IHE, openEHR, or PAS connectors.
- Changing calculator behavior.
- Making new validation claims without fixture evidence.

