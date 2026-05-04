# Specification: Calculator Core Abstraction and Validation Models

## Goal

Define strict calculator-core boundaries that consume the public contract package and keep computation separate from adapter concerns.

## Requirements

- Calculator orchestration must be separate from deterministic formula logic.
- Parameter models and input/output schemas must be explicit, validated, and aligned to the public API contract.
- Reference data resolution must be deterministic, traceable, and bundle-based.
- CLI, web, Python API, and C# adapters must not embed calculator-specific hidden assumptions or direct source lookup behavior.
- The core must expose a narrow contract-oriented boundary for prepared inputs, compute execution, and structured outputs.

## Acceptance Criteria

- A small calculator path demonstrates the target abstraction shape.
- Pydantic validation boundaries are documented and tested.
- Existing pandas behavior remains protected by regression tests.
- The track explicitly depends on the public API contract gate before downstream adapter work expands.
