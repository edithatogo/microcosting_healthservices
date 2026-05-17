# Docker MCP Registry Local Validation Evidence

Date: 2026-05-17
Source commit under validation: `a33823b0b607b42e7bf2782bd9a513b01434e3ce`
Docker MCP Registry PR: `https://github.com/docker/mcp-registry/pull/3595`

## Source Repository Validation

```bash
docker pull python:3.11-slim
docker build -t mchs-mcp:local .
python3 scripts/smoke_mcp_container.py mchs-mcp:local
PYTHONPATH=. uv run pytest tests/test_mcp_server.py
uv run ruff check nwau_py/mcp_server.py tests/test_mcp_server.py
```

## Source Repository Results

- `python:3.11-slim` was pulled successfully.
- `docker build -t mchs-mcp:local .` completed successfully after slimming the
  MCP image path to install the package with `--no-deps`.
- `python3 scripts/smoke_mcp_container.py mchs-mcp:local` passed.
- `PYTHONPATH=. uv run pytest tests/test_mcp_server.py` passed: `13 passed`.
- `uv run ruff check nwau_py/mcp_server.py tests/test_mcp_server.py` passed:
  `All checks passed!`.

## Docker MCP Registry Validation

The upstream Docker MCP Registry fork was prepared under `servers/mchs/` with:

- `server.yaml`
- `tools.json`
- `readme.md`

Validation command:

```bash
/tmp/task-bin/task validate -- --name mchs
```

Result:

```text
[pass] Name is valid
[pass] Directory is valid
[pass] Title is valid
[pass] YAML formatting is valid
[pass] Commit is pinned
[pass] Secrets are valid
[pass] Config env is valid
[pass] License is valid
[pass] Icon is valid
[pass] Remote validation skipped (not a remote server)
[pass] OAuth dynamic configuration is valid
```

## Docker MCP Registry Build Helper Note

`/tmp/task-bin/task build -- --tools mchs` launched Docker BuildKit with this
pinned remote git context:

```text
https://github.com/edithatogo/mchs.git#a33823b0b607b42e7bf2782bd9a513b01434e3ce
```

In this local environment the BuildKit remote git-context process produced no
further output and had to be cancelled. The same commit and Dockerfile build
successfully from a clean local checkout, and the resulting image passes the
MCP container smoke test. This is recorded as a local BuildKit/remote-context
blocker, not as evidence of an invalid MCHS Dockerfile.

## Submission Evidence

- Fork branch: `https://github.com/edithatogo/mcp-registry/tree/add-mchs-mcp`
- Docker MCP Registry PR: `https://github.com/docker/mcp-registry/pull/3595`

Docker MCP Catalog publication is not claimed until the PR is merged or the
catalog listing is visible.
