# Binding Strategy: Swift Binding

## Decision

Use a staged integration strategy for Swift consumers, initially targeting
file/Arrow exchange and CLI invocation, with C ABI as a future native
integration path. Swift consumers read pre-computed calculator outputs as
Parquet or CSV and invoke the shared core via the CLI tool from Swift
processes. No Swift formula port is created.

This follows the polyglot Rust core roadmap and reuses the C ABI and CLI/file
interop contracts established by the shared core.

## Rationale

- Native Swift FFI via C ABI (Rust `#[no_mangle]` extern "C" functions) is
  viable but requires a C bridge header and module map for Swift Package
  Manager integration.
- File/Arrow exchange has no language dependency and works immediately from
  Swift Foundation's `Parquet`, `CSV`, or `JSONDecoder`.
- CLI invocation via `Process` gives a zero-build-consumer path for Swift
  scripts and CLI tools on macOS.
- Apple-platform constraints (sandboxing, app store review, privacy
  manifests) are easier to satisfy with file-based or service boundaries than
  with embedded C ABI libraries.
- No Swift build tooling (SPM, Xcode project) is committed for a
  design-only track.

## Contract shape

### Integration modes

| Mode          | Consumer              | Transport       | Notes                               |
|---------------|-----------------------|-----------------|-------------------------------------|
| File exchange | Swift `ParquetReader` | Parquet / CSV   | Primary mode; no framework deps     |
| CLI process   | Swift `Process`       | CLI stdout/json | Zero-build; invokes shared-core CLI |
| C ABI         | Swift `CFunction`     | C library .dylib| Future path; requires module map    |
| Service API   | Swift `URLSession`    | HTTP / REST     | Network boundary; async integration |

### Parquet/CSV schema contract

Swift reads the same Parquet and CSV schemas produced by the CLI/file interop
track:

- `contract_version` — pinned calculator contract version
- `calculator_id` — public calculator identifier
- `pricing_year` — target IHACPA pricing year
- `input_schema` — structured input columns matching the calculator contract
- `output_schema` — computed output columns with diagnostic flags
- `provenance` — shared-core version, source archive hash, generation timestamp
- `fixture_gate` — declared synthetic-only or local-only gate

### CLI invocation pattern

```swift
// Illustrative — not implemented here
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/local/bin/mchs-calc")
process.arguments = ["--calculator", "nwau", "--pricing-year", "2026"]
let output = try process.runAndCaptureOutput()
```

## Supported calculators

All calculators exposed through the CLI/file interop track are accessible from
Swift. No Swift-specific calculator packaging is required.

## Limitations

- Swift does not execute calculator logic. All computation happens in the
  shared core.
- C ABI integration requires a Rust `cdylib` build and a Swift module map.
  This path is documented but not implemented in this track.
- iOS and visionOS sandboxing restricts CLI `Process` invocation. On those
  platforms, file exchange or service API is preferred.
- No Swift-specific formula UDFs, property wrappers, or result builders are
  maintained in this repository.

## Versioning

- Swift integration pins to the CLI/file interop contract version for
  Parquet/CSV schemas.
- C ABI integration would pin to the C ABI contract version.
- No separate Swift interop version is needed.

## Diagnostics and provenance

- File outputs include full provenance metadata consumed by Swift decoder
  types.
- CLI invocation captures diagnostic output (stderr) and exit codes for error
  handling.
- Provenance metadata supports traceability from Swift clients back to shared
  core execution.

## Privacy and synthetic examples

- All committed Swift example manifests and test files are synthetic.
- Real IHACPA pricing data or patient-level extracts are never committed as
  Swift examples.
- The `fixture_gate` field distinguishes synthetic examples from local-only
  real data.

## When to use Swift vs. other bindings

Use Swift when:
- the consumer is an Apple-platform app (macOS, iOS, iPadOS, visionOS)
- the workflow requires native Swift concurrency (`async/await`) or
  SwiftUI presentation
- the team standardises on Swift for institutional tooling

Prefer CLI/file interop or service API when:
- the consumer is not Apple-platform-native
- the integration needs zero client-side dependencies
- the deployment target does not support Swift runtime

## Readiness bar

- This track is design-only. No Swift code is being written.
- Integration workflows are documented and validated against shared golden
  fixtures.
- Do not claim Swift integration as production-ready until a Swift file-read
  or CLI-invocation example has been validated against synthetic fixtures.
