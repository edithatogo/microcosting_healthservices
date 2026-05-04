# Specification: Calculator Core Abstraction and Validation Models

## Goal

Define strict abstractions for calculation logic, parameters, schemas, reference data, provenance, and delivery adapters.

## Requirements

- Calculator orchestration must be separate from deterministic formula logic.
- Parameter models and input/output schemas must be explicit and validated.
- Reference data resolution must be deterministic and traceable.
- CLI, web, Python API, and C# adapters must not embed calculator-specific hidden assumptions.

## Acceptance Criteria

- A small calculator path demonstrates the target abstraction shape.
- Pydantic validation boundaries are documented and tested.
- Existing pandas behavior remains protected by regression tests.
