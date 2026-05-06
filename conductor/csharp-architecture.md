# C# Calculation Engine Architecture

## Purpose

The C# engine is the calculation boundary for downstream Power Platform and
service integrations. It should consume the public calculator contract and the
shared golden fixtures rather than re-implementing contract decisions.

## Layout

- A service project should own the calculation logic.
- A thin adapter layer should translate contract inputs and outputs.
- Power Platform should call the service boundary, not calculation math.

## Logging

- Do not log patient-level field values.
- Log contract identifiers, pricing year, fixture identifier, and validation
  status only when needed for debugging.

## Fixture Use

- Shared fixture packs should drive regression and parity tests.
- The same manifest and payload contract should be usable from Python, C#, and
  the web demo.

