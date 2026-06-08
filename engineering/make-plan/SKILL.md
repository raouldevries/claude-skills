---
name: make-plan
description: Create structured implementation plans with phased breakdowns, acceptance criteria, quality gates, and progress tracking. Creates the plan file that precedes execution; each step maps to one audit-loop cycle. Use when starting multi-step projects, refactoring efforts, feature implementations, a multi-step security-hardening effort, or non-trivial work spanning multiple files or sessions. Also use when the user asks to "make a plan", "create a plan", "write an implementation plan", or similar planning requests.
---

# Make Plan

Create a structured plan file following a proven anatomy: metadata, skills & tools, workflow diagram, phased steps with acceptance criteria, risk areas, and progress tracking. Each step is designed to be consumed by `/audit-loop` as one independent implement-audit-fix cycle.

## When to plan

Use make-plan for multi-file, multi-session, or multi-phase work. If you could describe the diff in one sentence and finish it in a single session, skip the plan and implement directly. Planning a trivial task adds review overhead without payoff.

## Effort

Run discovery and exploration at `xhigh` effort. Write the plan at `high` as a floor. Avoid `max`, which tends to overthink a planning task. Effort was recalibrated in Opus 4.8, so a setting tuned on an earlier model no longer maps directly.

## Workflow

Four phases. Only one ordering is load-bearing: finish read-only discovery before you write. Treat the rest as goals, not a script.

1. **Discover** — Explore the codebase, gather context, identify patterns and constraints
2. **Structure** — Resolve open scope questions, then decide phases, steps, dependencies, and which optional sections to include
3. **Write** — Generate the plan file using the template and the anatomy reference
4. **Review** — Present the plan to the user, iterate on feedback

---

## Discipline

| Rationalization | Reality |
|---|---|
| "I already know this codebase" | Codebases drift between sessions. Run discovery before writing, even on familiar code. |
| "The step is self-explanatory, no acceptance criteria needed" | If you can't write a testable acceptance criterion, the step is underspecified. Split it. |
| "One large step is simpler than several small ones" | Large steps fail audit-loops. Each step must fit one audit-loop cycle. |
| "I'll add the file paths later" | File paths now. Vague plans produce wrong implementations. |

## Phase 1: Discover

### Scaffold the plan file

Run the init script. Use the absolute path so it works from any project directory:

```bash
python3 ~/.claude/skills/make-plan/scripts/init-plan.py "<Plan Title>" --target "<goal>"
```

Optional `--path` flag to specify the output directory. Defaults to: `.claude/plans/` → `~/.claude/plans/` (pass `--path` for another location, e.g. `memory-bank/plans/`).

### Explore the codebase

For a multi-area or unfamiliar codebase, delegate fact-gathering to Explore subagents (cap ~3) following `references/discovery-protocol.md`. For a focused, single-area plan, read the relevant files directly. Either way, complete discovery before writing.

Search for:

- Documentation, README, CLAUDE.md instructions
- Existing code patterns, architecture, and test infrastructure
- Related past plans to learn from
- Project-applicable skills in `.claude/skills/`

The subagent reporting contract (sources actually read, exact paths/signatures, copy-ready snippet locations, confidence notes + gaps; reject reports without citations) is defined in `references/discovery-protocol.md`.

### Consolidate findings

As orchestrator, synthesize subagent reports into:

- **Allowed APIs / Existing Patterns** list with file path citations
- **Anti-patterns to avoid** (methods that don't exist, deprecated params)
- **Reusable code map** (existing code that steps can reference)
- **Applicable skills** for the plan's Skills & Tools section

---

## Phase 2: Structure

**Resolve scope first.** If discovery surfaced unresolved scope questions (ambiguous requirements, unstated constraints, competing approaches), batch up to 3-5 of them to the user and get answers before writing. Skip this when scope is unambiguous or the change is small. Resolving one wrong assumption now is cheaper than unwinding it from a finished plan.

Then decide plan shape:

- **Number of phases** — Group related steps. Typical: 2-5 phases for medium projects, up to 8 for large ones.
- **Steps per phase** — Break into independently executable units (Step X.Y format). Each step = one `/audit-loop` cycle.
- **Complexity per step** — Assign S/M/L. If a step is L, consider splitting.
- **Dependencies** — Map which steps depend on others.
- **Optional sections** — Include Database Schema, API Endpoints, Code Examples, Table of Contents, and Risk Areas per the inclusion criteria in `references/plan-anatomy.md`.

---

## Phase 3: Write

Fill in the scaffolded plan file. Reference `references/plan-anatomy.md` for section-by-section format; the template marks every slot. A few standing rules the reference assumes:

- **Skills & Tools** — This set pairs `/audit-loop` (test-first implement, self-audit, Codex audit, commit) with `/handover` (session boundaries). The code-review gate is built into audit-loop's self-audit and Codex audit phases; add your project's standalone review skill under Project Skills if you use one. Fall back to plain TDD + commit when a skill is absent. Populate **Audit References** with project-specific review standards (linting configs, CLAUDE.md rules, code review guides).
- **Workflow diagram** — The template's ASCII flowchart has `<!-- slot: ... -->` markers. Replace them with the actual skills (for example `/frontend-design` in IMPLEMENT, `/webapp-testing` in AUDIT) and update the quality gates to match.
- **Steps** — Each must be independently executable with testable acceptance criteria (audit-loop compatibility). Use lettered sub-steps (a, b, c). Backtick all file paths. Frame tasks as copy-based ("Follow the pattern in `src/routes/users.ts`"), not "migrate the existing code."
- **Context section** — Fill from the consolidated discovery findings: Current State, Key Patterns Found (with file paths), Critical Gaps.
- **Progress Tracking** — Must mirror the Phase/Step structure exactly: same titles, same order. Date entries get added during implementation: `_(completed YYYY-MM-DD)_`.
- **Final Verification** — Close the plan with a Final Verification step: full suite/build/smoke plus a coverage check mapping every acceptance criterion to a passing check, before Status flips to Completed. This is the whole-plan gate that the per-step audit-loops do not cover.

---

## Phase 4: Review

1. Before presenting, scan the plan for any remaining `<!-- TODO -->` / `<!-- slot -->` markers and fill or delete them.
2. Present the plan to the user.
3. Call out any remaining assumptions or decisions that need confirmation.
4. Iterate on feedback: adjust scope, reorder steps, add or remove sections.
5. Confirm the plan is approved before implementation begins.

---

## Resources

- **Template:** `assets/plan-template.md` — skeleton with all standard sections
- **Section guide:** `references/plan-anatomy.md` — format specs and examples for every section
- **Discovery protocol:** `references/discovery-protocol.md` — subagent exploration and reporting rules
- **Init script:** `scripts/init-plan.py` — scaffolds a new plan file with metadata pre-filled
