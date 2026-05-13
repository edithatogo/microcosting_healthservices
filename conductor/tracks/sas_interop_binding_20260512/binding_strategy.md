# Binding Strategy: SAS Interoperability

## Decision

Use a file-based import/export and comparison strategy for SAS
interoperability. SAS users compare IHACPA SAS reference outputs against
shared-core results through CSV, Parquet, and pyreadstat-supported formats.
No SAS formula port is created.

The shared core produces deterministic outputs that SAS consumers can validate
against reference SAS runs. This is a controlled comparison surface, not a
dual implementation.

## Rationale

- IHACPA distributes SAS-based calculators as reference implementations.
  A SAS port would duplicate formula logic and split validation effort.
- CSV and Parquet interchange is already supported by the CLI/file contract.
- pyreadstat and similar readers can import/export SAS `.sas7bdat` and
  `.xpt` files without requiring a SAS license.
- The track focuses on parity reporting, not re-execution. SAS stays the
  reference; the shared core proves it matches.

## Contract shape

### Import/export workflows

| Direction | Format       | Reader/provider         | Notes                                |
|-----------|--------------|------------------------|--------------------------------------|
| Import    | .sas7bdat    | pyreadstat             | Read-only; no write to .sas7bdat     |
| Import    | .xpt / .csv  | pyreadstat or Pandas   | Transport format for SAS-less review |
| Export    | .csv         | Pandas or CLI/file     | Preferred comparison format          |
| Export    | .parquet     | CLI/file Arrow write   | For Parquet-native consumers         |
| Export    | .xpt         | pyreadstat write       | SAS transport format                 |

### Comparison report structure

A SAS comparison report compares shared-core output columns against SAS
reference output columns. The report includes:

- Contract version and pricing year
- Calculator identifier and input file hash
- Comparison method (exact match, tolerance, structural)
- Per-column results: match/mismatch/n/a with count and first-difference
  details
- Overall verdict: pass, fail, or blocked
- Provenance record for both the reference and shared-core output

### Comparison modes

- **Exact**: bitwise-identical numeric and string columns
- **Tolerance**: numeric columns compared within a configurable epsilon
  (default 0.001)
- **Structural**: schema shape and column existence only

## Supported calculators and formats

SAS comparison is supported for any calculator for which:

1. An IHACPA SAS reference output exists and is archived with provenance
2. The shared core produces a compatible output schema
3. The reference is accessible under the source archive policy

Formats and their status:

| Format     | Import | Export | Comparison | Notes                             |
|------------|--------|--------|------------|-----------------------------------|
| .sas7bdat  | Yes    | No     | External   | Read-only; SAS-licensed format    |
| .xpt       | Yes    | Yes    | External   | SAS transport; no formula exec    |
| .csv       | Yes    | Yes    | Yes        | Preferred comparison surface      |
| .parquet   | Yes    | Yes    | Yes        | Structured Arrow-based comparison |

## Limitations

- SAS `.sas7bdat` is a proprietary format. The shared core does not execute
  or rehost SAS code.
- Comparison reports are informative, not authoritative. Only IHACPA's
  published outputs are the reference standard.
- Licensed IHACPA SAS source code is never committed to this repository.
  Archived outputs are handled per source archive policy.
- Complex SAS macros and helper dependencies are not replicated.

## Versioning

- SAS interop workflows pin to the CLI/file interop contract version for
  file schemas.
- Comparison reports declare the shared-core version and the SAS reference
  archive hash.
- No separate SAS interop version is needed.

## Diagnostics and provenance

- Comparison reports include full provenance: reference source URL/archive
  path, retrieval date, hash, shared-core version, and CLI command used.
- Diagnostic output separates pass/fail/blocked checks so SAS consumers can
  identify mismatches without reading the shared-core source.
- Blocked checks occur when a reference output is not available under the
  current source archive policy.

## Privacy and licensed material

- References to IHACPA SAS calculators link to the public source or archive
  record, not the source code itself.
- No SAS source code is committed to the repository.
- Comparison reports committed as examples must use synthetic fixtures or
  aggregate public IHACPA outputs.
- Real SAS reference outputs stay local and user-supplied.

## When to use SAS interop vs. native bindings

Use SAS interop when:
- validating shared-core outputs against an IHACPA SAS reference
- migrating a SAS-based costing workflow to the shared core
- comparing results between an existing SAS pipeline and the Rust/Python core

Prefer native bindings or CLI/file interop when:
- the consumer no longer depends on SAS reference outputs
- the workflow is production and does not require SAS parity confirmation
- the SAS reference is archived and no longer actively compared

## Readiness bar

- This track is design-only. No SAS code is being written.
- Comparison workflows are documented and validated against shared golden
  fixtures.
- Do not claim SAS parity for a pricing year until a comparison report has
  been produced against the archived IHACPA SAS reference for that year.
