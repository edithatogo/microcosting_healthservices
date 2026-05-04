# Specification: C# Calculation Engine and Power Platform Adapter

## Goal

Define and eventually implement a C# calculation engine that can support Power Platform workflows while preserving parity with Python and IHACPA sources.

## Requirements

- C# must consume shared contracts and golden fixtures.
- Power Platform should act as an app/orchestration surface, not the source of calculator logic.
- The engine should be suitable for an Azure Function, custom connector, or similar service boundary.
- Logging must avoid patient-level field values.

## Acceptance Criteria

- C# architecture is documented.
- Shared fixtures can drive future C# tests.
- Power Platform integration boundaries are explicit.
