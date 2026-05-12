# Track classification_input_validation_20260512 Context

- [Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Metadata](./metadata.json)

## Current State

Phase 1 has a conservative compatibility matrix for AR-DRG, AECC, UDG, Tier 2,
and AMHCC. The matrix is a validation input, not the canonical coding-set
registry: durable version ownership remains with the coding-set registry and
licensed-product workflow tracks.

The first shared preflight validator now exists in `nwau_py.classification_validation`.
It validates stream-specific required fields and pricing-year-specific versions
without redistributing licensed classification products. Phase 2/3 remain open
until that boundary is wired into calculator and CLI entry points with broader
validation evidence.
