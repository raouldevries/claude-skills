# Triage Rubric

Triage every Codex finding individually. Each finding gets exactly one verdict. No finding may be skipped or left unclassified.

## Severity Definitions

These definitions match the Codex plan audit prompt. They are reproduced here so this rubric can be read standalone.

**P0** — Structural flaw that would cause implementation to fail or produce the wrong result.
Examples: step references a nonexistent API, circular dependency between steps, missing step required for the goal, acceptance criteria that contradict each other.

**P1** — Logic gap that would cause ambiguity or wasted audit-loop cycles during implementation.
Examples: vague acceptance criteria requiring implementer guesswork, step ordering that forces rework, missing file path for a modification step, dependency on an unconfigured tool.

**P2** — Improvement that would make the plan clearer or more efficient but isn't blocking.
Examples: steps that could be parallelized, acceptance criteria that could be more specific, missing but inferrable file paths, minor scope gaps.

## Verdicts

### FIX

The finding identifies a real defect in the plan that must be corrected.

**Requirements:**
- Evidence: Cite the specific file path, line, or pattern in the repo that confirms the defect
- Action: Describe the concrete change to make to the plan

**Example:**
```
Finding: "Step 3 references UserService.getAll() which doesn't exist"
Verdict: FIX
Evidence: Checked src/services/ — no UserService file. Nearest match: src/services/user_repo.py:42 UserRepository.list_users()
Action: Update step 3 to reference UserRepository.list_users() and change file path to src/services/user_repo.py
```

### DISMISS

The finding is incorrect because either (a) the plan already handles the concern, or (b) repo evidence shows the concern does not apply.

**Requirements:**
- Evidence: Cite a specific file path + line number or pattern that proves one of the two cases above. Before logging a DISMISS, confirm the evidence field contains a file path. A DISMISS without a file citation is invalid — reclassify as FIX or SCOPE-OUT.

**Example:**
```
Finding: "Plan should include a database migration step"
Verdict: DISMISS
Evidence: Project uses Alembic auto-migrations (alembic/env.py:23 — target_metadata configured), triggered in CI pipeline (.github/workflows/deploy.yml:45 — alembic upgrade head). No manual migration step needed.
```

### SCOPE-OUT

The finding raises a valid concern that the repo does not address, but it is outside the scope of this plan's stated goal.

**Requirements:**
- Justification: Explain why this is out of scope, referencing the plan's stated goal
- Future work: Note where this concern should be tracked (or "Not tracked" if no clear owner)

**Example:**
```
Finding: "Consider adding a rollback procedure for step 5"
Verdict: SCOPE-OUT
Justification: Valid concern but this plan's goal is initial implementation, not operational runbook. Rollback procedures belong in a separate deployment plan.
Future work: Add to project backlog as a follow-up task.
```

## Round-Aware Severity Thresholds

Not all findings are worth fixing in every round. As the plan matures through rounds, the bar for what justifies another revision cycle rises.

| Rounds | Fix threshold | Rationale |
|--------|--------------|-----------|
| 1–2 | P0 + P1 | Both rounds: fix structural flaws and ambiguity |

Both rounds use the same threshold. Round cap at 2 prevents diminishing-returns cycles.

**Applying the threshold:**
- Triage ALL findings regardless of round (every finding gets a verdict)
- After triage, filter FIX verdicts against the current round's threshold
- Findings below threshold: keep the FIX verdict in the log but do NOT revise the plan for them
- Below-threshold findings are accepted risk for this plan iteration and are included in the convergence summary for the user to review post-convergence

**Escalation trigger:** If a P0 finding persists after both rounds of triage, escalate to the user per the escalation rules in SKILL.md.

## Convergence Criteria

The plan has **converged** when a Codex audit round produces zero FIX findings that meet the current round's severity threshold after triage.

In other words:
- Run Codex audit → get findings
- Triage each finding → assign verdicts
- Filter FIX verdicts by round threshold
- If zero FIX findings survive the filter → **converged**
- If any FIX findings survive → apply fixes, increment round, run another cycle

## Triage Log Format

Log every finding's triage result for auditability. Use this format:

```
## Round N Triage Log

### Finding 1: <short title from Codex>
- Severity: P0|P1|P2
- Verdict: FIX|DISMISS|SCOPE-OUT
- Recurrence: NEW | seen in round(s) N, M
- Evidence/Justification: <as required by verdict>
- Action: <plan change if FIX, "none" otherwise>
- Future work: <for SCOPE-OUT only — where to track, or "Not tracked">
- Threshold: <ABOVE|BELOW current round threshold>

### Finding 2: ...
```

The triage log is ephemeral — it lives in the conversation context, not as a committed file. Its purpose is to make the triage reasoning visible and auditable within the session.
