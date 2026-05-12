# Track Template: Governance Checklist

Use this checklist when creating any new Conductor track or auditing an
existing one.

## Required Fields

- `track_id`
- `type`
- `status`
- `track_class`
- `current_state`
- `primary_contract`
- `dependencies`
- `completion_evidence`
- `publication_status`
- `created_at`
- `updated_at`
- `description`

## Allowed Track Classes

- `governance`
- `source-discovery`
- `data-contract`
- `validator`
- `calculator`
- `classifier`
- `costing`
- `binding`
- `publication`
- `audit`

## Allowed Current States

- `roadmap-only`
- `scaffold-only`
- `in-progress`
- `complete-with-gaps`
- `complete`

## Required Questions

- Does this track duplicate an existing track?
- What contract will exist when this track is done?
- What evidence proves the contract was achieved?
- What tracks or artifacts must exist before this can start?
- What tracks or surfaces depend on this?
- Does this track affect published packages, docs, GitHub Pages, releases, or
  registry state?
- Does this track make a validation claim? If yes, where is the SAS, Excel,
  fixture, or source-gap evidence?
- Does this track expose a binding, app, tutorial, or demo? If yes, how does it
  avoid duplicating formula logic?

## Completion Rule

Do not mark a track complete when only the roadmap or scaffold exists. Use
`roadmap-only`, `scaffold-only`, or `complete-with-gaps` until durable evidence
exists.
