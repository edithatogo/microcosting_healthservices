# Specification: Power Platform Binding

## Overview
Finalize Power Platform as an orchestration-only binding surface. Canvas apps, model-driven apps, flows, and custom connectors must call a shared service, managed connector, or file/API boundary and must not contain formula logic.

## Functional Requirements
- Define supported Power Platform integration modes: custom connector, Power Automate flow, service API, and managed solution packaging.
- Define request/response schemas aligned with the shared calculator contract.
- Define environment variables, connection references, ALM, and publish requirements.
- Reuse shared fixtures through service-level tests.

## Acceptance Criteria
- Power Platform roadmap separates app orchestration from calculator execution.
- Managed solution publication path is documented.
- No formula logic is stored in apps or flows.
