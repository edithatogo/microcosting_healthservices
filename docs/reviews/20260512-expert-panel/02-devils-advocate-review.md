# Simulated Devil's Advocate Review

## Role

Sceptical reviewer challenging whether the roadmap is too broad, whether claims
are over-ambitious, and whether the project risks becoming planning-heavy
without implementation depth.

## Findings

1. The roadmap may now be broader than the current implementation can justify.
   A Rust core, many bindings, Power Platform, cost buckets, classification
   groupers, conda, docs, and audits are all valid, but together they create a
   major delivery risk.

2. "Polyglot library" is premature unless the shared contract is real.
   Without versioned schemas, fixture conformance tests, and at least one
   fully promoted Rust-backed stream, the phrase should be treated as a target
   state only.

3. Costing-study support could distract from calculator parity.
   Cost buckets and AHPCS are valuable, but they should not dilute the first
   obligation: correct NWAU calculation.

4. Conductor completion states may be misleading.
   Some completed tracks appear to be scaffold or roadmap completion rather
   than production achievement.

5. The library should resist "everything everywhere" integration.
   R, Julia, C#, Go, JVM, WASM, SQL, SAS interop, Power Platform, and web
   should only proceed after the shared Rust/Arrow contract is proven.

## Counterproposal

Constrain the next milestone to:

1. one canonical year;
2. one calculator stream;
3. one source bundle;
4. one Rust core implementation;
5. one Python binding;
6. one CLI/Arrow interface;
7. one docs tutorial;
8. full SAS and Excel parity evidence.

Only after that should secondary language bindings proceed.

## Priority Recommendation

Focus the next release on credibility, not breadth. Prove the full lifecycle for
one stream/year before adding more public surfaces.
