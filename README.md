# claude-skills

A collection of reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills — language-agnostic workflows that work with any repository.

## Skills

| Skill | Description |
|-------|-------------|
| [audit-loop](./audit-loop/) | Test-first implement → self-audit → Codex audit → commit → handover. Full quality-gated workflow for a single plan step. |
| [handover](./handover/) | Create a session handover document summarizing what was done, decisions made, current state, and next steps. |
| [make-plan](./make-plan/) | Create structured implementation plans with phased breakdowns, acceptance criteria, quality gates, and progress tracking. Each step maps to one audit-loop cycle. |

## How They Work Together

These skills chain into a pipeline for multi-session project execution:

```
  make-plan                    audit-loop                   handover
┌────────────┐  Step X.Y    ┌────────────────┐  state    ┌───────────┐
│ Structure  │──────────────▶│ Test-first     │──────────▶│ Snapshot  │
│ the work   │  + acceptance │ implement +    │  + done   │ session   │──┐
│ into steps │  criteria     │ quality gate   │  steps    │ state     │  │
└────────────┘               └────────────────┘           └───────────┘  │
      ▲                                                                  │
      └──────────────────── next session reads ──────────────────────────┘
```

The **plan file is the shared contract**. make-plan writes steps with acceptance criteria as checkboxes → audit-loop consumes each step (criteria become tests in the test-first phase) → handover records progress and points back to the plan. The next session picks up where the last one left off.

This creates continuity across Claude's ephemeral context windows — no single skill handles multi-session projects, but together they do.

## Installation

Claude Code discovers skills **only** from `~/.claude/skills/` — it won't scan other directories. Since this repo lives outside that path, you need to symlink the skills you want into the discovery directory:

```bash
# Link a single skill
ln -s ~/claude-skills/audit-loop ~/.claude/skills/audit-loop

# Or link all skills at once
for skill in ~/claude-skills/*/; do
  name=$(basename "$skill")
  [ "$name" = ".git" ] && continue
  ln -sf "$skill" ~/.claude/skills/"$name"
done
```

Why symlinks instead of copying? The repo stays a normal git checkout — you can `git pull` to get updates and they take effect immediately without re-copying.

After linking, the skill is available in any Claude Code session. Invoke it by name (e.g. "use the audit-loop skill to implement this step").

## Skill Structure

Each skill is a directory containing:

```
skill-name/
├── SKILL.md              # Main skill definition (instructions + workflow)
├── references/           # Supporting documents the skill reads at runtime
├── scripts/              # Executable helper scripts (Python/Bash)
└── assets/               # Templates and files used in skill output
```

- **`SKILL.md`** — The entry point. Contains the skill's metadata (name, description) and full workflow instructions. Claude reads this when the skill is invoked.
- **`references/`** — Supporting documents referenced by the skill. These are read on demand during execution (e.g. the severity rubric is passed to the review sub-agent).
- **`scripts/`** — Executable code that can be run directly (e.g. `init-plan.py` scaffolds a new plan file).
- **`assets/`** — Templates and files used within the skill's output (e.g. plan-template.md gets copied and filled in).

## Customization

### CLAUDE.md (recommended)

Skills are designed to defer to your project's `CLAUDE.md` for project-specific configuration. For example, the audit-loop skill:

- Uses your `CLAUDE.md`'s validation command if specified
- Follows your `CLAUDE.md`'s code style rules
- Reads your `CLAUDE.md`'s domain-specific review criteria

This means you can customize behaviour **without forking** — just add the relevant instructions to your project's `CLAUDE.md`.

### Forking

For deeper changes, fork this repo and modify the skill files directly. Since skills are just markdown files, they're easy to adapt.

## Contributing

To add a new skill:

1. Create a directory: `your-skill-name/`
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`) and workflow instructions
3. Add any supporting files under `references/`
4. Update the skills table in this README
5. Open a PR

Guidelines:
- Keep skills **language-agnostic** — detect project type rather than assuming one
- Reference supporting files with **relative paths** (`references/foo.md`)
- Design for graceful degradation — skip optional steps rather than failing

## License

MIT
