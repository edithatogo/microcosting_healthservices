# Specification: C# Calculation Engine and Power Platform Adapter

## Goal

Define and eventually implement a C# calculation engine that can support Power Platform workflows while preserving parity with Python and IHACPA sources, using the public calculator contract and shared golden fixtures as the interoperability boundary.

## Requirements

- C# must consume the shared public contract and golden fixtures.
- Power Platform should act as an orchestration surface, not the source of calculator logic.
- The C# engine should own calculation behavior and sit behind a secure service boundary such as an Azure Function or custom connector target.
- Logging must avoid patient-level field values.
- Real-data workflows must be validated against the public contract and not rely on Power Platform-native formula logic.
- Fixture compatibility should be versioned so Python, C#, and the web demo can consume the same evidence set.

## Acceptance Criteria

- C# architecture is documented.
- Shared fixtures can drive future C# tests.
- Power Platform integration boundaries are explicit.
- The service boundary and contract mapping are clear enough to support later web and API adapters.
