# Canonical Schema Priority

> Parallel-agent notice: contract and implementation agents should derive
> surface-specific schemas from this priority order rather than inventing
> independent request/response shapes.

## Immediate canonical schemas

1. `support-status.schema.json`
2. `calculator-request.schema.json`
3. `calculator-response.schema.json`
4. `hwau-output.schema.json`
5. `price-schedule.schema.json`
6. `valuation-output.schema.json`
7. `diagnostic.schema.json`
8. `error.schema.json`
9. `provenance.schema.json`
10. `evidence-bundle.schema.json`

## Derivation rule

- CLI/file schemas derive from canonical schemas.
- HTTP OpenAPI components derive from canonical schemas.
- MCP tool schemas derive from canonical schemas.
- OpenAI tool definitions derive from canonical schemas.
- Language bindings derive from canonical schemas.

## Schema ownership

The canonical contract foundation owns schema semantics. Surface tracks may add
transport metadata, but they may not rename domain concepts or add formula
logic.
