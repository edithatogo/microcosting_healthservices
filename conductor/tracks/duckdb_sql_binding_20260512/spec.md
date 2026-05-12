# Specification: SQL and DuckDB Integration

## Overview
Provide a SQL/DuckDB integration path for analysts and data-engineering workflows. SQL integration should use table-valued functions, CLI/file round trips, or Arrow/Parquet contracts over the shared core rather than SQL reimplementations of formulas.

## Functional Requirements
- Evaluate DuckDB extension, Python/Rust UDF, and CLI/Arrow-file integration paths.
- Define tabular input/output schemas for SQL workflows.
- Reuse shared fixtures as tables.
- Document limitations around complex classifier/grouper dependencies.

## Acceptance Criteria
- SQL/DuckDB roadmap identifies the initial supported path.
- SQL examples validate against shared fixtures.
- No formula logic is hand-copied into SQL snippets.
