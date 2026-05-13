# DotNet binding prototype

This directory contains a synthetic C#/.NET scaffold for a future binding
surface. It is intentionally not a calculator implementation and is not
publication-ready.

## What this prototype provides

- typed request/response models
- a file-based interop adapter boundary
- a small CLI entrypoint that loads a request file and writes a response file

## What it does not provide

- formula logic
- clinical or financial business rules
- packaging for public distribution

The adapter is intentionally narrow. It only validates the file boundary and
round-trips structured data between JSON files. Any calculation engine should
live behind this boundary later, not inside the scaffold.

## Usage

```bash
dotnet run --project bindings/dotnet -- \
  --request ./request.json \
  --response ./response.json
```

### Request schema

`request.json` should contain a `BindingRequest` document:

```json
{
  "inputPath": "./input.csv",
  "outputPath": "./output.csv",
  "operation": "scaffold-only",
  "correlationId": "example-correlation-id",
  "metadata": {
    "source": "synthetic"
  }
}
```

### Response schema

The CLI writes a `BindingResponse` document to the response path and also
prints the same payload to stdout:

```json
{
  "success": true,
  "status": "scaffold-only",
  "operation": "scaffold-only",
  "inputPath": "./input.csv",
  "outputPath": "./output.csv",
  "message": "DotNet binding scaffold completed without calculator logic.",
  "warnings": [
    "Formula logic is intentionally not implemented in this prototype."
  ]
}
```

## Boundary notes

- This code is synthetic and local-only.
- The request/response contract is intentionally small and typed.
- File I/O is separated from any future calculation engine so the adapter can
  be replaced without changing the CLI contract.
