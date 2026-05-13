# Review: Kotlin/Native Binding

## Findings

1. Resolved - The track metadata points to the live synthetic contract bundle
   at `contracts/kotlin-native-binding/kotlin-native-binding.contract.json`.
2. Resolved - The track includes fixture-backed tests, live contract examples,
   and a Kotlin/Native scaffold.
3. Resolved - The roadmap and governance docs choose Arrow/Parquet first,
   service fallback, and C ABI deferral. Kotlin/Native package publication remains
   future-gated and is not implied as ready.

## Blockers

- None for the Kotlin-first roadmap/prototype scope.

## Changed files

- `microcosting_healthservices/conductor/tracks/kotlin_native_binding_20260512/review.md`

## Validation

- The initial review was document-only; the integration pass adds contract,
  fixture, Kotlin scaffold, Starlight, JSON, and focused test validation.

## Risks

- The Kotlin scaffold is transport-only and does not invoke a real calculator
  backend yet.
- C ABI and Kotlin/Native package work remain gated until reproducible packaging and
  runtime matrices exist.
- Formula behavior remains owned by the shared core; Kotlin/Native stays an
  adapter surface.
