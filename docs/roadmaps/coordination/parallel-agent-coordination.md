# Parallel Agent Coordination

> Parallel-agent notice: Codex is currently updating roadmap, track, support
> status, and release-planning files. Cline/deepseek may be working in Rust
> implementation, contract, and binding paths at the same time. Agents should
> avoid broad rewrites, preserve each other's work, and stage only owned files.

## Coordination rules

- Use explicit file ownership in each task handoff.
- Do not edit another agent's active implementation files without coordination.
- Prefer additive roadmap/contract changes over broad rewrites.
- Keep formula logic only in the Rust core track.
- Keep adapters thin and contract-driven.
- Update `review.md` and validation evidence before handoff.
- If a track is marked `No new development`, do not implement it unless the
  roadmap status is changed first.

## Active lanes

| Lane | Ownership | Primary paths |
| --- | --- | --- |
| A | Rust core implementation | `rust/crates/` |
| B | Canonical and surface contracts | `contracts/` |
| C | Roadmaps, tracks, support matrix | `docs/roadmaps/`, `conductor/tracks/` |
| D | Binding experiments and deferred surfaces | `bindings/`, binding fixtures |
| E | CI/CD, release evidence, docs site | `.github/`, `docs-site/`, release docs |

## Handoff checklist

- Files changed are listed.
- Validation command and result are recorded.
- Known blockers are recorded.
- Unsupported support claims are marked `blocked`, `planned`, or
  `no_new_development`.
- No generated artefact or implementation file is staged by the wrong lane.
