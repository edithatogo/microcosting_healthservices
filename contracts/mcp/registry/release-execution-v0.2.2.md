# MCP Release Execution: v0.2.2

Date prepared: 2026-05-17

## Current State

- Local package metadata is prepared for `0.2.2`.
- Local package artifact validation is prepared for `0.2.2` and checks the
  wheel/sdist for the MCP entry point, README verification marker, package
  data, clean archive boundaries, and license metadata.
- The PyPI publish workflow verifies release evidence artifacts in `dist/` but
  stages only wheel and source distribution files into `dist-pypi/` for upload.
- GitHub has an unpublished draft release named `nwau_py v0.2.2`.
- The draft release currently targets `refs/heads/master` and has no published
  tag artifact yet.
- The working tree contains many unrelated modified and untracked files, so a
  release tag should not be created until the intended release changes are
  reviewed and committed cleanly.

## Required Release Sequence

1. Review and commit the intended release changes.
2. Ensure `master` contains the committed `0.2.2` release source.
3. Create and push tag `v0.2.2`.
4. Publish the GitHub draft release for `v0.2.2`.
5. Confirm the Python publish workflow publishes `nwau-py 0.2.2` to PyPI.
6. Confirm `.github/workflows/publish-mcp-registry.yml` runs after release
   publication and publishes `contracts/mcp/registry/server.json` through
   `mcp-publisher`.
7. Verify the official MCP Registry entry by searching for
   `io.github.edithatogo/mchs`.
8. Submit or claim Glama listing once the public release and MCP Registry entry
   are visible.

## Commands

```bash
RELEASE_REF_NAME=v0.2.2 RELEASE_REF_TYPE=tag uv run python .github/scripts/validate_release_metadata.py
uv run python .github/scripts/validate_mcp_package_artifacts.py
uv run pytest tests/test_mcp_server.py tests/test_release_evidence_automation.py tests/test_release_governance.py
uv run ruff check nwau_py/mcp_server.py tests/test_mcp_server.py .github/scripts/validate_release_metadata.py .github/scripts/validate_mcp_package_artifacts.py
```

After the intended release commit is clean:

```bash
git tag v0.2.2
git push origin v0.2.2
gh release edit v0.2.2 --draft=false
```

## Do Not Do

- Do not tag from a dirty worktree.
- Do not publish the GitHub draft before the `0.2.2` source is committed.
- Do not claim official MCP Registry publication until the registry search
  returns the entry.
- Do not submit to Docker MCP Registry unless a container artifact is added.
