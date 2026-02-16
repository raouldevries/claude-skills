# claude-skills

A collection of reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills — language-agnostic workflows that work with any repository.

## Skills

### Engineering

| Skill | Description |
|-------|-------------|
| [audit-loop](./audit-loop/) | Test-first implement → self-audit → Codex audit → commit → handover. Full quality-gated workflow for a single plan step. |
| [handover](./handover/) | Create a session handover document summarizing what was done, decisions made, current state, and next steps. |
| [make-plan](./make-plan/) | Create structured implementation plans with phased breakdowns, acceptance criteria, quality gates, and progress tracking. Each step maps to one audit-loop cycle. |

### Marketing Analytics

| Skill | Description |
|-------|-------------|
| [metrics-kpis](./metrics-kpis/) | KPI selection, macro/micro conversion measurement, LTV calculation, and brand metrics. Answers "what should I measure and why." |
| [data-analysis](./data-analysis/) | Systematic 10-step account audits, audience segmentation, root cause investigation, and statistical significance. Answers "how do I investigate." |
| [digital-strategy](./digital-strategy/) | DMMM framework, Acquisition-Behavior-Outcomes trifecta, multichannel attribution, and core analytics principles. Answers "how do I connect goals to execution." |

These three marketing skills are designed as an interlocking system — see [The Marketing Analytics Stack](#the-marketing-analytics-stack) below for how they compound each other's value.

## How Engineering Skills Work Together

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

## The Marketing Analytics Stack

The three marketing skills — `digital-strategy`, `metrics-kpis`, and `data-analysis` — form a closed-loop system where each skill's output feeds directly into the next. They're distilled from Avinash Kaushik's analytical frameworks, adapted for paid media and ad platform contexts.

Individually, each skill handles one layer of marketing intelligence. Together, they create something none of them can do alone: a continuous cycle from strategic intent through measurement design to investigative analysis and back.

### The Strategy → Measurement → Analysis Loop

```
                    digital-strategy
                  ┌──────────────────┐
                  │ "Why are we      │
      Revised     │  doing this?"    │     Business
      objectives  │                  │     objectives
    ┌─────────────│  DMMM framework  │─────────────┐
    │             │  A-B-O trifecta  │             │
    │             └──────────────────┘             │
    │                                              ▼
┌───┴──────────┐                          ┌──────────────────┐
│ data-analysis│                          │  metrics-kpis    │
│              │                          │                  │
│ "What        │                          │ "What should     │
│  happened    │◀─── KPIs + targets ──────│  I measure?"     │
│  and why?"   │                          │                  │
│              │                          │  KPI selection   │
│ Segmentation │                          │  LTV, goal       │
│ Root cause   │── Findings feed back ──▶ │  values, brand   │
│ Significance │   into strategy review   │  metrics         │
└──────────────┘                          └──────────────────┘
```

Each skill solves a distinct problem. The power is in the handoffs:

**digital-strategy → metrics-kpis**: Strategy defines objectives using the DMMM five-step process (objectives → goals → KPIs → targets → segments). Step 3 of the DMMM — "select KPIs" — hands off directly to the metrics-kpis skill, which provides the selection framework, the eight rules, and the "three layers of so what" test. Without digital-strategy, KPI selection happens in a vacuum. Without metrics-kpis, strategy has no concrete measures.

**metrics-kpis → data-analysis**: Once KPIs are chosen and conversion tracking is configured (macro/micro conversions with economic values), the data-analysis skill knows *what* to segment and *what* "changed" means. Its ten-step audit framework uses the same measurement hierarchy. Its segmentation strategies slice data along the dimensions the KPI framework defined. Its statistical significance checks validate the results against the targets that metrics-kpis set. Without metrics-kpis, data-analysis has no compass. Without data-analysis, metrics are numbers without investigation.

**data-analysis → digital-strategy**: Analysis findings — which segments outperform, where the funnel breaks, what changed and why — feed back into the next quarterly DMMM review. The digital-strategy skill's "kill 25% of metrics annually" principle depends on data-analysis surfacing which metrics drive action and which don't. The trifecta diagnostic (is it an acquisition, behavior, or outcome problem?) is only answerable with the investigation methods from data-analysis. Without data-analysis, strategy is static. Without digital-strategy, analysis has no strategic frame to report against.

### What You Can't Do With Just One

| Scenario | One skill alone | With the full stack |
|----------|----------------|---------------------|
| "Help me pick KPIs" | metrics-kpis gives you a framework and a list | digital-strategy ensures KPIs connect to real objectives; data-analysis tells you which KPIs actually drove decisions last quarter |
| "My CPA spiked" | data-analysis walks you through root cause investigation | metrics-kpis ensures you're looking at the right conversion definition (macro vs. micro, with economic value); digital-strategy checks if the CPA target was realistic given the DMMM |
| "Plan a new product launch" | digital-strategy builds a DMMM | metrics-kpis selects the right KPIs and sets LTV-based CPA targets; data-analysis designs the segmentation plan and baseline measurements |
| "Is this A/B test result real?" | data-analysis checks statistical significance | metrics-kpis verifies both variants measure the same conversion definition; digital-strategy confirms the test maps to a business objective |
| "Our brand campaign has no ROI" | metrics-kpis provides brand measurement frameworks | digital-strategy reframes the question using the A-B-O trifecta (brand campaigns serve acquisition, not outcomes); data-analysis correlates campaign timing with downstream behavioral shifts |
| "Which audiences should I scale?" | data-analysis segments by value and behavior | metrics-kpis applies LTV calculation to each segment; digital-strategy validates the scaling plan against the DMMM's acquisition goals |

### The Gap They Fill

Most marketing AI skills are strong on *execution* — what to write, what to target, what to bid. These three skills fill the layers that execution skills assume someone has already figured out:

```
┌─────────────────────────────────────────────────┐
│          STRATEGIC LAYER                        │
│          digital-strategy                       │
│          "Why are we doing this?"               │
│          DMMM, objectives, measurement model    │
├─────────────────────────────────────────────────┤
│          MEASUREMENT LAYER                      │
│          metrics-kpis                           │
│          "What should we measure?"              │
│          KPIs, conversions, LTV, brand metrics  │
├─────────────────────────────────────────────────┤
│          INVESTIGATION LAYER                    │
│          data-analysis                          │
│          "What happened and why?"               │
│          Segmentation, root cause, significance │
├─────────────────────────────────────────────────┤
│          EXECUTION LAYER                        │
│          (other skills / human decisions)        │
│          "What do we do about it?"              │
│          Ad copy, targeting, bidding, creative  │
└─────────────────────────────────────────────────┘
```

Execution without measurement is guessing. Measurement without strategy is vanity metrics. Strategy without investigation is a PowerPoint that never gets updated. The stack closes the loop.

### Workflow Examples

**Quarterly planning session:**
1. Invoke `digital-strategy` → Build or review DMMM for the quarter
2. Invoke `metrics-kpis` → Select/update KPIs, set LTV-based targets, configure conversion tracking
3. Launch campaigns
4. Invoke `data-analysis` → Weekly audit using ten-step framework, segmented against DMMM dimensions
5. Findings feed into next quarter's DMMM review (back to step 1)

**Performance investigation:**
1. "ROAS dropped 30%" → Invoke `data-analysis` (What's Changed investigation)
2. Root cause identified: audience saturation in top ad set
3. Invoke `metrics-kpis` → Recalculate convertible audience, check if LTV justifies higher CPA for audience expansion
4. Invoke `digital-strategy` → Validate expansion plan against DMMM acquisition goals
5. Act on the recommendation with full strategic backing

**New campaign setup:**
1. Invoke `digital-strategy` → Create DMMM worksheet for the initiative
2. Invoke `metrics-kpis` → Select KPIs (Phase 1), define macro/micro conversions (Phase 2), set targets
3. Launch campaign
4. After 2 weeks: Invoke `data-analysis` → Baseline audit (Phase 1), segment analysis (Phase 3), validate results have statistical significance (Phase 4)

### Origin

These skills are distilled from [Avinash Kaushik's](https://www.kaushik.net/avinash/) analytical frameworks (DMMM, Acquisition-Behavior-Outcomes trifecta, macro/micro conversions, "What's Changed" methodology). The blog content was scraped, structured into frameworks, stripped of narrative, and adapted with ad platform context (campaign objectives, Pixel events, attribution windows, bid strategies). The original blog prose is ~150,000 words across 100+ posts; the skills compress that into ~6,000 words of actionable frameworks.

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
