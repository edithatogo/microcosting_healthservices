# Go bindings scaffold

This directory contains a synthetic, non-published Go module used as a
prototype binding surface.

Scope:

- Typed spreadsheet-shaped structs
- A file interop adapter boundary
- A small CLI that round-trips model data through the adapter

Out of scope:

- Formula parsing
- Formula evaluation
- Spreadsheet calculation semantics
- Repo-wide build or release wiring

## Layout

- `model/`: typed data structures
- `interop/`: file adapter abstraction and JSON-backed implementation
- `cmd/mchsbind/`: minimal CLI entrypoint

## Usage

```bash
cd bindings/go
go run ./cmd/mchsbind load --path ./sample.json
go run ./cmd/mchsbind save --path ./sample.json < ./input.json
```

The CLI only loads and saves model data. It does not compute formula results or
mutate formula expressions.
