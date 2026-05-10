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
- Record privacy classification for every example, fixture, and output bundle.

## Browser and Web-App Constraints

The GitHub Pages web app must default to synthetic examples and client-side demonstration workflows. It must not encourage users to upload sensitive patient-level data into an unaudited browser workflow.

If real-data calculation is supported later, use a secured service boundary with documented privacy, retention, audit, and access controls.

## Streamlit Constraints

Streamlit is a Python-hosted analyst surface for local or demo use. It should
consume the same public contracts and synthetic fixture packs as the other
delivery surfaces.

- Do not expose unrestricted file upload paths for patient-level data.
- Log operational metadata, not patient-level fields.
- Keep raw calculation inputs and outputs behind the same privacy rules as the
  rest of the repository.
- Route any real-data workflow through the secured service boundary rather than
  the Streamlit app itself.

## Power Platform Constraints

Power Platform integration should keep Dataverse and app workflows separate from the calculation engine. The C# engine should expose explicit input and output contracts, avoid hidden persistence, and log operational metadata without logging patient-level fields.

## Governance Process

- Every new fixture pack, sample output set, and source-manifest schema change should be reviewed for privacy impact before release.
- Assign an owner for privacy incidents, manifest corrections, and release blocking data issues.
- Retain raw source artifacts only according to the approved source-archive storage policy.
- Document redaction rules for logs, screenshots, and exported diagnostics, then test them.

## Classification Tiers

- `public`: approved published sample data or non-sensitive documentation examples.
- `synthetic`: fabricated data intended to exercise edge cases without real-world records.
- `derived-sensitive`: outputs or aggregates produced from real data that still require protection.
- `restricted`: source extracts, patient-level records, or operational data that must never enter the repo.

## Test Data Policy

Golden fixtures should be small, synthetic, and designed to exercise edge cases. If a fixture is derived from an official calculator example, document the source and transformation.
