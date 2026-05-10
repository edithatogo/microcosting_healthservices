# Power BI and Power Platform CLI Tooling — Verification Handoff

## Scope Completed in This Phase

- Implemented and documented the repository bootstrap command in `scripts/bootstrap-power-platform-powerbi-cli.sh`.
- Captured command contracts for `pac`, `powerbi`, and `az` in-track spec.
- Recorded the tooling decision to avoid `pacx` and rely on supported Microsoft CLI surfaces (`pac`, `az`, `powerbi`).
- Recorded minimum supported tooling versions and hardening checks:
  - `pac >= 1.35.0` (managed via `dotnet tool` install/update)
  - `powerbi >= 1.0.0` (managed via npm install/update)
  - `az >= 2.70.0` (required preinstalled dependency)

## Manual Verification Guidance

Run these commands from the repository root in a clean shell where `pac` is not preloaded:

1. `./scripts/bootstrap-power-platform-powerbi-cli.sh`
   - Expected: exits successfully and prints command matrix smoke-check logs.
2. `command -v pac`
   - Expected: returns a path (typically `~/.dotnet/tools/pac`).
3. `command -v powerbi`
   - Expected: returns a path (typically npm global bin).
4. `command -v az`
   - Expected: returns a path for Azure CLI.
5. `./scripts/bootstrap-power-platform-powerbi-cli.sh`
   - Expected: succeeds again without reinstalling already healthy binaries.
6. If `pac` remains undetected even after reinstall:
   - `export PATH="$PATH:$HOME/.dotnet/tools"`
   - `command -v pac` should now resolve to `$HOME/.dotnet/tools/pac`.

## Handoff Conditions

- `pac` and `powerbi` are considered available when smoke checks above succeed:
  - `pac --help`
  - `pac auth --help`
  - `pac solution --help`
  - `pac solution checker --help`
  - `powerbi --help`
  - `powerbi workspace --help`
  - `powerbi dataset --help`
  - `powerbi report --help`
  - `az --version`
  - `az version`
- Conductor-facing artifacts now reference the track:
  - Registry entry in `conductor/tracks.md`
  - Plan and tests updated to reflect Phase 4 completion
  - Track index links to this file
