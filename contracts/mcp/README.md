# MCHS MCP Contract

This directory defines the Model Context Protocol (MCP) surface contract for the Micro-Costing Health Services (MCHS) system. MCP enables AI assistants to discover and interact with micro-costing calculators, run calculations, and retrieve evidence.

## Documents

| File | Description |
|---|---|
| `tools.md` | MCP tool definitions for calculator operations |
| `resources.md` | MCP resource definitions for schemas, support status, and evidence |
| `examples/` | Pass, fail, and unsupported request/response examples |
| `registry/server.json` | Published public registry metadata for the stdio MCP server |
| `registry/submission-decisions.md` | Registry submission decisions and publication evidence |

## Design Principles

- All tool input/output shapes conform to the canonical JSON Schemas in `contracts/canonical/`.
- Tools are idempotent where possible.
- Resources are read-only and represent static or semi-static data.
- No formula logic is exposed — tools delegate to the canonical calculation engine.

## Registry Publication Targets

This directory is the MCP contract and registry evidence for the published
stdio MCP server. The runnable server artifact is the `mchs-mcp` console script
included in `nwau-py` beginning with version `0.2.2`.

When a server exists, use this registry order:

| Target | Use when | Status for MCHS |
| --- | --- | --- |
| Official MCP Registry (`registry.modelcontextprotocol.io`) | Public server metadata is ready and points to a public package, container, or remote endpoint. This is the canonical MCP metadata registry. | Published as `io.github.edithatogo/mchs` version `0.2.2`. |
| Docker MCP Registry / Docker MCP Catalog | The server has a Docker deployment path and should be discoverable through Docker Desktop and Docker Hub tooling. | Deferred until a container artifact exists. |
| Glama | The server is open source or publicly reachable and should be indexed, inspected, and tested through a public discovery layer. | Eligible through official MCP Registry indexing; no separate authenticated submission is recorded. |
| Smithery | The server exposes Streamable HTTP with OAuth where required, or ships a local MCPB bundle for stdio distribution. | Deferred until Streamable HTTP or MCPB packaging exists. |

Private or restricted healthcare deployments should use a private registry or
internal catalog instead of the public official MCP Registry.

## Local Stdio Server

The first runnable server shape is stdio. It can be launched without Docker:

```bash
uv run mchs-mcp
```

MCP client configuration:

```json
{
  "mcpServers": {
    "mchs": {
      "command": "mchs-mcp",
      "args": []
    }
  }
}
```

The server exposes the contracted tools and resources while preserving the
boundary that formula logic belongs in the canonical runtime, not the MCP
adapter.
