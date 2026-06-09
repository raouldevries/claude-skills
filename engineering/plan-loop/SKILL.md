---
name: plan-loop
description: Use when a drafted implementation plan needs validating against the actual codebase before implementation begins — triggers like "validate this plan", "run plan-loop", "audit my plan", or "check this plan for logic errors". Refines the plan through iterative Claude self-audit + Codex audit until convergence. NOT for creating a plan from scratch (use make-plan), nor for implementing plan steps (use audit-loop).
---

# Plan Loop

Refine an implementation plan through iterative Claude self-audit + Codex audit rounds until convergence, enforced by a stop hook that prevents premature session exit.

## Hard Constraint — Plan Document Only

**This skill ONLY edits the plan file. It NEVER writes implementation code.**

- Your output is a revised `.md` plan file — never source code files (`.py`, `.ts`, `.js`, `.html`, etc.)
- "Revise" means editing text in the plan document (rewording steps, updating file paths, adding acceptance criteria). It does NOT mean implementing the steps described in the plan.
- If you catch yourself about to create, edit, or write to a file that is not the plan file or a temporary context/audit file (`/tmp/plan-loop-context.md`, `/tmp/codex-plan-audit-output.md`), **stop immediately** — you are off track.
- Read codebase files for verification only. Never modify them.
- **Pre-write check**: Before every Edit or Write call, verify: (1) the file extension is `.md`, and (2) the file path is the plan file or an allowed temp file. If either check fails, stop — you are about to implement code.

## Inputs

Before starting, confirm you have:
- A plan goal (what the plan should achieve) OR an existing draft plan file
- The target project directory (must be a git repo)
- `codex` CLI available (`command -v codex`)

## Discipline

| Rationalization | Reality |
|---|---|
| "This finding is clearly wrong, I'll DISMISS it" | Every DISMISS requires a file path citation. No citation = reclassify as FIX or SCOPE-OUT. |
| "The context package hasn't changed, skip reassembly" | Only skip if the plan revision didn't change referenced files. Check before assuming. |
| "This is just a P2, not worth fixing" | P2s don't need fixing, but they must be logged. Unlogged findings resurface. |
| "The plan is good enough to converge" | "Good enough" is not a threshold. Zero FIX findings above threshold is the threshold. |
| "I already know what the codebase looks like" | Read the files. Plans validated against assumptions produce wrong implementations. |

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
│                    CONVERGENCE LOOP (max 2 rounds)           │
│                                                             │
│  ┌─────────┐   ┌───────────┐   ┌─────────┐   ┌─────────┐ │
│  │  DRAFT   │──▶│SELF-AUDIT │──▶│ CONTEXT │──▶│  CODEX  │ │
│  │ (R1 only)│   │(R1 only)  │   │ASSEMBLY │   │  AUDIT  │ │
│  └─────────┘   └───────────┘   └─────────┘   └────┬────┘ │
│       ▲          skip in R2 ───────┘                │       │
│       │         ┌───────────┐   ┌─────────┐        │       │
│       └─────────│  REVISE   │◀──│ TRIAGE  │◀───────┘       │
│      (round 2)  │   PLAN    │   │(rebuttal)│               │
│                 └───────────┘   └────┬────┘                │
│                                      │                     │
│                              No FIX findings               │
│                              at threshold?                  │
│          ── OR round 2 (P1-only; P0 → escalate) ──          │
│                                      │                     │
│                                      ▼                     │
│                                 CONVERGED                   │
└─────────────────────────────────────────────────────────────┘
```

### Phase 1: Draft (Round 1 Only)

**State:** `draft` (set automatically by `init`)

> **Guardrail**: This phase reads codebase files for research. Do NOT modify any codebase file. Only write to the plan `.md` file.

This phase runs only in round 1. In round 2+, the plan revision happens in Phase 5 (Revise) before the round is incremented.

1. Read `~/.claude/skills/make-plan/SKILL.md` to confirm current discovery protocol and plan formatting requirements
2. Use the `/make-plan` discovery protocol: deploy Explore subagents to research the codebase, map existing patterns, find APIs, and identify constraints
3. Consolidate findings into a context summary (allowed APIs, anti-patterns, reusable code)
4. Draft the plan following `/make-plan` Phase 3 formatting (phased steps, acceptance criteria, file paths, dependencies, complexity ratings)
5. Write the plan to the plan file path (typically `.claude/plans/<plan-name>.md`)

**State transition:**
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase self-audit
```

### Phase 2: Self-Audit (Round 1 Only)

**State:** `self-audit`

> **Guardrail**: This phase spawns a read-only sub-agent. Do NOT modify any file. Only proceed to Phase 3 after reviewing findings.

**Skip rule**: In round 2, skip this phase entirely and go straight to Phase 3 (Context Assembly + Codex Audit). The self-audit's value peaks in round 1 when the plan is roughest. In round 2, Codex alone provides sufficient coverage.

Spawn a Task sub-agent (type: `code-reviewer`) using the prompt template at `~/.claude/skills/plan-loop/references/self-audit-prompt.md`. Populate its two placeholders — `{{PLAN_FILE_PATH}}` and `{{FILE_LIST}}` (the relevant codebase files to verify).

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

> **Guardrail**: This phase reads codebase files and runs Codex. Do NOT modify any file except `/tmp/plan-loop-context.md`.

#### 3a. Assemble context package

If the codebase has not changed since the last context assembly (i.e., only the plan file was modified), reuse the existing context package at `/tmp/plan-loop-context.md`. Reassemble only if plan revisions changed which repo files are referenced.

When assembling (or reassembling), read key files from the repo that are relevant to the plan and write the context package to `/tmp/plan-loop-context.md`. Include:
- Architecture summary (project structure, key frameworks, build system)
- Excerpts from files directly referenced by plan steps (function signatures, class definitions, config patterns)
- Existing patterns the plan should follow or is aware of

Cap context at ~2000 lines. Prioritize files directly referenced by plan steps.

#### 3b. Run Codex audit via subagent

**Why subagent**: Raw codex output is the largest context consumer in the plan-loop. By delegating execution and parsing to a `code-reviewer` subagent, the raw output stays in the subagent's context (and `/tmp/codex-plan-audit-output.md`) — only the structured P0/P1/P2 findings list returns to the main session.

Spawn an Agent (type: `code-reviewer`) with the following task:

1. **Resolve prompt** — check for project-specific override first:
   ```bash
   ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
   PROMPT="${ROOT}/.claude/codex-plan-audit-prompt.md"
   [ ! -f "$PROMPT" ] && PROMPT="$HOME/.claude/skills/plan-loop/references/codex-plan-audit-prompt.md"
   ```

2. **Execute codex**:
   ```bash
   { cat "$PROMPT"; printf "\n\n--- CODEBASE CONTEXT ---\n\n"; cat /tmp/plan-loop-context.md; printf "\n\n--- BEGIN PLAN ---\n\n"; cat <plan-file-path>; } | codex exec --sandbox read-only - 2>&1 | tee /tmp/codex-plan-audit-output.md
   ```
   If `codex` is not on PATH in the subagent environment, or `${PIPESTATUS[1]}` (the codex stage of the pipe — `tee` would otherwise mask its non-zero exit via `$?`) is non-zero, return `CODEX_UNAVAILABLE` as the only output so the main session invokes the Fallback below. Do NOT parse empty or error output as "No P0/P1/P2 findings" — that would converge the plan without an audit.

3. **Parse output** — read `/tmp/codex-plan-audit-output.md` and extract findings into structured format:
   ```
   [P0|P1|P2] <short title>
   - Step: <step number and name>
   - Issue: <what is wrong>
   - Evidence: <file path or pattern>
   - Impact: <what goes wrong during implementation>
   - Suggested fix: <concrete plan change>
   ```

4. **Return** only the structured findings list (or "No P0/P1/P2 findings.") to the main session.

**Fallback**: If the subagent returns `CODEX_UNAVAILABLE` (codex not on PATH in the subagent environment, or `${PIPESTATUS[1]}` non-zero), the main session runs the codex command from step 2 above (it may have a broader PATH than the subagent), then spawns a `code-reviewer` subagent that only reads `/tmp/codex-plan-audit-output.md` and returns the parsed findings.

Note: `codex exec` reads stdin as the prompt when `-` is passed. The audit instructions, codebase context, and plan are concatenated into a single stdin stream. Wait for completion — this may take 1-2 minutes.

**State transition** (in the main session, after subagent returns):
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase triage
```

### Phase 4: Triage

**State:** `triage`

> **Guardrail**: This phase is analysis only. Do NOT modify the plan file or any codebase file. Only produce the triage log in conversation.

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

#### Apply the severity threshold

After triaging all findings, filter FIX verdicts against the threshold: **fix all P0 and P1 findings in both rounds; log P2 but never revise the plan for it.** (The 2-round hard cap, not a rising bar, is what bounds the loop.)

Mark each FIX finding as `ABOVE` (P0/P1) or `BELOW` (P2). Only `ABOVE` findings trigger plan revisions.

#### Convergence check

If zero FIX findings are `ABOVE` the current threshold → the plan has **converged**. Jump to the Convergence section below.

If any FIX findings are `ABOVE` the threshold → proceed to Phase 5 (Fix).

**State transition (if not converged):**
```bash
~/.claude/skills/plan-loop/hooks/update-state.sh phase fix
```

### Phase 5: Revise Plan

**State:** `fix`

> **Guardrail**: The ONLY file you may modify in this phase is the plan `.md` file. Before every Edit/Write call, verify the target is the plan file. If it is not, stop.

1. List all FIX findings that are `ABOVE` the threshold
2. Apply ALL fixes in a single pass to the **plan file text** — reword steps, update file paths, revise acceptance criteria, adjust dependencies. Batch all changes into one revision rather than fixing findings individually. "Revise" means editing the `.md` plan document, NOT writing implementation code.
3. Do NOT address DISMISS or SCOPE-OUT findings
4. Do NOT create, edit, or write to any source code file
5. Self-audit P0/P1 findings (from round 1) should already be applied in Phase 2. If any were inadvertently missed, apply them now before incrementing the round
6. Compress round 1 context (see Inter-Round Context Compression below), then increment to round 2 (the `round` subcommand advances directly to the codex-audit phase, since self-audit is skipped in round 2):

```bash
~/.claude/skills/plan-loop/hooks/update-state.sh round 2
```

## Inter-Round Context Compression

Before starting round 2, produce a fixed-format summary of round 1. This summary replaces the detailed round 1 artifacts in your working memory.

**Round 1 Summary** (write this in the conversation, 5-10 lines max):
```
Round 1 Summary:
- Findings: <N> total (<X> P0, <Y> P1, <Z> P2)
- Fixed: <list of FIX finding titles>
- Dismissed: <count> (with evidence)
- Scoped out: <count>
- Plan sections revised: <list of section names/step numbers>
- Accepted risk: <any below-threshold findings, or "none">
```

**Concreteness note**: "Compress" means do not re-read or re-quote raw round 1 artifacts (triage logs, codex output, self-audit findings) from conversation history. If you need to reference specific round 1 details during round 2, read from `/tmp/codex-plan-audit-output.md` rather than scrolling back through conversation context. The subagent delegation in Phase 3 already keeps raw codex output out of the main context — this compression step handles the triage log and fix details.

## Hard Cap — Round 2

If round 2 completes triage and still has FIX findings above threshold:
- **P0 persists** → escalate to the user. The plan likely needs user input on a fundamental design question.
- **P1 only** → force convergence with accepted risk. Log remaining P1 findings as "Accepted risk — hard cap reached" and proceed to the Convergence section below.

This prevents diminishing-returns cycles. Two rounds of audit is sufficient for any plan — empirical data shows rounds 3+ never converge and exhaust the context window instead.

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
       Round 2: <X> findings → <Y> fixed (or "converged in round 1")

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

## Completion Verification

Before claiming convergence or completing any round:
1. Confirm zero FIX findings are ABOVE the threshold — count them explicitly
2. Verify every DISMISS verdict has a file path citation — re-read your triage log
3. Confirm every FIX was actually applied to the plan file — re-read the changed sections

Forbidden claims without evidence:
- "the plan looks good now" — show the triage log with zero above-threshold FIX findings
- "findings are minor" — classify them per the rubric, don't editorialize
- "converged" — only after the threshold check passes, not before
- "context hasn't changed" — list which plan references changed and confirm none affect context

## Escalation Rules

Stop and ask the user in these situations:

- **Ambiguous goal**: If the plan goal is unclear or could be interpreted multiple ways, ask before drafting
- **Persistent P0s**: If a P0 finding persists after both rounds, escalate to the user — the plan may have a fundamental design issue.
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
