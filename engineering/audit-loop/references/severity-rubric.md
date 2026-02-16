# Severity Rubric

Use this rubric to classify findings from code review and audits.

---

## P0 — Critical

**Can directly cause catastrophic impact with little friction.**

A single mistake or omission on a reachable code path leads to severe
consequences without requiring unusual timing or compound failures.

### Examples

- **SQL / command injection** — unsanitized user input in queries or shell commands
- **Authentication / authorization bypass** — missing or broken auth checks on
  protected endpoints
- **Data corruption or loss** — writes that silently overwrite or delete user
  data without safeguards
- **Unbounded resource exhaustion** — no limits on allocation (memory, disk,
  connections) leading to denial of service
- **Secret / credential exposure** — API keys, tokens, or passwords logged,
  returned in responses, or committed to source control

### Action

**Fix immediately.** Add a regression test that proves the vulnerability is
closed.

---

## P1 — High

**Can realistically cause major impact under common failure scenarios.**

Requires a plausible (not exotic) failure — network timeout, concurrent request,
restart during processing — to trigger significant damage.

### Examples

- **Race conditions causing duplicates** — concurrent requests create duplicate
  records or side effects because of missing locking / uniqueness constraints
- **Missing idempotency on retries** — retried operations (network errors, queue
  redelivery) apply effects multiple times
- **State desync between systems** — partial failure leaves two systems (DB and
  cache, service A and service B) in contradictory states with no reconciliation
- **Error handling that disables safety** — catch blocks that swallow errors and
  continue execution past safety checks

### Action

**Fix before merging.** Add tests that simulate the failure scenario.

---

## P2 — Medium

**Meaningful impact but requires specific timing or compounded conditions.**

Needs an unusual sequence of events, precise timing, or multiple independent
failures to trigger.

### Examples

- **Intermittent race conditions** — timing-dependent bugs that surface only
  under specific load patterns
- **Incomplete edge-case validation** — missing checks on rare but valid inputs
  (empty collections, boundary values, unicode edge cases)
- **Recovery gaps requiring manual intervention** — the system can get into a
  state that requires manual database fixes or restarts to resolve

### Action

**Document in the handover.** Fix if time permits, otherwise flag for follow-up.

---

## Exclude — Not a Finding

Do **not** report these:

- Style preferences not mandated by the project's linter config or CLAUDE.md
- Hypothetical issues in code paths that are unreachable or disabled
- Performance optimizations without evidence of a real bottleneck
- "Best practice" suggestions that don't address a concrete risk
- TODOs or missing features that are out of scope for the current task

---

## Evidence Threshold

Every reported finding **must** include:

1. **File and line** — exact location (`path/to/file.ext:42`)
2. **Risk** — concrete impact description (not "could be bad")
3. **Failure path** — step-by-step sequence that triggers the issue
4. **Concrete fix** — specific code change or design adjustment
5. **Validation** — test or check that proves the fix works

If you cannot provide all five, the finding is speculative — do not report it.
