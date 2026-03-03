---
name: audit-loop
description: Use when implementing a plan step end-to-end with built-in quality gates and external audit verification.
---

# Audit Loop

Automate the full implement-audit-fix cycle for one plan step.

## Inputs

Before starting, confirm you have:
- A plan file with the step spec (user provides path or describes the step)
- The resolved progress file open for tracking (default: `memory-bank/progress.md`)
- The resolved validation command passing on the current codebase (default: `make validate`)

## Discipline

| Rationalization | Reality |
|---|---|
| "This change is too small to need tests" | Small changes break things. Write the test — it takes 30 seconds. |
| "The test would just verify the same code" | That's what tests do. Write it anyway. |
| "I'll fix the Codex finding later" | Classify it as FIX, DOCUMENT, or DISMISS. "Later" means never. |
| "The spec is clear enough, no need to re-read" | Re-read the spec. Drift from spec is the #1 audit finding. |
| "Validation passed, so the implementation is correct" | Passing validation means no syntax/type errors. It doesn't mean the code is correct. Run the acceptance criteria tests. |

## Activation

Before starting Phase 1, create the state file for stop hook enforcement. Replace `<step_name>` with the actual plan step name:

```bash
~/.claude/skills/audit-loop/hooks/update-state.sh init "<step_name>"
```

To use gate mode instead of the default TDD mode:

```bash
~/.claude/skills/audit-loop/hooks/update-state.sh init "<step_name>" --mode gate
```

**Important**: Create `.claude/audit-loop.config.yaml` (see Configuration below) *before* running `init` — config values are read once at init time and stored in the state file.

Note: Ensure `.claude/audit-loop.local.*` is excluded from version control (via `.git/info/exclude` or `.gitignore`).

## Configuration

Project-specific settings are read from `.claude/audit-loop.config.yaml` at the project root (resolved via `git rev-parse --show-toplevel`). All fields are optional — omitted fields use defaults.

```yaml
# .claude/audit-loop.config.yaml
validate_command: "ruff check src/ && pytest"   # default: "make validate"
progress_file: docs/progress.md                  # default: "memory-bank/progress.md"
codex_prompt: .claude/codex-audit-prompt.md      # default: "" (use fallback chain)
```

**Resolution order** — values are resolved at `init` and stored in the state JSON:
1. `.claude/audit-loop.config.yaml` in the project root (if present)
2. Defaults: `make validate`, `memory-bank/progress.md`, `""` (empty)

### Mode Selection

| Mode | Flag | When to use |
|------|------|-------------|
| **TDD** (default) | `--mode tdd` | Greenfield steps where writing tests first makes sense |
| **Gate** | `--mode gate` | Existing code or steps where tests already exist — verify coverage, validate, proceed |

### Quick Setup for New Repos

```yaml
# Python project
validate_command: "ruff check src/ && pytest"
progress_file: docs/progress.md

# Node/TypeScript project
validate_command: "npm run lint && npm test"
progress_file: docs/progress.md

# Go project
validate_command: "go vet ./... && go test ./..."
progress_file: docs/progress.md
```

## Pre-Cycle Context Check

Before starting a new audit-loop cycle, assess how many cycles have already completed in this session. Count the number of prior summary banners (`AUDIT LOOP ─`) or committed steps in this conversation.

| Cycle count | Action |
|-------------|--------|
| 1 (first cycle) | Proceed normally |
| 2–3 | Proceed, but monitor for signs of degraded capability (missed findings, incomplete reasoning, summarizing instead of reading) |
| 4+ | Run `/handover` instead of starting a new cycle. Context is likely near capacity. |

**Advisory note**: This check uses cycle count as a deterministic proxy — the AI cannot precisely measure its own context usage. The cycle 4+ threshold is conservative and based on empirical session data (~5 cycles was the observed maximum before degradation).

## Phase 1 — Implementation

1. **Read context** — Read the plan file and the resolved progress file to understand the step spec, dependencies, and what's already done.
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 2`

**TDD mode** (default):

2. **Write tests first** — Write unit tests that encode the step's acceptance criteria. Tests should fail initially (red phase).
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 3`

3. **Implement** — Write production code following CLAUDE.md code style:
   - Type hints on all functions (mypy strict)
   - Dataclasses for data structures
   - Async/await for I/O operations
   - Early returns over nested conditions
   - Files under ~500 LOC
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 4`

**Gate mode**:

2. **Verify test coverage** — Check that tests exist for the step's acceptance criteria. Add missing tests for any uncovered criteria.
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 3`

3. **Implement or modify** — Write or update production code following CLAUDE.md code style.
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 4`

**Both modes**:

4. **Validate** — Run the resolved validation command. Fix failures.
   - Max 3 fix-validate attempts. If still failing after 3 rounds, STOP and report to user with the remaining errors.
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh phase 2 self-audit 5`

## Phase 2 — Self-Audit

5. **Spawn review sub-agent** — Use the Task tool to launch a sub-agent that:
   - Reads the uncommitted diff (`git diff` + `git diff --cached`)
   - Reviews it against the severity rubric at `~/.claude/skills/audit-loop/references/severity-rubric.md`
   - Reviews it against the scope priorities at `~/.claude/skills/audit-loop/references/review-scope.md`
   - Returns only P0/P1/P2 findings in the output contract format:
     ```
     [P0|P1|P2] <short title>
     - File: <path:line>
     - Risk: <impact>
     - Failure path: <step-by-step trigger>
     - Concrete fix: <specific code change>
     - Validation: <test or check that proves fix>
     ```
   - Returns `No P0/P1/P2 findings.` if clean

6. **Fix findings** — Fix all P0 and P1 findings. Add regression tests for each fix. Re-run the resolved validation command.
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh phase 3 codex-audit 7`

## Phase 3 — Codex CLI Audit

7. **Run Codex audit** — Resolve the prompt using the fallback chain, then run via `codex exec`:
   ```bash
   ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
   # Fallback chain: 1) codex_prompt from state, 2) project-level, 3) user-scope generic
   STATE_PROMPT=$(jq -r '.codex_prompt // ""' "${ROOT}/.claude/audit-loop.local.json" 2>/dev/null)
   if [ -n "$STATE_PROMPT" ] && [ -f "${ROOT}/${STATE_PROMPT}" ]; then
     PROMPT="${ROOT}/${STATE_PROMPT}"
   elif [ -f "${ROOT}/.claude/codex-audit-prompt.md" ]; then
     PROMPT="${ROOT}/.claude/codex-audit-prompt.md"
   else
     PROMPT="$HOME/.claude/skills/audit-loop/references/codex-audit-prompt.md"
   fi
   codex exec --sandbox read-only - < "$PROMPT" 2>&1 | tee /tmp/codex-audit-output.md
   ```
   **Why `codex exec` instead of `codex review`**: `codex review --uncommitted` uses a built-in review prompt that cannot be overridden — `--uncommitted` and `[PROMPT]` are mutually exclusive. `codex exec` with `-` reads our custom audit prompt from stdin as the instruction. The `--sandbox read-only` flag gives Codex filesystem access to read the repo and run `git diff` itself.

   **Prompt resolution order**: (1) `codex_prompt` from config (resolved relative to project root), (2) `${ROOT}/.claude/codex-audit-prompt.md`, (3) `$HOME/.claude/skills/audit-loop/references/codex-audit-prompt.md`. Wait for completion (this may take 1-2 minutes).
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 8`

8. **Triage findings** — Read `/tmp/codex-audit-output.md` and classify each finding:
   - **FIX** — P0/P1 findings: fix immediately with regression tests
   - **DOCUMENT** — P2 findings or valid concerns that don't need immediate fixing: note in handover doc
   - **DISMISS** — False positives, style nits, or below-threshold: ignore

   **Skip rule**: If zero FIX findings after triage, skip steps 9-10 and go directly to Phase 4:
   ```bash
   ~/.claude/skills/audit-loop/hooks/update-state.sh phase 4 commit-document 11
   ```
   - **State** (if FIX findings exist): `~/.claude/skills/audit-loop/hooks/update-state.sh step 9`

9. **Fix and re-validate** (only if FIX findings exist from step 8) — Fix all FIX-classified findings. Add regression tests. Run the resolved validation command.
   - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh step 10`

10. **Re-audit if needed** (only if FIX findings exist from step 8) — If any P0 findings were fixed in step 9:
    - Run Codex audit once more (same prompt resolution as step 7):
      ```bash
      ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
      STATE_PROMPT=$(jq -r '.codex_prompt // ""' "${ROOT}/.claude/audit-loop.local.json" 2>/dev/null)
      if [ -n "$STATE_PROMPT" ] && [ -f "${ROOT}/${STATE_PROMPT}" ]; then
        PROMPT="${ROOT}/${STATE_PROMPT}"
      elif [ -f "${ROOT}/.claude/codex-audit-prompt.md" ]; then
        PROMPT="${ROOT}/.claude/codex-audit-prompt.md"
      else
        PROMPT="$HOME/.claude/skills/audit-loop/references/codex-audit-prompt.md"
      fi
      codex exec --sandbox read-only - < "$PROMPT" 2>&1 | tee /tmp/codex-audit-round2.md
      ```
    - If P0s persist after round 2: **STOP** and report to user with full findings
    - If clean or only P2s remain: proceed to Phase 4
    - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh phase 4 commit-document 11`

## Phase 4 — Commit & Document

11. **Git commit** — Stage specific files (no `git add -A`). Use conventional commit format:
    ```
    feat|fix|refactor|test: <description>

    <body with what changed and why>

    Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
    ```

12. **Update progress** — Update the resolved progress file with:
    - Checkbox entry for the completed step
    - Test count from validation output
    - Audit results table (if findings were found and fixed):
      ```
      | # | Finding | Severity | Fix |
      |---|---------|----------|-----|
      | 1 | <title> | P0/P1/P2 | <what was done> |
      ```
    - Date stamp

13. **Write handover doc** (conditional) — Write a full handover doc only on **session-final cycle** (last step before ending) or **escalation** (stuck/failure). When continuing to the next plan step in the same session, skip the full handover — the progress update from step 12 is sufficient.

    When writing the full handover, use the template at `~/.claude/skills/audit-loop/references/handover-template.md`. Include:
    - What was implemented (files, key decisions)
    - Audit findings and fixes (self-audit + Codex)
    - Validation state (test count, linter, type checker)
    - Files changed (tracked and untracked)
    - **State**: `~/.claude/skills/audit-loop/hooks/update-state.sh phase 5 summary-banner 14`

## Phase 5 — Summary Banner

14. **Print workflow banner** — After completing all phases (or on escalation/failure), output an ASCII workflow summary. Replace `<step name>` with the actual plan step name, mark each stage with its outcome, and fill in the stats line with real values from the session.

**On success:**
```
══════════════════════════════════════════════════════════════════════════════
  AUDIT LOOP ─ <step name>
══════════════════════════════════════════════════════════════════════════════

  READ ──▶ TESTS ──▶ IMPLEMENT ──▶ VALIDATE ──▶ SELF-AUDIT ──▶ CODEX ──▶ COMMIT
   ✓        ✓          ✓             ✓            <result>      <result>   done

  Tests: <n> pass  |  Findings: <n> fixed  |  <commit message>
══════════════════════════════════════════════════════════════════════════════
```

**On failure/escalation:**
```
══════════════════════════════════════════════════════════════════════════════
  AUDIT LOOP ─ <step name>
══════════════════════════════════════════════════════════════════════════════

  READ ──▶ TESTS ──▶ IMPLEMENT ──▶ VALIDATE ──▶ SELF-AUDIT ──▶ CODEX ──▶ COMMIT
   ✓        ✓          ✓             ✗ STUCK      ·             ·         ·

  BLOCKED: <reason>  |  See output above
══════════════════════════════════════════════════════════════════════════════
```

Mark completed stages with `✓`, the failed stage with `✗ <reason>`, unreached stages with `·`, and skipped stages (e.g., steps 9-10 when no FIX findings) with `–`.
   - **Cleanup**: `~/.claude/skills/audit-loop/hooks/update-state.sh cleanup`

## Escalation Rules

- **Phase 1 stuck**: After 3 failed validation rounds, stop and report errors to user
- **Phase 3 P0 persists**: After 2 Codex audit rounds with P0s, stop and report full findings to user
- **Ambiguous spec**: If the step spec is unclear, ask the user before implementing (don't guess)

## Completion Verification

Before marking ANY phase or step complete:
1. Run the verification command (the resolved validation command, Codex audit)
2. Read the FULL output — do not summarize or skip
3. Confirm the output matches expectations

Forbidden claims without evidence:
- "should work now" — show that it works
- "looks correct" — prove it's correct with test output
- "probably fixed" — run the test that was failing
- "tests pass" — paste the test output

## Resources

- Severity rubric: `~/.claude/skills/audit-loop/references/severity-rubric.md`
- Review scope: `~/.claude/skills/audit-loop/references/review-scope.md`
- Codex prompt: `~/.claude/skills/audit-loop/references/codex-audit-prompt.md`
- Handover template: `~/.claude/skills/audit-loop/references/handover-template.md`
- Progress tracker: the resolved progress file (default: `memory-bank/progress.md`)

## Cancellation

To cancel an active audit loop, the user says "cancel the audit loop" or similar:

```bash
~/.claude/skills/audit-loop/hooks/update-state.sh cancel
```

This sets the cancelled flag (race safety), reports the current phase/step, and deletes the state file.
