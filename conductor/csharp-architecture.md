# C# Calculation Engine Architecture

## Purpose

The C# surface is a downstream adapter or service integration target, not the
calculation boundary. It should consume the public calculator contract and the
shared golden fixtures rather than re-implementing contract decisions.

## Layout

- A service project may wrap the calculator core, but the formula logic should
  live in the Rust core rather than in C#.
- A thin adapter layer should translate contract inputs and outputs.
- Power Platform should call the service boundary, not calculation math.
- If the C# path is retained, it should remain a downstream adapter or service
  façade over the shared contract.

## Logging

- Do not log patient-level field values.
- Log contract identifiers, pricing year, fixture identifier, and validation
  status only when needed for debugging.

## Fixture Use

- Shared fixture packs should drive regression and parity tests.
- The same manifest and payload contract should be usable from Python, C#, and
  the web demo.
- The same manifest and payload contract should also be usable by future Rust
  and other language surfaces.
