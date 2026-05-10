---
title: Streamlit delivery
---

Streamlit is a Python-hosted analyst surface for local and demo workflows.
It is not a calculator engine.

Rules:

- Use the existing Python package and shared public contracts.
- Keep Streamlit fixture-backed or synthetic by default.
- Do not log patient-level fields in app telemetry.
- Route any real-data workflow through a secured service boundary.
- Treat Streamlit as a convenience surface, not a source of calculator truth.

See the canonical source in [Conductor streamlit-delivery.md](../../../../conductor/streamlit-delivery.md).
