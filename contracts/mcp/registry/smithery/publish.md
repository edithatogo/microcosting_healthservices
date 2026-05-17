# Smithery Publication Runbook

Status: prepared, not yet submitted.

## Endpoint

The Smithery-ready adapter runs the existing MCHS MCP JSON-RPC dispatcher over
HTTP:

```bash
mchs-mcp-http --host 0.0.0.0 --port 8765
```

Routes:

- `POST /mcp`: Streamable HTTP JSON-RPC endpoint.
- `GET /healthz`: public readiness probe with no private data.
- `GET /.well-known/mcp/server-card.json`: static server-card metadata for
  Smithery scanner fallback.

## Publication Gate

Do not submit until the endpoint is reachable through public HTTPS. For local
validation, tunnel or deploy the service and verify `initialize`, `tools/list`,
and the server card from the public URL.

## Submission Command

```bash
smithery mcp publish "https://<public-host>/mcp" -n @edithatogo/mchs
```

Record the Smithery listing URL, scan result, and submission timestamp in
`contracts/mcp/registry/submission-decisions.md` before claiming publication.
