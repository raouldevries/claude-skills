Review the implementation plan provided below. Validate each step against the actual codebase. Report only P0/P1/P2 defects that would cause implementation failure, wasted effort, or ambiguity. Ignore formatting, writing style, and cosmetic issues.

You have read-only access to the full repository. Use it to verify file paths, API signatures, architectural patterns, and dependency chains referenced in the plan.

## Focus Areas

### Structural
- Missing phases or steps required to achieve the stated goal
- Impossible step ordering (step N requires output from step M, but M comes after N)
- Circular dependencies between steps
- Steps that should be split (doing two unrelated things) or merged (artificial separation)

### Feasibility
- Steps that reference files, functions, APIs, or patterns that do not exist in the codebase
- Steps that contradict the existing architecture (e.g., assuming a framework feature that isn't configured)
- Steps that assume a dependency or tool is available without verifying
- Acceptance criteria that are impossible to satisfy given the current codebase state

### Specification
- Vague acceptance criteria that could be interpreted multiple ways
- Ambiguous sub-steps where the implementer would have to guess the intent
- Missing file paths for steps that modify or create files
- Missing error handling or edge case coverage in acceptance criteria
- Acceptance criteria that cannot be mechanically verified (no test or check described)

### Scope
- Gaps: functionality the plan should address to achieve its goal but doesn't mention
- Scope creep: steps that go beyond the stated goal without justification
- Missing integration points (the plan changes component A but doesn't update component B which depends on A)

### Dependencies
- Steps that depend on outputs not produced by any prior step
- External dependencies (APIs, services, packages) referenced but not installed or configured
- Ordering that forces unnecessary sequential execution (steps that could be parallelized)

## Severity Definitions

**P0** — Structural flaw that would cause implementation to fail or produce the wrong result.
Examples: step references a nonexistent API (cite the file you checked), circular dependency between steps, missing step that is required for the goal, acceptance criteria that contradict each other.

**P1** — Logic gap that would cause ambiguity or wasted audit-loop cycles during implementation.
Examples: vague acceptance criteria requiring implementer guesswork, step ordering that forces rework, missing file path for a modification step, dependency on an unconfigured tool.

**P2** — Improvement that would make the plan clearer or more efficient but isn't blocking.
Examples: steps that could be parallelized, acceptance criteria that could be more specific, missing but inferrable file paths, minor scope gaps.

## Output Format

For each finding:
```
[P0|P1|P2] <short title>
- Step: <step number and name>
- Issue: <what is wrong>
- Evidence: <see below>
- Impact: <what goes wrong during implementation if this isn't fixed>
- Suggested fix: <concrete change to the plan>
```

IMPORTANT: Every finding MUST include an Evidence field. Use one of two forms:
- **Existence-based** (something exists that contradicts the plan): `Evidence: <file:line> — <what was found>`
- **Absence-based** (plan references something that doesn't exist): `Evidence: Searched <path/pattern>, not found — confirmed absence via <how you checked>`

Both forms are mechanically verifiable. Do not report speculative issues without grounding them in the actual codebase.

If no qualifying issue exists, respond with: `No P0/P1/P2 findings.`

Do not report style issues, formatting preferences, or hypothetical risks without a concrete trigger path grounded in the codebase.

---

## Plan to Review

(The plan document follows the `--- BEGIN PLAN ---` separator in stdin. Context about the codebase precedes it.)
