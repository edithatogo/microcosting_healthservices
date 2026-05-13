# OpenAI Tool Adapter Strategy

> Parallel-agent notice: OpenAI compatibility is a generated adapter strategy.
> Do not make the calculator service emulate an LLM endpoint.

## Strategy

- Generate OpenAI tool definitions from canonical schemas.
- Use the domain API or MCP server as the execution backend.
- Preserve diagnostics, errors, provenance, and support status in tool outputs.
- Keep prompts and model orchestration outside the calculator core.
- Avoid `/v1/chat/completions` or `/v1/responses` compatibility claims for the
  calculator service itself.

## Tool candidates

- `mchs_list_calculators`
- `mchs_get_schema`
- `mchs_validate_input`
- `mchs_calculate`
- `mchs_explain_result`
- `mchs_get_evidence`

## Validation

Generated tool definitions must be checked against canonical JSON Schemas and
must not contain formula logic or model-specific business rules.
