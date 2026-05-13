# C#/.NET binding contract bundle

This directory contains synthetic fixtures for the C#/.NET binding workstream.

## Contents

- `csharp-dotnet-binding.schema.json`: JSON Schema for the binding contract bundle.
- `csharp-dotnet-binding.contract.json`: Versioned synthetic contract for typed C# request/response models aligned to the public calculator contract.
- `examples/validation.pass.json`: Synthetic pass example showing a compliant binding surface.
- `examples/validation.fail.json`: Synthetic fail example showing contract, fallback, provenance, or packaging problems.
- `examples/diagnostics.json`: Synthetic diagnostics catalog for binding, CLI fallback, Arrow-file fallback, and packaging issues.
- `examples/provenance.json`: Synthetic provenance example for fixture and package traceability.
- `examples/errors.json`: Synthetic binding error catalog with stable codes.
- `examples/fixture-gates.json`: Synthetic fixture gate manifest for contract validation.
- `examples/nuget-readiness.json`: Synthetic NuGet readiness status example.

## Scope

These files are metadata-only fixtures. They are intentionally synthetic and do not include implementation code, generated C# sources, production data, or patient data.

The contract is intended to model a thin C#/.NET binding over the public calculator contract with explicit fallback behavior:

- typed request/response models for managed invocation
- CLI fallback for process-based execution
- Arrow-file fallback for file-based interchange
- diagnostics, provenance, and errors as first-class outputs
- fixture gates that keep synthetic examples aligned with the public calculator contract
- NuGet readiness status for packaging decisions

## Rules

- Keep all examples synthetic.
- Do not add implementation logic or reimplement calculator semantics.
- Keep the binding surface explicit and versioned.
- Preserve the boundary between the calculator contract and the C# binding contract.
