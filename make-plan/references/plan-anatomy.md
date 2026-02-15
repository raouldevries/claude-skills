# Plan Anatomy Reference

Section-by-section guide for writing implementation plans. Each section documents purpose, inclusion criteria, format, and a concise example.

---

## 1. Title & Metadata

**Purpose:** Identify the plan and track its lifecycle.

**When:** Always.

**Format:**

```markdown
# Plan: Title Here

> One-line subtitle describing the goal

| Field   | Value |
|---------|-------|
| Created | 2026-02-15 |
| Status  | Planning |
| Target  | What success looks like |
```

**Status values:** Planning → In Progress → Completed / Abandoned

---

## 2. Skills & Tools

**Purpose:** Declare which skills apply to this plan so every step can reference them. Ensures consistent quality gates across all steps.

**When:** Always. The three default skills are pre-filled; project skills are added during Discovery.

**Format:**

Three sub-sections:

1. **Default Skills** — table with Skill and Role columns. Always includes `/audit-loop`, `/handover`, `/code-reviewer`.
2. **Project Skills** — additional skills discovered during codebase exploration. Common additions:
   - `/frontend-design` — when plan involves UI work
   - `/webapp-testing` — when plan needs browser-level verification
   - `/doc-coauthoring` — when plan includes documentation deliverables
3. **Audit References** — table of project-specific review standards (code style guides, linting configs, CLAUDE.md rules) that `/code-reviewer` should check against.

**Skill selection during Discovery:**
- Scan the project's `.claude/` directory and CLAUDE.md for skill references
- Check if the project has a `memory-bank/` with skill-specific docs
- Match plan scope to available skills (UI changes → `/frontend-design`, etc.)

---

## 3. Implementation Workflow

**Purpose:** Visual reference for how each step should be executed. Embeds skill references so implementers know exactly which tools to use.

**When:** Always. The ASCII flowchart is a stable pattern — customize the `<!-- slot: ... -->` markers with actual skill names.

**Format:** Three sub-sections:

### 3a. Per-Step Flowchart

ASCII box diagram with 5 stages: READ PLAN → IMPLEMENT → AUDIT → UPDATE PROGRESS → ASK FOR CONFIRMATION. Each box can reference specific skills.

**Customizing slots:**
- IMPLEMENT box: Replace slot with actual skills. Example for UI work:
  ```
  │  2. IMPLEMENT                                               │
  │     - Use `/frontend-design` for component creation         │
  │     - Use `/audit-loop` Phase 1 (test-first)               │
  ```
- AUDIT box: Replace slot with project audit references:
  ```
  │  3. AUDIT                                                   │
  │     - `/code-reviewer` against `.ruff.toml`, `CLAUDE.md`   │
  │     - `/webapp-testing` for browser verification            │
  ```

### 3b. Audit Files Reference

Table listing project-specific files that `/code-reviewer` should check against. Populated during Discovery.

### 3c. Quality Gates

Checkbox list of gates that must pass before a step is considered complete. Defaults pre-filled; add project-specific gates.

---

## 4. Context / Analysis

**Purpose:** Ground the plan in the current state of the codebase. Prevents hallucinated APIs and informs step scoping.

**When:** Always.

**Format:** Three H3 sub-sections:

```markdown
### Current State
Summary of relevant codebase state, architecture, existing patterns.

### Key Patterns Found
APIs, utilities, conventions to reuse. Include file paths.

### Critical Gaps
What's missing, broken, or needs changing.
```

**Example snippet:**
```markdown
### Key Patterns Found
- Auth middleware at `src/middleware/auth.ts` uses JWT with 24h expiry
- All API routes follow `src/routes/{resource}.ts` convention
- Existing tests use vitest with `src/__tests__/{resource}.test.ts` pattern
```

---

## 5. Phase / Step Structure

**Purpose:** Break the plan into independently executable units. Each step maps to one `/audit-loop` cycle.

**When:** Always. This is the core of every plan.

**Format:**

```markdown
## Phase N: Phase Title

### Step N.M: Step Title

**Complexity:** S | M | L

**Acceptance criteria:**
- [ ] Concrete, testable criterion
- [ ] Another criterion

**Sub-steps:**
a. First action
b. Second action
c. Third action

**Files:**
- `src/path/to/file.ts`
- `src/path/to/test.ts`

**Dependencies:** Step X.Y, Step X.Z (or "None")
```

**Complexity guide:**
- **S** — Single file, <50 LOC change, straightforward
- **M** — 2-4 files, requires some design thought, ~50-200 LOC
- **L** — 5+ files, architectural decisions, >200 LOC, consider splitting

**Rules:**
- Steps must be independently executable (self-contained scope + clear acceptance criteria)
- Acceptance criteria must be encodable as tests (for `/audit-loop` compatibility)
- Sub-steps use lettered lists (a, b, c), not numbered (to avoid confusion with step numbers)
- File paths always in backticks
- Dependencies reference other steps by `Step X.Y` format

---

## 6. Risk Areas & Recommendations

**Purpose:** Surface known risks before implementation begins. Helps prioritize and plan mitigation.

**When:** Always for plans with 3+ phases. Optional for smaller plans.

**Format:**

```markdown
| Component | Issue | Recommendation |
|-----------|-------|----------------|
| Auth module | Token refresh race condition | Add mutex lock around refresh |
| DB migration | Large table ALTER | Run during maintenance window |

### Breaking Changes
- API response shape changes in `/api/users` endpoint

### Testing Recommendations
- Load test the token refresh under concurrent requests

### Quick Wins
- Add missing index on `users.email` (5 min, improves query by 10x)
```

---

## 7. Progress Tracking

**Purpose:** Mirror the phase/step structure as a trackable checklist. Updated as steps complete.

**When:** Always.

**Format:**

```markdown
## Progress Tracking

### Phase 1: Phase Title
- [x] Step 1.1: Step title _(completed 2026-02-15)_
- [ ] Step 1.2: Next step title

### Phase 2: Phase Title
- [ ] Step 2.1: Step title
```

**Rules:**
- Must exactly mirror the Phase/Step structure (same titles, same order)
- Date format: `_(completed YYYY-MM-DD)_` in italics after the title
- Check boxes as steps complete: `- [ ]` → `- [x]`

---

## 8. Database Schema / Model Changes (Conditional)

**Purpose:** Document data model changes when the plan affects database structure.

**When:** Plan involves creating/modifying tables, columns, relationships, or migrations.

**Format:**

```markdown
## Database Changes

### New Tables
| Table | Columns | Purpose |
|-------|---------|---------|
| `user_preferences` | `id, user_id, key, value, created_at` | Store user settings |

### Modified Tables
| Table | Change | Migration |
|-------|--------|-----------|
| `users` | Add `last_login_at` column | `ALTER TABLE users ADD COLUMN...` |
```

---

## 9. API Endpoints / Public Interface (Conditional)

**Purpose:** Document new or modified public interfaces.

**When:** Plan adds or changes API endpoints, CLI commands, or public module interfaces.

**Format:**

```markdown
## API Endpoints

### New Endpoints
| Method | Path | Request | Response | Auth |
|--------|------|---------|----------|------|
| POST | `/api/users` | `{ name, email }` | `{ id, name, email }` | Bearer |

### Modified Endpoints
| Endpoint | Change | Breaking? |
|----------|--------|-----------|
| `GET /api/users` | Add `?role=` filter | No |
```

---

## 10. Code Examples & Patterns (Conditional)

**Purpose:** Show concrete code patterns when the plan introduces new conventions.

**When:** Plan introduces a new pattern that multiple steps will follow (e.g., new error handling, new component structure).

**Format:** Fenced code blocks with language tags. Keep examples minimal — show the pattern, not the full implementation.

---

## 11. Table of Contents (Conditional)

**Purpose:** Navigation aid for large plans.

**When:** Plan has 5+ phases.

**Format:** Markdown links to each phase heading, placed after the metadata block.

---

## Formatting Conventions

| Element | Convention |
|---------|-----------|
| File paths | Backticks: `` `src/module/file.py` `` |
| Code blocks | Fenced with language tag |
| Status indicators | ✅ Complete, 🔵 In Progress, ⚠️ Risk |
| Sub-steps | Lettered: a, b, c |
| Step references | `Step X.Y` format |
| Dates | `_(completed YYYY-MM-DD)_` in italics |
| Phase headings | `## Phase N: Title` |
| Step headings | `### Step N.M: Title` |
| Checkboxes | `- [ ]` unchecked, `- [x]` checked |
