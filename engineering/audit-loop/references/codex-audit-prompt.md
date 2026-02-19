Review the uncommitted changes in this codebase. Report only P0/P1/P2 production-impacting defects. Ignore style, naming, and formatting.

## Focus Areas

### Correctness
- Logic errors, off-by-one, wrong operator, inverted conditions
- Incorrect return values or missing returns on error paths
- Type mismatches, implicit conversions, or unsafe casts
- Broken contracts between callers and callees

### Security
- Injection vulnerabilities (SQL, command, XSS, path traversal)
- Authentication and authorization gaps or bypasses
- Secrets, credentials, or tokens exposed in code or logs
- Unsafe deserialization, unvalidated redirects, SSRF

### Error Handling & Edge Cases
- Unhandled exceptions that crash or corrupt state
- Missing validation at system boundaries (user input, external APIs, file I/O)
- Resource leaks (connections, file handles, locks not released on error)
- Silent failures that mask real errors

### Concurrency & Data Races
- Shared mutable state accessed without synchronization
- Race conditions between concurrent operations
- Deadlock potential from lock ordering violations
- Non-atomic operations that should be atomic

### Data Integrity & State Management
- State mutations that can leave the system in an inconsistent state
- Missing or incorrect transaction boundaries
- Cache invalidation gaps
- Persistence and recovery correctness after crash or restart

## Severity Definitions

**P0** — Can directly cause critical failure, data loss, or security compromise with little friction.
Examples: auth bypass, data corruption, unhandled crash in critical path, injection vulnerability.

**P1** — Can realistically cause major impact under common failure conditions.
Examples: resource leaks under load, race conditions in normal operation, missing error handling on likely failure paths.

**P2** — Meaningful production impact but needs specific timing or compounded conditions.
Examples: edge-case race conditions, incomplete validation in uncommon paths, non-critical recovery gaps.

## Output Format

For each finding:
```
[P0|P1|P2] <short title>
- File: <path:line>
- Risk: <impact description>
- Failure path: <step-by-step trigger>
- Concrete fix: <specific code or design change>
- Validation: <test or check that proves fix>
```

If no qualifying issue exists, respond with: `No P0/P1/P2 findings.`

Do not report style issues, naming conventions, documentation gaps, or hypothetical risks without a concrete trigger path.
