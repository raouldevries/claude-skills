---
name: handover
description: >
  Create a session handover document summarizing what was done, decisions made,
  current state, and next steps. Use at the end of any session to preserve
  context for the next one.
---

# Handover Document

Create a concise handover document for the current session.

## Why Handovers Matter

Claude Code is **stateless between sessions** and has a **finite context window**
within them. Handovers are the primary mechanism for bridging that gap:

- **Context window is finite, sessions are not.** A complex coding session can
  fill the context window — when that happens, early decisions, rationale, and
  plan details get compressed or evicted. A handover crystallizes hours of
  context into a small document a fresh session can read in one shot.

- **Fresh sessions guess wrong without state.** Without a handover, the next
  session must re-derive intent from code alone. It may re-implement something
  that was deliberately removed, or miss that a design decision was already
  settled. The "Key Decisions" table prevents relitigating resolved questions.

- **State drift causes compounding errors.** The most dangerous mistakes happen
  when Claude assumes the project is in state A but it's actually in state B —
  tests were refactored, a dependency swapped, a config moved. Each
  misconception compounds. The "Current State" and "Files Changed" sections
  anchor the next session to reality.

- **Progress tracking prevents duplicate and skipped work.** Without explicit
  tracking, Claude may redo a completed step (wasting tokens and risking
  regressions) or skip one it thinks is done but isn't.

The cost is ~2 minutes at session end. The payoff is avoiding the 20-minute
spiral where a fresh session goes confidently in the wrong direction.

## Steps

1. **Gather context** — Review what was done this session:
   - Read recent git log (`git log --oneline -20`) to see commits made
   - Run `git diff --stat HEAD~N` (where N = number of session commits) for files changed
   - Auto-detect a progress tracker: check CLAUDE.md for a reference → look for
     common paths (`memory-bank/progress.md`, `PROGRESS.md`, `TODO.md`) → skip
     silently if none found
   - Check the project's CLAUDE.md for file placement rules

2. **Determine handover location** — Resolve in this priority order:
   1. If inside a git repo with a CLAUDE.md: use the path convention from CLAUDE.md (e.g., `docs/handovers/`)
   2. If inside a git repo without CLAUDE.md: use `docs/handovers/` relative to the repo root
   3. If **not** in a git repo: save to `~/.claude/handovers/YYYY-MM-DD-handover.md`
   - Always check with `git rev-parse --show-toplevel 2>/dev/null` to detect if you're in a repo
   - If a handover already exists for today, append a sequence number: `YYYY-MM-DD-handover-2.md`

3. **Write the handover** — Use the template in `references/handover-template.md`. Include:
   - **Session summary** — What was the goal, what was accomplished
   - **Changes made** — Files created/modified with brief descriptions
   - **Key decisions** — Any architectural or design choices made and why
   - **Current state** — Test results, build status, known issues
   - **Next steps** — What should be done in the next session
   - **Blockers** — Anything that's stuck or needs user input

4. **Update progress tracker** — If a progress tracker was detected in step 1, update it with today's work. Otherwise skip.

5. **Git commit the handover** — Only if inside a git repo. Stage and commit the handover doc (and progress update if applicable):
   ```
   docs: add session handover for YYYY-MM-DD

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
   If not in a git repo, skip the commit and just report where the file was saved.

6. **Report to user** — Summarize what's in the handover and where it was saved.

## Notes

- This skill is for **standalone handovers** — use the `audit-loop` skill when implementing plan steps (it includes its own handover phase)
- Keep handovers concise — 1-2 pages max. Focus on what the next session needs to know
- If no commits were made this session (e.g., research/debugging only), still document findings and conclusions
