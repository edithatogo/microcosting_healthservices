# Service Boundary Contract

This document defines the request/response contract used by the Power Platform
orchestration layer.

## Request Fields

- `contract_version`
- `calculator_id`
- `pricing_year`
- `fixture_id`
- `input_payload`

## Response Fields

- `status`
- `result_payload`
- `warnings`
- `trace_id`

## Rules

- Power Platform must send requests to the secured boundary only.
- Calculation logic stays outside Power Platform.
- The boundary must preserve traceability for auditing and validation.
