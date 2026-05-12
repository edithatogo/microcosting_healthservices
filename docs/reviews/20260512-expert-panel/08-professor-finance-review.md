# Simulated Professor of Finance Review

## Role

Reviewer focused on pricing, revenue interpretation, financial governance,
auditability, and decision risk.

## Findings

1. NWAU outputs can be financially material.
   Errors may affect funding estimates, costing-study conclusions, and policy
   analysis.

2. NEP multiplication should be documented as an analytical operation, not
   necessarily a final funding entitlement.
   Actual funding may include jurisdictional, policy, or local adjustments.

3. Version alignment matters.
   NEP, price weights, classifications, and coding systems must all correspond
   to the same pricing year.

4. Release notes should identify financial-impact changes.
   Any formula, parameter, price-weight, rounding, or classification change
   should be labelled in release notes.

5. Audit trails are required for reproducibility.
   Every estimate should be reproducible from package version, pricing year,
   reference bundle, input hash, and command/version metadata.

## Recommended Financial Controls

- Add revenue-estimate provenance to output records.
- Add warnings when NEP/weight/classification versions mismatch.
- Add financial-impact sections in release notes.
- Add examples showing cost versus efficient price with caveats.

## Priority Recommendation

Prioritise version alignment and provenance over additional package surfaces.
