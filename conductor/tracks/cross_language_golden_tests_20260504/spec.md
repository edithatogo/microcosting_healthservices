# Specification: Cross-Language Golden Test Suite

## Goal

Create self-describing fixture packs that enforce parity across Python, future C#, and web calculation surfaces without relying on Python-specific assumptions.

## Requirements

- Fixture packs must be synthetic, small, and explicitly source traceable.
- Each fixture pack must include a committed manifest that describes calculator, pricing year, service stream, inputs, expected outputs, tolerance, rounding policy, source basis, and privacy classification.
- Tabular payloads should use Arrow/Parquet where practical so the same fixture pack can be consumed by Python, C#, and web tooling.
- The manifest must declare cross-language readiness, schema version, fixture identifiers, and any required compatibility notes.
- Fixtures must be self-describing enough that failures can report provenance, tolerance, and privacy classification without inspecting implementation code.
- The fixture format must remain stable across runners and must not encode Python-specific objects or test harness details.

## Acceptance Criteria

- At least one calculator has a self-describing fixture pack with a manifest and payloads.
- Python tests consume the fixture pack through a shared reader and report provenance in failures.
- The fixture pack can be parsed by C#-oriented tooling without translation of the core manifest fields.
- Privacy classification, source basis, tolerance, and rounding policy are enforced by schema validation.
- The fixture format is suitable for web and future cross-language parity checks.
