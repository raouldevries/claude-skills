---
name: plan-loop
description: Iterative plan refinement with stop-hook enforcement and Codex convergence loop. Refines implementation plans through rounds of self-audit + Codex audit until convergence. Use when a plan needs to be validated against the actual codebase before implementation begins.
---

# Plan Loop

Refine an implementation plan through iterative Claude self-audit + Codex audit rounds until convergence, enforced by a stop hook that prevents premature session exit.

## Inputs

Before starting, confirm you have:
- A plan goal (what the plan should achieve) OR an existing draft plan file
- The target project directory (must be a git repo)
- `codex` CLI available (`command -v codex`)

## Activation

Create the state file to activate stop hook enforcement. Replace `<plan_name>` with a short identifier:

```bash
~/.claude/skills/plan-loop/hooks/update-state.sh init "<plan_name>"
```

Note: Ensure `.claude/plan-loop.local.*` is excluded from version control (via `.git/info/exclude` or `.gitignore`).

After activation, the stop hook blocks session exit until the plan converges or is cancelled. Read `.claude/plan-loop.local.json` to confirm current round/phase at any time.

## The Convergence Loop

```
┌─────────────────────────────────────────────────────────────┐
│                    CONVERGENCE LOOP                          │
│                                                             │
│  ┌─────────┐   ┌───────────┐   ┌─────────┐   ┌─────────┐ │
│  │  DRAFT/  │──▶│SELF-AUDIT │──▶│ CONTEXT │──▶│  CODEX  │ │
│  │  REVISE  │   │(sub-agent)│   │ASSEMBLY │   │  AUDIT  │ │
│  └─────────┘   └───────────┘   └─────────┘   └────┬────┘ │
│       ▲                                            │       │
│       │         ┌───────────┐   ┌─────────┐        │       │
│       └─────────│    FIX    │◀──│ TRIAGE  │◀───────┘       │
│    (next round) │  findings │   │(rebuttal)│               │
│                 └───────────┘   └────┬────┘                │
│                                      │                     │
│                              No FIX findings               │
│                              at threshold?                  │
│                                      │                     │
│                                      ▼                     │
│                                 CONVERGED                   │
└─────────────────────────────────────────────────────────────┘
```

### Phase 1: Draft (Round 1 Only)

**State:** `draft` (set automatically by `init`)

This phase runs only in round 1. In round 2+, the plan revision happens in Phase 5 (Fix) before the round is incremented.

1. Read `~/.claude/skills/make-plan/SKILL.md` to confirm current discovery protocol and plan formatting requirements
2. Use the `/make-plan` discovery protocol: deploy Explore subagents to research the codebase, map existing patterns, find APIs, and identify constraints
3. Consolidate findings into a context summary (allowed APIs, anti-patterns, reusable code)
4. Draft the plan following `/make-plan` Phase 3 formatting (phased steps, acceptance criteria, file paths, dependencies, complexity ratings)
5. Write the plan to the plan file path (typically `.claude/plans/<plan-name>.md`)

**State transition:**
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase self-audit
```

### Phase 2: Self-Audit

**State:** `self-audit`

Spawn a Task sub-agent (type: `code-reviewer`) using the prompt template at `~/.claude/skills/plan-loop/references/self-audit-prompt.md`. Populate placeholders with the current plan file path, relevant codebase files, round number, and prior round fixes (if any).

The sub-agent should:
1. Read the current plan file
2. Reads key codebase files referenced by the plan (verify they exist, check APIs/signatures)
3. Reviews the plan against the severity definitions from `~/.claude/skills/plan-loop/references/triage-rubric.md`:
   - P0: Structural flaw that would cause implementation to fail
   - P1: Logic gap that would cause ambiguity or wasted audit-loop cycles
   - P2: Clarity improvement, not blocking
4. Returns findings in the format:
   ```
   [P0|P1|P2] <short title>
   - Step: <step number and name>
   - Issue: <what is wrong>
   - Evidence: <file path or pattern verified in repo>
   - Impact: <what goes wrong during implementation>
   - Suggested fix: <concrete plan change>
   ```
5. Returns `No P0/P1/P2 findings.` if clean

**Language-semantic guardrail:** If a self-audit finding involves language-specific semantics (decorator ordering, inheritance resolution, async/await behavior, metaclass interactions, etc.), the finding MUST include a concrete code example demonstrating the expected behavior. Do not accept findings that state semantics without a verifiable example — this was the root cause of multi-round convergence failures during testing.

After receiving self-audit findings:
- Fix all P0 and P1 findings immediately (update the plan file)
- Log P2 findings but do not fix them at this stage

**State transition:**
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase codex-audit
```

### Phase 3: Context Assembly + Codex Audit

**State:** `codex-audit`

#### 3a. Assemble context package

If the codebase has not changed since the last context assembly (i.e., only the plan file was modified), reuse the existing context package at `/tmp/plan-loop-context.md`. Reassemble only if plan revisions changed which repo files are referenced.

When assembling (or reassembling), read key files from the repo that are relevant to the plan and write the context package to `/tmp/plan-loop-context.md`. Include:
- Architecture summary (project structure, key frameworks, build system)
- Excerpts from files directly referenced by plan steps (function signatures, class definitions, config patterns)
- Existing patterns the plan should follow or is aware of

Cap context at ~2000 lines. Prioritize files directly referenced by plan steps.

#### 3b. Run Codex audit

Resolve the prompt (project-specific overrides generic), then execute:

```bash
PROMPT="${PWD}/.claude/codex-plan-audit-prompt.md"
[ ! -f "$PROMPT" ] && PROMPT="$HOME/.claude/skills/plan-loop/references/codex-plan-audit-prompt.md"
{ cat /tmp/plan-loop-context.md; printf "\n\n--- BEGIN PLAN ---\n\n"; cat <plan-file-path>; } | codex exec --sandbox read-only "$(cat "$PROMPT")" 2>&1 | tee /tmp/codex-plan-audit-output.md
```

Wait for completion. This may take 1-2 minutes.

**State transition:**
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase triage
```

### Phase 4: Triage

**State:** `triage`

Read `/tmp/codex-plan-audit-output.md` and triage each finding using the rubric at `~/.claude/skills/plan-loop/references/triage-rubric.md`.

For EVERY finding, produce one of three verdicts:

- **FIX** — Real defect. Cite repo evidence confirming the issue. Describe the plan change.
- **DISMISS** — Finding is incorrect or irrelevant. MUST cite a specific file path + line/pattern that makes it irrelevant. A DISMISS without a file citation is invalid — reclassify as FIX or SCOPE-OUT.
- **SCOPE-OUT** — Valid concern but outside this plan's goal. Justify why.

Log all verdicts in the conversation using the triage log format:

```
## Round N Triage Log

### Finding 1: <title>
- Severity: P0|P1|P2
- Verdict: FIX|DISMISS|SCOPE-OUT
- Recurrence: NEW | seen in round(s) N, M
- Evidence/Justification: <as required by verdict>
- Action: <plan change if FIX, "none" otherwise>
- Future work: <for SCOPE-OUT only — where to track, or "Not tracked">
- Threshold: ABOVE|BELOW
```

#### Apply round-aware severity threshold

After triaging all findings, filter FIX verdicts against the current round's threshold:

| Rounds | Fix threshold | What to fix |
|--------|--------------|-------------|
| 1–3 | P0 + P1 | Structural flaws and ambiguity |
| 4–6 | P0 only | Implementation-blocking defects only |
| 7+ | Structural P0 only | Only P0s that would cause a step to fail entirely |

Mark each FIX finding as `ABOVE` or `BELOW` the threshold. Only `ABOVE` findings trigger plan revisions.

#### Convergence check

If zero FIX findings are `ABOVE` the current threshold → the plan has **converged**. Jump to the Convergence section below.

If any FIX findings are `ABOVE` the threshold → proceed to Phase 5 (Fix).

**State transition (if not converged):**
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase fix
```

### Phase 5: Fix + Revise

**State:** `fix`

1. List all FIX findings that are `ABOVE` the current round's threshold
2. Apply each fix to the plan file — update steps, acceptance criteria, file paths, dependencies as needed
3. Do NOT address DISMISS or SCOPE-OUT findings
4. Self-audit P0/P1 findings should already be applied in Phase 2. If any were inadvertently missed, apply them now before incrementing the round
5. Increment the round and proceed to Phase 2 (Self-Audit):

```bash
~/.claude/skills/plan-loop/hooks/update-state.sh round <next_round_number>
```

This resets the phase to `self-audit` and begins the next round. Return to Phase 2.

## Convergence

When the triage phase produces zero FIX findings above the current threshold:

1. Mark the plan as converged:
   ```bash
   ~/.claude/skills/plan-loop/hooks/update-state.sh converge
   ```

2. Print the convergence summary:
   ```
   ══════════════════════════════════════════════════════════════════════════════
     PLAN LOOP ─ <plan_name>
   ══════════════════════════════════════════════════════════════════════════════

     CONVERGED after <N> rounds

     Round history:
       Round 1: <X> findings → <Y> fixed
       Round 2: <X> findings → <Y> fixed
       ...

     Plan file: <path>

     Below-threshold accepted risk:
       - <finding title> (P1|P2, verdict, first seen round N)
       ...
       (or "None" if all findings were fixed)
   ══════════════════════════════════════════════════════════════════════════════
   ```

3. Clean up:
   ```bash
   ~/.claude/skills/plan-loop/hooks/update-state.sh cleanup
   ```

## Escalation Rules

Stop and ask the user in these situations:

- **Ambiguous goal**: If the plan goal is unclear or could be interpreted multiple ways, ask before drafting
- **Round 4+ with P0s persisting**: If the same P0 finding survives 3+ rounds of fixes, escalate — the plan may have a fundamental design issue that needs user input
- **Codex unavailable**: If `codex` CLI is not installed or fails, ask the user whether to proceed with self-audit only or pause
- **Context too large**: If the repo is too large to assemble meaningful context within the ~2000 line cap, ask the user which areas to prioritize

## Cancellation

To cancel an active plan loop, the user says "cancel the plan loop" or similar:

```bash
~/.claude/skills/plan-loop/hooks/update-state.sh cancel
```

This sets the cancelled flag (race safety), reports the current round/phase, and deletes the state file. The plan file is preserved — only the enforcement loop is stopped.

## Resources

- **Self-audit prompt template**: `~/.claude/skills/plan-loop/references/self-audit-prompt.md`
- **Codex plan audit prompt**: `~/.claude/skills/plan-loop/references/codex-plan-audit-prompt.md`
- **Triage rubric**: `~/.claude/skills/plan-loop/references/triage-rubric.md`
- **State management**: `~/.claude/skills/plan-loop/hooks/update-state.sh`
- **Stop hook**: `~/.claude/skills/plan-loop/hooks/stop-hook.sh`
- **Make-plan skill** (for discovery protocol and plan formatting): `~/.claude/skills/make-plan/SKILL.md`
