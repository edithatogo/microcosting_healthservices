# ALM Workflow

## Command Flow

1. Unpack the current solution into source control.
2. Edit unpacked assets.
3. Pack the solution artifact from the unpacked tree.
4. Validate with solution checker.
5. Import into a target environment as a managed solution.

## Supported Tooling

- `pac` for solution lifecycle commands.
- `az` for surrounding authentication and environment access.
- `powerbi` only when BI surface delivery is part of the release.

## Promotion Contract

- Development produces unpacked source and optional unmanaged artifacts.
- Test and production consume managed solutions.
- Promotion must remain gated by solution checker output and tracked approval state.
