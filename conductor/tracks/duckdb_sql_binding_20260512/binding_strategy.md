# Binding Strategy: SQL and DuckDB Integration

## Decision

Use DuckDB's native Arrow/Parquet and CSV read/write as the primary SQL
integration path for analytical workflows. Avoid DuckDB Python UDF or SQL-level
extension paths that would require hand-copied formula logic inside SQL
snippets.

DuckDB reads and writes the same Arrow/Parquet and CSV artifacts that the
CLI/file interop contract defines, so SQL consumers can reuse shared-core
outputs without a separate binding.

## Rationale

- DuckDB already supports direct `read_parquet`, `read_csv`, and Arrow
  zero-copy interchange via the Python or CLI runtime.
- The CLI/file interop contract produces Parquet and CSV output that DuckDB
  can consume without any SQL-level formula duplication.
- A DuckDB extension or UDF that wrapped shared-core calls would introduce a
  compilation and maintenance dependency without a clear analytical workflow
  advantage over Arrow/Parquet interchange.
- SQL analysts already work with tables and files; asking them to learn a
  DuckDB extension API is a higher barrier than reading a Parquet directory.

## Contract shape

### Table schemas

SQL consumers interact with tabular input/output schemas defined by the
shared calculator contract. The DuckDB mapping mirrors the file contract:

| Surface   | Input format      | Output format      | Notes                         |
|-----------|-------------------|--------------------|-------------------------------|
| CLI pipe  | Parquet or CSV    | Parquet or CSV     | `funding-calculator` stdout   |
| Direct    | Parquet file read | Parquet file write | `read_parquet` / `copy`      |
| Direct    | CSV file read     | CSV file write     | `read_csv` / `copy`           |

### SQL workflow example (conceptual)

```sql
-- Read pre-computed calculator outputs as a Parquet table.
CREATE TABLE acute_results AS
SELECT * FROM read_parquet('outputs/acute_2026_results.parquet');

-- Perform analyst-side aggregation or filtering.
-- No calculator formula logic appears here.
SELECT stream, pricing_year, sum(nwau) AS total_nwau
FROM acute_results
GROUP BY stream, pricing_year;
```

### Supported calculators

Any calculator that exposes Parquet/CSV output through the CLI/file interop
contract is accessible from DuckDB. The SQL layer never reimplements formula
logic.

### Limitations

- Complex classifiers and groupers (AR-DRG, UDG, AECC) remain in the shared
  core. DuckDB cannot derive these classifications from raw inputs without
  calling the core.
- DuckDB does not host the calculator runtime. All calculated columns must be
  pre-materialized through the CLI or file contract.
- DuckDB UDFs are deferred until a clear analytical use case requires them
  and the shared Rust core exposes a stable C ABI or Arrow UDF interface.

## Versioning

- DuckDB SQL consumers use the CLI/file interop contract version as their
  schema reference.
- No separate DuckDB-specific version is needed. The contract bundle lives in
  `contracts/interop/`.
- SQL examples and fixture validation track the shared fixture suite.

## Diagnostics and provenance

- DuckDB consumers get diagnostics from the CLI/file contract (output
  provenance, schema metadata, validation gates).
- SQL-level diagnostics are limited to DuckDB-native file read errors or
  schema mismatches.
- No calculator-level diagnostics are re-exposed in SQL; the consumer must
  inspect the pre-computed output and its provenance record.

## Privacy and synthetic examples

- All committed SQL examples use synthetic fixtures from the golden test
  suite.
- Do not place PHI, patient-level extracts, or licensed classification
  tables in SQL example files.
- Real-data workflows remain the operator's responsibility and must pass
  through the CLI/file contract's fixture gate.

## When to use DuckDB SQL vs. native bindings

Choose DuckDB SQL when:
- the consumer is an analyst or data engineer working in SQL-centric tooling
- the workflow is batch or read-only (aggregation, filtering, joining with
  other tables)
- the data volume fits a file-based boundary (Parquet or CSV on disk)

Prefer native bindings or the CLI/file boundary when:
- the consumer needs in-process or low-latency calculator calls
- the workflow requires per-row classification or grouper logic
- the integration surface needs bidirectional typed contracts

## Readiness bar

- This track is design-only. No DuckDB extension or UDF is being built.
- SQL support is demonstrated through Parquet/CSV examples validated against
  shared golden fixtures.
- Do not claim "DuckDB integration" as production-ready until the CLI/file
  contract's Parquet and CSV paths are stable and fixture-validated for the
  target pricing year.
