# Simulated Professor of Mathematics Review

## Role

Reviewer focused on formula correctness, rounding, invariants, edge cases, and
mathematical reproducibility.

## Findings

1. SAS and Excel formula parity should be mandatory per pricing year.
   A calculator library is not credible if formulae cannot be traced to
   authoritative source logic or tested outputs.

2. Rounding and missingness are likely major sources of divergence.
   These must be explicit in fixtures and evidence records.

3. Formula extraction should preserve source references.
   A formula bundle should record workbook sheet/cell or SAS line/table
   provenance where feasible.

4. Numeric tolerances must be justified.
   Do not use broad tolerances to hide differences caused by wrong branching or
   classification logic.

5. Invariants should be tested.
   Examples include non-negative weights where applicable, category coverage,
   branch exclusivity, and stable behavior under row ordering.

## Recommended Mathematical Controls

- Define exact rounding policy by stream/year.
- Add source-line or cell provenance for extracted formulae.
- Add boundary-case fixtures for thresholds.
- Add property tests for invariants.
- Record known SAS/Excel disagreements explicitly.

## Priority Recommendation

Implement formula-bundle extraction and SAS/Excel parity evidence before
claiming any new year validated.
