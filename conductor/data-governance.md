# Data Governance

## Scope

This project handles health funding calculator logic and may be used with patient-level activity data. The repository must treat real patient data, identifiable facility data, and operational extracts as sensitive even when examples appear small.

## Rules

- Do not commit real patient data, production extracts, or identifiable operational data.
- Do not use real patient data in GitHub Pages examples, documentation fixtures, screenshots, or browser-side demos.
- Use synthetic, de-identified, or officially published sample data for tests and examples.
- Keep raw IHACPA calculator artifacts separate from extracted and validated datasets.
- Record source provenance and checksums for downloaded public artifacts.
- Treat calculator outputs derived from real data as sensitive unless an explicit governance decision says otherwise.

## Browser and Web-App Constraints

The GitHub Pages web app must default to synthetic examples and client-side demonstration workflows. It must not encourage users to upload sensitive patient-level data into an unaudited browser workflow.

If real-data calculation is supported later, use a secured service boundary with documented privacy, retention, audit, and access controls.

## Power Platform Constraints

Power Platform integration should keep Dataverse and app workflows separate from the calculation engine. The C# engine should expose explicit input and output contracts, avoid hidden persistence, and log operational metadata without logging patient-level fields.

## Test Data Policy

Golden fixtures should be small, synthetic, and designed to exercise edge cases. If a fixture is derived from an official calculator example, document the source and transformation.

