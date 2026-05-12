# Specification: Abstraction Doctrine Enforcement

## Overview
Make the project abstraction philosophy explicit and enforceable. The codebase
must preserve clear boundaries between formula kernels, reference data bundles,
classification registries, mapping/grouping adapters, validation models,
language bindings, apps, and documentation examples.

## Functional Requirements
- Define an architecture doctrine document for calculator and classification
  abstraction boundaries.
- Add tests or static checks that prevent apps, bindings, and docs examples from
  introducing duplicate formula logic.
- Add review checklist items for new pricing years, coding sets, classifiers,
  and language bindings.
- Add developer documentation showing the intended ports-and-adapters model.
- Link all new roadmap tracks to the shared abstraction doctrine.

## Non-Functional Requirements
- Abstraction rules must be concrete enough to review in pull requests.
- Enforcement should prioritize high-signal checks over brittle text matching.
- Exceptions must be documented as transitional-state compatibility, not
  intended architecture.

## Acceptance Criteria
- Architecture docs define allowed dependencies and forbidden shortcuts.
- CI or tests catch at least the highest-risk duplicate-formula paths.
- Roadmap and contributor docs tell maintainers where to add formulae,
  parameters, mappings, groupers, bindings, and app orchestration.
- Existing roadmap tracks remain consistent with the abstraction doctrine.
