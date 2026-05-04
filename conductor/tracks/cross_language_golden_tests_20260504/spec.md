# Specification: Cross-Language Golden Test Suite

## Goal

Create shared fixtures that enforce parity across Python, future C#, and web calculation surfaces.

## Requirements

- Fixtures must be synthetic, small, and source-traceable.
- Each fixture must declare calculator, year, inputs, expected outputs, precision tolerance, and source basis.
- Fixtures must support Python and C# test runners.

## Acceptance Criteria

- At least one calculator has a golden fixture pack.
- Python tests consume the fixture pack.
- The fixture format is suitable for C# consumption.
