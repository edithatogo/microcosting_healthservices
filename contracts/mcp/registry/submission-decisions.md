# MCP Registry Submission Decisions

Date: 2026-05-17

## Current Artifact

The first runnable MCP artifact is a stdio server launched with `mchs-mcp`.
Docker is not required.

## Registry Decisions

| Registry | Decision | Evidence |
| --- | --- | --- |
| Official MCP Registry | Published. | `mcp-publisher` published `io.github.edithatogo/mchs` version `0.2.2` on 2026-05-17; registry search API returns active/latest metadata for `io.github.edithatogo/mchs`; `nwau-py 0.2.2` is visible on PyPI. |
| Glama | Eligible through official-registry indexing; no separate authenticated submission completed from this environment. | Glama documentation states it is a superset of the official MCP Registry. Direct Glama API verification was blocked by its edge protection from this environment. |
| Smithery | Ready for hosted submission, not yet published. | `mchs-mcp-http` provides a Streamable HTTP adapter and `contracts/mcp/registry/smithery/` records the runbook and server-card fallback. No public HTTPS endpoint or Smithery listing is recorded yet. |
| Docker MCP Registry | Ready for validation and PR, not yet published. | `Dockerfile`, `scripts/smoke_mcp_container.py`, and `contracts/mcp/registry/docker/` provide the local containerized server candidate. Docker Registry validation and PR evidence are not recorded yet. |

## Official MCP Registry Basis

Checked against the official MCP Registry documentation on 2026-05-17:

- The registry is still in preview, so release evidence must not overclaim
  permanent listing stability.
- PyPI packages use `"registryType": "pypi"` in `server.json`.
- Stdio package transports use `"transport": { "type": "stdio" }`.
- PyPI ownership verification requires the published package README to contain
  `mcp-name: $SERVER_NAME`; this project uses
  `mcp-name: io.github.edithatogo/mchs`.
- The GitHub namespace `io.github.edithatogo/mchs` is compatible with GitHub
  OIDC publication from the `edithatogo/mchs` repository.

## Release Execution

The concrete `v0.2.2` release sequence is recorded in
`contracts/mcp/registry/release-execution-v0.2.2.md`.

## Local Stdio Configuration

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

For development from the repository checkout:

```bash
uv run mchs-mcp
```

## Publication Evidence

- GitHub release: `https://github.com/edithatogo/mchs/releases/tag/v0.2.2`
- PyPI package: `https://pypi.org/project/nwau-py/0.2.2/`
- Official MCP Registry search:
  `https://registry.modelcontextprotocol.io/v0/servers?search=io.github.edithatogo%2Fmchs`
- MCP Registry publish workflow:
  `https://github.com/edithatogo/mchs/actions/runs/25981730256`

## Remaining Submission Blockers

- Smithery requires public HTTPS hosting and Smithery scan/listing evidence
  before publication can be claimed.
- Docker MCP Registry requires Docker Registry validation and a PR or merge
  record before Docker MCP Catalog publication can be claimed.
