# Docker MCP Registry Local Validation Attempt

Date: 2026-05-17
Commit under validation: `3a2d07eee5aae3aa03159e1115936c08bb5a5aeb`

## Attempted Commands

```bash
docker --version
task --version
docker build -t mchs-mcp:local .
```

## Results

- Docker is installed: `Docker version 29.4.3, build 055a478ea9`.
- `task` is not installed in this environment, so Docker MCP Registry upstream
  validation commands such as `task validate -- --name mchs` and
  `task build -- --tools mchs` could not be run locally.
- The Docker build did not reach repository build steps. It blocked while
  resolving Docker Hub metadata for `python:3.11-slim` through OrbStack.

Observed build error after canceling the hung build:

```text
ERROR: failed to solve: Canceled: context canceled
#2 ERROR: Unavailable: connection error: desc = "transport: Error while dialing: only one connection allowed"
```

## Interpretation

This is an environment/base-image retrieval blocker, not evidence that the
MCHS Dockerfile is invalid. The next validation attempt should run in an
environment that can pull `python:3.11-slim` and has the Docker MCP Registry
`task` tooling installed.

## Remaining Docker Registry Gates

- Build `mchs-mcp:local` from a clean checkout.
- Run `python scripts/smoke_mcp_container.py mchs-mcp:local`.
- Copy `contracts/mcp/registry/docker/*` into the upstream Docker MCP Registry
  shape under `servers/mchs/`.
- Replace `about.source.commit: UPDATE_BEFORE_DOCKER_REGISTRY_PR` with the
  exact submission commit.
- Run Docker MCP Registry validation tooling.
- Open the Docker MCP Registry PR and record its URL/status before claiming
  Docker MCP Catalog publication.
