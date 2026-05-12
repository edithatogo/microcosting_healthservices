# Simulated Professor of Computer Science Review

## Role

Academic reviewer focused on formal models, semantics, type systems, data
representation, correctness, and language interoperability.

## Findings

1. The project needs a formal semantic boundary.
   A calculator should be a deterministic function from typed inputs, pricing
   year, reference bundle, and classifier outputs to typed outputs plus
   diagnostics and provenance.

2. Arrow is a sound interoperability choice.
   It gives columnar semantics and cross-language portability, but the project
   must define stable schemas and nullability rules.

3. ABI design should be minimal.
   C ABI is useful as a lowest-common-denominator bridge, but should expose
   Arrow-compatible buffers or file handles rather than complex domain objects.

4. Versioning is not optional.
   Schema version, pricing year, coding-set version, formula-bundle version,
   and package version must be distinct.

5. Cross-language equivalence must be property-driven as well as fixture-driven.
   Golden fixtures catch examples; property tests catch invariant failures.

## Recommended Formalisation

- Define a typed core calculus for calculator execution.
- Define schemas for input, output, diagnostics, provenance, and evidence.
- Define compatibility functions between pricing years and coding-set versions.
- Define total error behavior for invalid inputs.
- Use property-based tests for monotonicity, non-negativity, null handling,
  category coverage, and version rejection.

## Priority Recommendation

Formalise schemas and deterministic semantics before expanding ABI and language
bindings.
