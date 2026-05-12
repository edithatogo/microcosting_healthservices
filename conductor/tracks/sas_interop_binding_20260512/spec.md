# Specification: SAS Interoperability

## Overview
Provide SAS interoperability for users validating against IHACPA SAS calculators and legacy SAS data workflows. This is not a SAS port; it is a controlled import/export and comparison surface around the shared calculator behavior.

## Functional Requirements
- Support SAS-compatible import/export workflows where feasible through CSV, Parquet, or pyreadstat-supported formats.
- Define comparison reports between IHACPA SAS outputs and shared-core outputs.
- Preserve source provenance and validation status.
- Document how SAS calculators are used as references without duplicating code.

## Acceptance Criteria
- SAS interop strategy is documented as validation/import/export, not a formula port.
- Comparison examples validate against shared fixtures or archived reference outputs.
- Restricted IHACPA artifacts are handled according to source policy.
