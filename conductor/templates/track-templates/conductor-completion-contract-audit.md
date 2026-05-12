# Track Template: Conductor Completion and Contract Audit

Use this template to create a recurring audit track that verifies whether the Conductor system, completed tracks, contracts, and claimed outcomes are explicitly stated, internally consistent, and actually achieved.

## Template Variables

- `TRACK_ID`: `conductor_completion_contract_audit_<YYYYMMDD>`
- `TRACK_TITLE`: `Conductor Completion and Contract Audit`
- `AUDIT_DATE`: `<YYYY-MM-DD>`
- `AUDIT_SCOPE`: `<all tracks | selected tracks | release milestone>`
- `AUDITOR`: `<name or role>`

## metadata.json

```json
{
  "track_id": "TRACK_ID",
  "type": "chore",
  "status": "new",
  "created_at": "AUDIT_DATET00:00:00Z",
  "updated_at": "AUDIT_DATET00:00:00Z",
  "description": "Audit Conductor completion claims, explicit contracts, and achieved evidence across AUDIT_SCOPE."
}
```

## spec.md

```markdown
# Specification: TRACK_TITLE

## Overview
Audit Conductor's project-management state for AUDIT_SCOPE. The audit must determine whether tracks marked complete have explicit contracts, whether those contracts are testable, whether the required evidence exists, and whether the achieved state matches the registry claim.

## Audit Questions
- Are all relevant tracks present in `conductor/tracks.md` and linked to valid `index.md`, `spec.md`, `plan.md`, and `metadata.json` files?
- Do completed tracks state their contracts explicitly enough to test or inspect?
- Do completed tracks have evidence that acceptance criteria were achieved?
- Are implementation claims backed by code, docs, tests, CI, releases, package publication, or other durable artifacts?
- Are incomplete, scaffold-only, or roadmap-only tracks clearly marked as such?
- Do archive locations, active-track links, and workflow paths agree?
- Are there stale paths, stale badges, stale repo names, stale workflow references, or broken source-of-truth links?
- Are future-state statements clearly distinguished from current validated behavior?
- Does each track have a roadmap-governance class, dependency statement, explicit contract, and completion-evidence requirement?

## Required Evidence
- Tracks registry status and links.
- Track metadata status.
- Contract statements in specs, ADRs, docs, or public API files.
- Tests, CI workflows, release artifacts, docs pages, package registry pages, and generated artifacts where claimed.
- GitHub PR/branch/release/package status where applicable.

## Acceptance Criteria
- Every audited track is classified as `complete`, `complete-with-gaps`, `roadmap-only`, `scaffold-only`, `in-progress`, or `stale/inconsistent`.
- Every completed track has an explicit contract or a documented gap requiring follow-up.
- Every completed claim has durable evidence or a documented remediation track.
- Tracks missing class/dependency/contract/evidence metadata are updated or flagged for remediation.
- Stale links, stale workflow paths, and inaccurate status claims are fixed or converted into follow-up tasks.
- The audit produces a concise findings table and remediation backlog.

## Out of Scope
- Implementing every remediation found by the audit.
- Rewriting completed tracks unless their status is inaccurate.
```

## plan.md

```markdown
# Plan: TRACK_TITLE

## Phase 1: Inventory and Link Integrity
- [ ] Task: Inventory registry entries, active tracks, archived tracks, and linked files.
    - [ ] Check every registry link resolves.
    - [ ] Check every track has `index.md`, `spec.md`, `plan.md`, and `metadata.json`.
    - [ ] Check archived tracks are not referenced by stale active workflow paths.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 1: Inventory and Link Integrity' (Protocol in workflow.md)

## Phase 2: Contract Explicitness Audit
- [ ] Task: Audit whether each selected track states explicit contracts and acceptance criteria.
    - [ ] Identify ambiguous contracts, future-state claims, and untestable language.
    - [ ] Map contracts to tests, docs, ADRs, APIs, workflows, or artifacts.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 2: Contract Explicitness Audit' (Protocol in workflow.md)

## Phase 3: Achievement Evidence Audit
- [ ] Task: Verify claimed completion against durable evidence.
    - [ ] Check code, tests, docs, workflows, releases, packages, Pages, registries, and GitHub metadata as applicable.
    - [ ] Classify each track as complete, complete-with-gaps, roadmap-only, scaffold-only, in-progress, or stale/inconsistent.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 3: Achievement Evidence Audit' (Protocol in workflow.md)

## Phase 4: Remediation Backlog
- [ ] Task: Create or update follow-up tracks for unresolved gaps.
    - [ ] Fix high-confidence stale paths and inaccurate status claims.
    - [ ] Add remediation tasks for incomplete contracts, missing evidence, and stale publication claims.
- [ ] Task: Conductor - Automated Review and Checkpoint 'Phase 4: Remediation Backlog' (Protocol in workflow.md)
```
