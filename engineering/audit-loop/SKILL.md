---
name: audit-loop
description: >
  Automated implement-audit-fix workflow for a single plan step.
  Writes tests first, implements code, self-audits the diff, runs Codex CLI
  audit, fixes findings, commits, updates progress, and writes a handover doc.
  Language-agnostic — works with any repo that has a validation command.
---

# Audit-Loop Skill

> Implements one plan step end-to-end with built-in quality gates.

---

## Project Detection (run once at skill start)

Detect the project's validation command using the first match:

1. **CLAUDE.md** — look for an explicit validate / check / lint command
2. **Makefile / justfile** — `make validate` or `just validate` (fall back to `make check` / `just check`)
3. **package.json** — `npm test` (or `yarn test` / `pnpm test` based on lockfile)
4. **Cargo.toml** — `cargo clippy --all-targets && cargo test`
5. **go.mod** — `go vet ./... && go test ./...`
6. **pyproject.toml / setup.cfg** — `python -m pytest` (add `mypy .` / `ruff check .` if configured)
7. **build.gradle / pom.xml** — `./gradlew check` / `mvn verify`
8. **None found** — ask the user: *"No validation command detected. What command should I run?"*

Store the result as **`VALIDATE_CMD`** for all subsequent phases.

**Monorepo note:** If the current working directory is a package inside a monorepo, prefer the package-level config first, then fall back to root-level.

---

## Activation (optional)

The skill includes hook scripts for state tracking and cancellation support.
Before starting Phase 1, create the state file:

```bash
<skill-dir>/hooks/update-state.sh init "<step_name>"
```

This enables:
- Stop-hook enforcement (prevents skipping phases)
- Cancellation via `<skill-dir>/hooks/update-state.sh cancel`
- State tracking between phases

Note: Ensure `.claude/audit-loop.local.*` is excluded from version control.

---

## Phase 1 — Test-First Implementation

### Steps

1. **Read context**
   - Read the plan file / task description.
   - Auto-detect a progress tracker: check CLAUDE.md for a reference → look for
     common paths (`memory-bank/progress.md`, `PROGRESS.md`, `TODO.md`) → skip
     silently if none found.

2. **Write tests first** *(conditional)*
   - If the repo has test infrastructure (test runner configured, existing test
     files), write failing tests that cover the planned behaviour (red phase).
   - If the repo has **no** test infrastructure, skip and note in the handover:
     *"Tests skipped — no test framework detected."*

3. **Implement**
   - Follow the repo's **CLAUDE.md** or linter config for style.
   - General principles when no style guide exists:
     - Explicit types / type annotations where the language supports them
     - Small, focused functions
     - Early returns over deep nesting
     - Files under ~500 LOC
   - Make tests pass (green phase).

4. **Validate**
   - Run `VALIDATE_CMD`.
   - On failure → fix → re-run (max **3 rounds**).
   - After 3 failures → **stop and report** the remaining errors to the user.

### Progress banner after Phase 1

```
┌─────────────────────────────────────────────┐
│  AUDIT-LOOP  ·  Phase 1 complete            │
│  Tests: <pass_count>  ·  Validate: ✓        │
└─────────────────────────────────────────────┘
```

---

## Phase 2 — Self-Audit

1. **Spawn a review sub-agent** with this prompt context:
   - The uncommitted diff (`git diff` + `git diff --cached`)
   - The severity rubric at **`references/severity-rubric.md`** (relative to this skill's directory)
   - The repo's **CLAUDE.md** (if present) for domain-specific rules

2. The sub-agent reviews the diff and returns **only P0 / P1 / P2 findings** in
   this format:

   ```
   [P0|P1|P2] <short title>
   - File: <path:line>
   - Risk: <impact description>
   - Failure path: <step-by-step trigger>
   - Concrete fix: <specific code or design change>
   - Validation: <test or check that proves the fix>
   ```

3. **Fix all P0 and P1 findings.** Add regression tests for each fix.

4. **Document P2 findings** in the handover (do not block on them).

5. Re-run `VALIDATE_CMD` after fixes.

---

## Phase 3 — Codex CLI Audit

> This phase requires the [Codex CLI](https://github.com/openai/codex).

### Pre-flight

```bash
if ! command -v codex &>/dev/null; then
  echo "✘ Codex CLI not found. Install it: npm install -g @openai/codex"
  echo "  → https://github.com/openai/codex"
  # STOP — do not continue without Codex
fi
```

If Codex is not on PATH, **stop and tell the user to install it.** The external
audit is the core quality gate of this skill.

### Prompt Resolution

Resolve the audit prompt before running Codex. A project-level prompt provides
domain-specific focus areas; the generic prompt covers universal concerns.

```bash
PROMPT="${PWD}/.claude/codex-audit-prompt.md"
[ ! -f "$PROMPT" ] && PROMPT="<skill-dir>/references/codex-audit-prompt.md"
```

Where `<skill-dir>` is the directory containing this SKILL.md.

**To customize for a specific project:** add `.claude/codex-audit-prompt.md` to
the repo root. Use `references/codex-audit-prompt.md` as a starting template
and replace the focus areas with domain-specific concerns.

### Audit

1. Run:
   ```bash
   codex review --uncommitted - < "$PROMPT" 2>&1 | tee /tmp/codex-audit-output.md
   ```
   The `-` flag tells Codex to read the review prompt from stdin. Codex outputs
   findings in P0/P1/P2 format matching Phase 2.

2. **Triage** each finding:
   | Action       | Criteria |
   |-------------|----------|
   | **FIX**      | P0 or P1 per the severity rubric |
   | **DOCUMENT** | P2 — add to handover |
   | **DISMISS**  | False positive or already addressed — note reason |

3. Fix P0/P1 findings, re-run `VALIDATE_CMD`.

4. If any **P0 was fixed**, re-run the Codex audit (max **2 rounds** total).
   After 2 rounds with remaining P0s → **stop and report** to the user.

---

## Phase 4 — Commit & Document

### 4a. Commit

- Stage changed files and commit using **Conventional Commits** format:
  ```
  feat(<scope>): <description>

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```
- Scope = affected module or area. Use `fix`, `refactor`, `test`, etc. as
  appropriate.

### 4b. Update progress tracker *(if detected in Phase 1)*

- Mark the current step complete (checkbox, status update, etc.)
- Append: test count, audit results summary, date.

### 4c. Write handover document

Use the template at **`references/handover-template.md`** (relative to this
skill's directory). Include:
- Implementation summary and files changed
- All audit findings (fixed and documented)
- Key design decisions
- Validation state

---

## Phase 5 — Summary Banner

```
┌──────────────────────────────────────────────────────────────┐
│  AUDIT-LOOP COMPLETE                                         │
│                                                              │
│  IMPLEMENT ── SELF-AUDIT ── CODEX ── COMMIT ── HANDOVER     │
│      ✓            ✓         <s>       ✓          ✓          │
│                                                              │
│  Tests: <N>  ·  P0 fixed: <n>  ·  P1 fixed: <n>             │
│  P2 documented: <n>  ·  Dismissed: <n>                       │
│  Commit: <short-sha> <message>                               │
└──────────────────────────────────────────────────────────────┘
```

Where `<s>` in the CODEX column is:
- `✓` — Codex ran and passed (no findings)
- `!` — Codex ran, findings were fixed

---

## Escalation Rules

| Situation | Action |
|-----------|--------|
| `VALIDATE_CMD` fails 3× in Phase 1 | **Stop.** Report errors to the user. |
| P0 persists after 2 Codex audit rounds | **Stop.** Report the finding to the user. |
| Ambiguous spec / unclear requirement | **Ask** the user before implementing. |
| No test infrastructure in repo | Skip tests, note in handover. Continue. |
| No progress tracker found | Skip progress update silently. Continue. |
| Codex CLI not installed | **Stop.** Tell the user to install Codex. |

---

## Cancellation

To cancel an active audit loop:

```bash
<skill-dir>/hooks/update-state.sh cancel
```

This sets the cancelled flag, reports the current phase/step, and cleans up the state file.

---

## Resource References

| Resource | Path |
|----------|------|
| Severity rubric | `references/severity-rubric.md` |
| Codex audit prompt (generic) | `references/codex-audit-prompt.md` |
| Handover template | `references/handover-template.md` |
| Hook: state tracking | `hooks/update-state.sh` |
| Hook: stop enforcement | `hooks/stop-hook.sh` |
| Project-specific prompt (optional) | `.claude/codex-audit-prompt.md` in repo root |
