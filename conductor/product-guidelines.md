# Product Guidelines

## Guiding Principle

This project should be maintained as an audit-first implementation of IHACPA calculator behavior. Product, documentation, and implementation decisions should support accurate reflection of the reference calculators and make it possible to explain how each result was derived.

## Documentation Style

Documentation should be precise, evidence-based, and conservative.

Use direct language that distinguishes:

- Verified behavior confirmed against trusted reference outputs or source logic.
- Inferred behavior derived from SAS, Excel, compiled, Python, or supporting files.
- Known gaps where source material exists but validation is incomplete.
- Unsupported behavior where the project intentionally does not claim parity.

Avoid overstating support. If a pricing year, calculator, adjustment, or edge case has not been validated, the documentation should say so plainly.

## Source Traceability

Every calculator behavior should be traceable to the strongest available reference source. Relevant sources may include official SAS programs, Excel calculator workbooks, extracted formulas, weight tables, compiled or Python reference files, and associated IHACPA support data.

When implementing or changing calculator logic, maintainers should record which source informed the behavior and whether the change was validated by output comparison, source inspection, or both.

## Validation Language

The project should use consistent validation terms:

- **Archived** means source material is present in the repository or expected archive location.
- **Extracted** means formulas, weights, or reference data have been parsed into project-usable files.
- **Implemented** means Python logic exists for the calculator or pricing year.
- **Validated** means Python output has been checked against trusted reference behavior.

A calculator or year should not be described as validated unless the relevant output comparison or source parity check has been performed.

## Contributor Experience

The project should be practical for future maintainers. Guides should include clear examples, expected commands, data locations, and validation workflows.

New contributors should be able to answer:

- Which IHACPA source files are relevant for a calculator.
- Which years are implemented and validated.
- How to run a calculator from the CLI or Python API.
- How to compare Python output against reference material.
- Where to add or update weights, formulas, and archived source files.

## User Experience

The command line interface and Python API should remain dependable and predictable. Interfaces should favor explicit year selection, clear error messages, and reproducible outputs.

Convenience features are useful only when they do not obscure source provenance or calculator behavior.

## Data Governance

Product decisions must protect sensitive health data. Documentation, examples, tests, browser workflows, and screenshots should use synthetic, de-identified, or officially published sample data only.

The GitHub Pages web app should be safe by default and should not encourage upload of real patient-level data into a static browser workflow. Any future real-data workflow must use a documented secure service boundary.

Power Platform integration should keep app orchestration separate from the calculation engine. The calculation engine should expose explicit contracts and avoid logging patient-level fields.

## Validation Claims

Validation claims must use precise language. Prefer terms such as source parity, output parity, regression parity, and cross-engine parity over broad claims that a year or calculator is simply "supported."

If source materials disagree, documentation should identify the disagreement, the chosen authority, and the reason for that choice.

## Design Tone

The project should read like a technical reference for health funding calculator parity rather than a promotional product. It should be calm, specific, and transparent about limits.

The preferred tone is:

- Accurate over persuasive.
- Specific over broad.
- Traceable over implicit.
- Practical over decorative.
