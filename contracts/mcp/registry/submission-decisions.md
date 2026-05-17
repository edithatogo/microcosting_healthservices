# MCP Registry Submission Decisions

Date: 2026-05-16

## Current Artifact

The first runnable MCP artifact is a stdio server launched with `mchs-mcp`.
Docker is not required.

## Registry Decisions

| Registry | Decision | Evidence |
| --- | --- | --- |
| Official MCP Registry | Automated through GitHub OIDC after a package release includes `mchs-mcp`; blocked only until the next release/tag is published. | `contracts/mcp/registry/server.json`; `nwau_py/README.md` contains `mcp-name: io.github.edithatogo/mchs` for PyPI ownership verification; `.github/workflows/publish-mcp-registry.yml` runs `mcp-publisher publish`. |
| Glama | Prepared as a secondary discovery target after the public release contains the MCP entry point. | Public repository and stdio server metadata exist. |
| Smithery | Deferred. | No Streamable HTTP endpoint or MCPB bundle exists in this track. |
| Docker MCP Registry | Deferred. | No Docker image is required or produced for the first MCP release. |

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

## Submission Blockers

- Official registry submission is automated with GitHub OIDC. The workflow
  waits for the tagged `nwau-py` version to appear on PyPI, then runs
  `mcp-publisher login github-oidc` and `mcp-publisher publish` from the
  directory containing `server.json`.
- Public package metadata must be refreshed after the next release that includes
  the `mchs-mcp` console script.
- Smithery and Docker registry submission require packaging surfaces that are
  intentionally out of scope for the first stdio release.
