# Release Notes: 0.2.2

Date: 2026-05-17

## MCP Server Readiness

- Adds the `mchs-mcp` stdio MCP server entry point.
- Publishes official MCP Registry metadata under
  `contracts/mcp/registry/server.json`.
- Adds the PyPI README verification marker required by the official MCP
  Registry.
- Adds GitHub OIDC automation for MCP Registry publication after the tagged
  package release is visible on PyPI.
- Keeps Docker, Smithery, and hosted HTTP deployment out of scope for this
  release.

## Validation Scope

This release prepares local stdio MCP use and registry metadata publication. It
does not broaden calculator formula parity claims beyond the existing validated
Python runtime scope.
