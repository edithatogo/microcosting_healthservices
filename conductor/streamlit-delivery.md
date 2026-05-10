# Streamlit Delivery

## Purpose

Streamlit provides a Python-hosted analyst surface for local exploration and
demo workflows. It is not a separate calculation engine.

## Boundary Rules

- Streamlit should use the existing Python package and shared public contracts.
- The app may read synthetic or fixture-backed data only by default.
- The app must not own calculator formulas, validation rules, or reference-data
  loading logic.
- Any real-data workflow must go through a secured service boundary.
- Do not log patient-level fields or free-form identifiers in app telemetry.

## Observability Rules

- Log operational state such as calculator selection, fixture identifiers, and
  validation outcome summaries.
- Avoid logging raw inputs, patient-level fields, or sensitive identifiers.
- Treat browser-exported diagnostics as sensitive if they contain real-data
  content.

## Delivery Shape

- A local Streamlit app can reuse the current Python runtime and package
  boundaries.
- The app should present a clean demo or analyst workflow, not a hidden copy of
  the calculator engine.
- Public docs should describe the app as a convenience surface, not as a new
  authority on calculator behavior.
