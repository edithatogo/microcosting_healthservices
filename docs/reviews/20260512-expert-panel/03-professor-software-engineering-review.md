# Simulated Professor of Software Engineering Review

## Role

Academic reviewer focused on requirements engineering, architecture, testing,
maintainability, traceability, and process discipline.

## Findings

1. The project now has strong architectural intent but incomplete traceability.
   Roadmap tracks describe contracts, but many contracts are not yet materialised
   as schemas, tests, or generated documentation.

2. The definition of done needs to distinguish three states:
   specification complete, scaffold complete, and implementation validated.

3. Requirements should be traceable from source artifact to formula bundle to
   implementation to fixture to documentation.

4. Validation needs a formal claims model.
   "Validated" should not be prose. It should be a typed evidence record with
   source basis, commands, fixture identifiers, tolerances, and results.

5. Binding surfaces must be treated as adapters.
   The ports-and-adapters model is appropriate, but needs enforcement tests and
   dependency rules.

## Recommended Engineering Improvements

- Add a machine-readable requirements/evidence registry.
- Add schema files for public contracts and reference-data manifests.
- Generate documentation tables from manifests rather than maintaining status
  by hand.
- Add architecture fitness functions that detect duplicated formula logic in
  bindings and apps.
- Require all completed tracks to reference evidence artifacts.

## Priority Recommendation

Implement the manifest, contract, and evidence registry before implementing
additional calculators or bindings.
