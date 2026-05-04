# Specification: Public Calculator API Contract

## Goal

Define stable input, output, parameter, error, and metadata contracts that can drive Python, CLI, web, C#, and Power Platform surfaces.

## Requirements

- Contracts must be versioned.
- Contracts must expose supported calculators, years, required fields, optional parameters, output fields, and validation status.
- Error responses must be structured and explainable.
- Contracts must be generated or verified from the calculator core where possible.

## Acceptance Criteria

- Contract documentation exists for at least one calculator.
- The contract maps to Python API and CLI behavior.
- The contract is suitable for OpenAPI or C# model generation later.
