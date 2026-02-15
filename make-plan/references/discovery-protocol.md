# Discovery Protocol

How to gather context before writing a plan. This is Phase 1 (Discover) of the make-plan workflow.

---

## Delegation Model

Use **subagents for fact-gathering**, keep **synthesis and plan authoring** with the orchestrator.

- Subagents explore docs, grep for patterns, read file signatures
- Orchestrator consolidates findings, decides phase boundaries, writes the plan
- If a subagent report is incomplete or lacks evidence, re-check with targeted reads before finalizing

---

## Subagent Deployment

Deploy Explore subagents to search for:

1. **Documentation & instructions** — README files, CLAUDE.md, `docs/` directories, inline doc comments
2. **Existing code patterns** — Architecture conventions, module structure, naming patterns, error handling
3. **Test infrastructure** — Test runner, test conventions, fixture patterns, coverage setup
4. **Related plan files** — Past plans in `.claude/plans/`, `memory-bank/`, or project `docs/` (learn from previous approaches)
5. **Available skills** — Scan `.claude/skills/` for project-applicable skills to include in the plan's Skills & Tools section

---

## Subagent Reporting Contract

Each subagent response **must** include:

1. **Sources consulted** — Files and URLs actually read (not just searched for)
2. **Concrete findings** — Exact API names, function signatures, file paths, line numbers
3. **Copy-ready snippet locations** — Example files/sections that can be referenced in steps
4. **Confidence note + known gaps** — What might still be missing or unverified

**Reject and redeploy** if a subagent reports conclusions without citing sources.

---

## Orchestrator Consolidation

After subagent reports arrive, the orchestrator creates:

### Allowed APIs / Existing Patterns

List of verified APIs, utilities, and patterns with file path citations:

```markdown
- Auth middleware: `src/middleware/auth.ts:15` — `authenticateUser(req, res, next)`
- DB query helper: `src/db/query.ts:8` — `executeQuery<T>(sql, params): Promise<T[]>`
- Test factory: `tests/factories/user.ts:3` — `createTestUser(overrides?)`
```

### Anti-Patterns to Avoid

Patterns found to not exist or to be deprecated:

```markdown
1. **DO NOT** use `db.rawQuery()` — removed in v2, use `executeQuery()` instead
2. **DO NOT** assume `req.user` exists without auth middleware — crashes with 500
3. **DO NOT** create new utility files in `src/utils/` — project uses co-located helpers
```

### Reusable Code Map

Existing code that steps can reference or extend:

```markdown
| Pattern | Location | Reuse Strategy |
|---------|----------|----------------|
| API route handler | `src/routes/users.ts` | Copy structure for new routes |
| Migration template | `migrations/001_init.sql` | Follow naming and structure |
| Component pattern | `src/components/Card.tsx` | Extend for new components |
```

### Applicable Skills

Skills discovered during exploration that should be listed in the plan's Skills & Tools section:

```markdown
| Skill | Why |
|-------|-----|
| `/frontend-design` | Plan includes 3 UI component steps |
| `/webapp-testing` | Project has Playwright setup in `tests/e2e/` |
```

---

## Anti-Pattern Guards

### Never invent APIs
- Only reference methods confirmed in source code or documentation
- If a method "should" exist but isn't found, flag it as a gap — don't assume

### Never add undocumented parameters
- If a function signature doesn't include a parameter, don't add it in the plan
- Check the actual function definition, not just call sites

### Frame tasks as copy-based
- Good: "Follow the pattern in `src/routes/users.ts` to create `src/routes/orders.ts`"
- Bad: "Migrate the existing code to the new pattern"

### Require documentation citations
- Every external API reference must cite the source (file path, URL, line number)
- "The docs say..." without a citation is insufficient

### Verify before assuming
- Run the test suite to confirm current state before planning changes
- Check git status/log to understand recent changes
- Read CLAUDE.md for project-specific constraints
