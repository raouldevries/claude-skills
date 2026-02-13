# claude-skills

A collection of reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills — language-agnostic workflows that work with any repository.

## Skills

| Skill | Description |
|-------|-------------|
| [audit-loop](./audit-loop/) | Test-first implement → self-audit → Codex audit → commit → handover. Full quality-gated workflow for a single plan step. |

## Installation

Claude Code discovers skills from `~/.claude/skills/`. Symlink a skill directory to make it available:

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

After linking, the skill is available in any Claude Code session. Invoke it by name (e.g. "use the audit-loop skill to implement this step").

## How Skills Work

Each skill is a directory containing:

```
skill-name/
├── SKILL.md              # Main skill definition (instructions + workflow)
└── references/           # Supporting documents the skill reads at runtime
    ├── severity-rubric.md
    └── handover-template.md
```

- **`SKILL.md`** — The entry point. Contains the skill's metadata (name, description) and full workflow instructions. Claude reads this when the skill is invoked.
- **`references/`** — Supporting documents referenced by the skill. These are read on demand during execution (e.g. the severity rubric is passed to the review sub-agent).

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
