# Kotlin/Native binding contract fixtures

This directory contains synthetic fixtures for the Kotlin/Native binding workstream.

## Scope

The bundle describes a versioned binding contract for calculator request and response models, a primary Arrow/Parquet file surface, service fallback path, diagnostics, stable errors, fixture gates, and Kotlin/Native package readiness.

The contract is aligned to the public calculator boundary in `microcosting_healthservices/nwau_py/contracts.py` and keeps the binding layer thin:

- request and response models mirror the public calculator contract fields
- service calls remain orchestration-only
- Arrow and Parquet are declared as deterministic fallback transports
- diagnostics and errors are stable and machine-readable
- fixture gates stay explicit so pass/fail behavior is reproducible

## Contents

- `kotlin-native-binding.schema.json`: JSON Schema for the binding contract bundle.
- `kotlin-native-binding.contract.json`: Versioned synthetic contract document.
- `examples/validation.pass.json`: Pass example showing an aligned binding bundle.
- `examples/validation.fail.json`: Fail example showing missing alignment and blocked readiness.
- `examples/diagnostics.json`: Diagnostics example covering service and fallback selection.
- `examples/errors.json`: Stable error example for binding consumers.

## Rules

- Keep all committed examples synthetic and metadata only.
- Do not add formula logic, generated calculator kernels, PHI, or proprietary tables.
- Keep Arrow and Parquet fallback metadata declarative.
- Keep Kotlin/Native models compatible with Kotlin/Native package consumers without committing platform-specific build outputs.
