# Conductor Track Templates

These templates are reusable starting points for recurring governance and discovery tracks.

## Templates

- `track-governance-checklist.md`: required governance fields and questions for every new or audited track.
- `subagent-execution-plan.md`: reusable delegation plan for tracks that use parallel subagents.
- `conductor-completion-contract-audit.md`: audit Conductor track completion, contract explicitness, and evidence of achievement.
- `ihacpa-discovery-audit.md`: search IHACPA for new formulae, systems, mappings, classifications, costing materials, and documentation.
- `repository-publication-sota-audit.md`: audit local/remote repository health, branches, PRs, CI, Pages, homepage, packages, releases, versions, dependency currency, examples, and tutorials.

## Usage

1. Copy the relevant template into a new directory under `conductor/tracks/<track_id>/`.
2. Replace all template variables.
3. Split the embedded `metadata.json`, `spec.md`, and `plan.md` sections into real files.
4. Apply `track-governance-checklist.md` so class, current state, dependencies, contract, completion evidence, and publication status are explicit.
5. Add an `index.md` linking the files.
6. Add the new track to `conductor/tracks.md`.
7. Execute the plan using the project workflow.

These templates are intentionally evidence-heavy. They should produce a clear distinction between completed, scaffolded, roadmap-only, stale, and truly published states.
