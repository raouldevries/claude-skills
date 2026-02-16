---
name: make-plan
description: Create structured implementation plans with phased breakdowns, acceptance criteria, quality gates, and progress tracking. Use when starting multi-step projects, refactoring efforts, feature implementations, security audits, or any work spanning multiple files or sessions. Also use when the user asks to "make a plan", "create a plan", "write an implementation plan", or similar planning requests.
---

# Make Plan

Create a structured plan file following a proven anatomy: metadata, skills & tools, workflow diagram, phased steps with acceptance criteria, risk areas, and progress tracking. Plans are designed so each step can be consumed by `/audit-loop` as an independent implement-audit-fix cycle.

## Workflow

Four sequential phases:

1. **Discover** — Explore the codebase, gather context, identify patterns and constraints
2. **Structure** — Determine phases, steps, dependencies, and which optional sections to include
3. **Write** — Generate the plan file using the template and formatting guide
4. **Review** — Present plan to user, iterate on feedback

---

## Phase 1: Discover

### Scaffold the plan file

Run the init script to create a plan file with metadata pre-filled:

```bash
python3 skills/make-plan/scripts/init-plan.py "<Plan Title>" --target "<goal>"
```

Optional `--path` flag to specify output directory. Defaults to: `memory-bank/plans/` → `.claude/plans/` → `~/.claude/plans/`.

### Explore the codebase

Deploy Explore subagents for fact-gathering. Follow the protocol in `references/discovery-protocol.md`:

- Search for documentation, README, CLAUDE.md instructions
- Map existing code patterns, architecture, and test infrastructure
- Find related past plans to learn from
- Scan `.claude/skills/` for project-applicable skills

**Subagent reporting contract** — Each subagent must report: sources consulted, concrete findings (exact paths/signatures), copy-ready snippet locations, confidence notes + gaps. Reject reports without source citations.

### Consolidate findings

As orchestrator, synthesize subagent reports into:
- **Allowed APIs / Existing Patterns** list with file path citations
- **Anti-patterns to avoid** (methods that don't exist, deprecated params)
- **Reusable code map** (existing code that steps can reference)
- **Applicable skills** for the plan's Skills & Tools section

---

## Phase 2: Structure

Determine plan shape based on scope:

- **Number of phases** — Group related steps. Typical: 2-5 phases for medium projects, up to 8 for large ones.
- **Steps per phase** — Break into independently executable units (Step X.Y format). Each step = one `/audit-loop` cycle.
- **Complexity per step** — Assign S/M/L. If a step is L, consider splitting.
- **Dependencies** — Map which steps depend on others.
- **Optional sections** — Include Database Schema, API Endpoints, Code Examples only when relevant.

Decision guide for optional sections (see `references/plan-anatomy.md` for full details):
- Data model changes → include Database Schema section
- New endpoints or public APIs → include API Endpoints section
- New patterns that multiple steps follow → include Code Examples section
- 5+ phases → include Table of Contents
- 3+ phases → include Risk Areas section (always recommended)

---

## Phase 3: Write

Fill in the scaffolded plan file. Reference `references/plan-anatomy.md` for section-specific formatting.

### Populate Skills & Tools

Always include the three default skills:

| Skill | Role in Plan |
|-------|-------------|
| `/audit-loop` | Each step maps to one audit-loop cycle: test-first → implement → self-audit → codex audit → commit. Steps must have acceptance criteria encodable as tests. |
| `/handover` | Use at session boundaries. Progress tracking format is compatible with handover's progress updates. |
| `/code-reviewer` | Quality gate before commits. Embed in the workflow diagram's AUDIT step. |

Add project-specific skills discovered in Phase 1. Common additions:
- `/frontend-design` — UI component work
- `/webapp-testing` — browser-level verification
- `/doc-coauthoring` — documentation deliverables

Populate the **Audit References** table with project-specific review standards (linting configs, CLAUDE.md code style rules, code review guides).

### Customize the workflow diagram

The template's ASCII flowchart has `<!-- slot: ... -->` markers. Replace them with actual skills:

**IMPLEMENT step** — Default is `/audit-loop` Phase 1. For UI work, add `/frontend-design`:
```
│  2. IMPLEMENT                                               │
│     - Use `/frontend-design` for component creation         │
│     - Use `/audit-loop` Phase 1 (test-first)               │
```

**AUDIT step** — Reference the audit files from the Skills & Tools table:
```
│  3. AUDIT                                                   │
│     - `/code-reviewer` against `.ruff.toml`, `CLAUDE.md`   │
│     - `/webapp-testing` for browser verification            │
```

Update quality gates to match the skills listed.

### Write Phase/Step content

For each step, include all required fields:

- **Acceptance criteria** — Checkbox list. Must be testable (for `/audit-loop` compatibility).
- **Sub-steps** — Lettered list (a, b, c). Concrete actions, not vague goals.
- **Files** — Backtick-wrapped paths to create or modify.
- **Dependencies** — References to other steps, or "None".
- **Complexity** — S, M, or L.

Frame tasks as copy-based: "Follow the pattern in `src/routes/users.ts`" not "Migrate existing code."

### Fill Context section

Use the consolidated findings from Phase 1:
- **Current State** — Codebase state relevant to the plan
- **Key Patterns Found** — APIs, utilities, conventions to reuse (with file paths)
- **Critical Gaps** — What's missing or needs to change

### Complete Progress Tracking

Must exactly mirror the Phase/Step structure. Same titles, same order:

```markdown
### Phase 1: Phase Title
- [ ] Step 1.1: Step title
- [ ] Step 1.2: Step title

### Phase 2: Phase Title
- [ ] Step 2.1: Step title
```

Date entries get added during implementation: `_(completed YYYY-MM-DD)_`

---

## Phase 4: Review

1. Present the plan to the user
2. Call out any assumptions or decisions that need confirmation
3. Iterate based on feedback — adjust scope, reorder steps, add/remove sections
4. Confirm the plan is approved before implementation begins

---

## Resources

- **Template:** `assets/plan-template.md` — skeleton with all standard sections
- **Section guide:** `references/plan-anatomy.md` — format specs and examples for every section
- **Discovery protocol:** `references/discovery-protocol.md` — subagent exploration and reporting rules
- **Init script:** `scripts/init-plan.py` — scaffolds a new plan file with metadata pre-filled
