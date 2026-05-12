# Track Template: Subagent Execution Plan

Use this template inside a track when work will be delegated to subagents.

## Model Availability

Requested models are environment-specific. Record the requested model and the
actual model used.

| Requested Model | Intended Use | Fallback |
| --- | --- | --- |
| `gpt-5.4-mini` | Bounded implementation, docs, fixtures, simple tests | current default model |
| `gpt-5.4` or stronger | architecture, integration, security-sensitive work | current default frontier model |
| `deepseek-v4` | external model where available | current default model or defer |

## Assignment Table

| Subagent | Role | Model Preference | Owned Files | Out of Scope | Required Evidence |
| --- | --- | --- | --- | --- | --- |
| `<name>` | `<explorer|worker|reviewer|validator|docs|release>` | `<model>` | `<paths>` | `<paths>` | `<tests/docs/review/report>` |

## Required Assignment Prompt Fields

- Track ID:
- Phase:
- Role:
- Model preference:
- Fallback model:
- Owned files:
- Out of scope:
- Required actions:
- Acceptance criteria:
- Validation commands:
- Documentation requirements:
- Review requirements:
- Handoff format:
- Coordination warning: do not revert or overwrite work owned by others.

## Required Handoff Format

```markdown
## Subagent Handoff

Role:
Model requested:
Model used:
Track/phase:

### Completed Work

### Files Changed

### Files Inspected

### Tests or Validation Run

### Documentation Updated

### Review Findings and Fixes

### Contract or Schema Impact

### Residual Risks or Blockers

### Recommended Next Action
```

## Phase Integration Checklist

- [ ] All subagent handoffs received.
- [ ] Changed files do not conflict.
- [ ] Tests or validation evidence exists.
- [ ] Documentation/examples updated where needed.
- [ ] Contract/schema/versioning impact recorded.
- [ ] `conductor-review` run automatically.
- [ ] High-confidence fixes applied.
- [ ] Validation rerun.
- [ ] Phase checkpoint created.
- [ ] Next phase/task started automatically unless blocked.
