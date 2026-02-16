---
name: data-analysis
description: Systematic investigation frameworks for analyzing Meta Ads performance data. Provides structured approaches for account audits, audience segmentation, root cause investigation when metrics change, and statistical significance evaluation. Use when the user asks to "analyze this data", "segment audiences", "what changed", "why did performance drop", "find insights", "statistical significance", "account audit", "investigate", or needs help diagnosing campaign performance issues.
---

# Data Analysis Advisor

Systematic frameworks for investigating campaign performance, segmenting audiences, diagnosing changes, and applying statistical rigor to Meta Ads decisions.

## Quick Reference: Analysis Approach

```
Complex problem ──→ Break into segments ──→ Compare segments ──→ Find the outlier ──→ Investigate the cause ──→ Act
```

Core principle: In aggregate, almost all data is useless. **Segment or Die.** Every insight comes from comparing one segment against another.

## Decision Tree

Route to the right framework based on the user's need:

```
"Analyze my account" ──────────────→ Phase 1 (Systematic Audit)
"Performance dropped/changed" ─────→ Phase 2 (What's Changed)
"Find my best audiences/segments" ─→ Phase 3 (Segmentation)
"Is this result significant?" ─────→ Phase 4 (Statistical Significance)
"Compare these campaigns/creatives" → Phase 3 + Phase 4
"Full investigation" ──────────────→ Phase 1 → Phase 2 → Phase 3
```

## Phase 1: Systematic Account Audit

Read `references/ten-step-analysis-framework.md` for the full 10-step investigation process and output template.

When starting from scratch or conducting a periodic review:

1. **Review account setup** — Structure, objectives, conversion tracking, landing pages
2. **Assess acquisition strategy** — Campaign type mix, funnel coverage, budget distribution
3. **Evaluate engagement depth** — Frequency, time-to-conversion, multi-touch patterns
4. **Find broken elements** — Zero-conversion ad sets, high-CPA outliers, disapproved ads
5. **Identify top performers** — Highest ROAS, best AOV, most efficient creatives
6. **Audit creative strategy** — Format diversity, hook variety, freshness, testing cadence
7. **Validate tracking** — Pixel events, conversion values, attribution windows
8. **Evaluate budget efficiency** — CPA by campaign, diminishing returns, placement performance
9. **Analyze the funnel** — Drop-off points from impression to conversion
10. **Detect anomalies** — Statistical outliers, sudden changes, unknown unknowns

### Quick Audit (30 min)
Focus on Steps 2, 4, 5, and 8 for the fastest actionable output.

### Full Audit (2-3 hrs)
Execute all 10 steps sequentially. Delivers comprehensive findings with prioritized action plan.

## Phase 2: What's Changed Investigation

Read `references/whats-changed-analysis.md` for the full root cause methodology and common misdiagnoses.

When a metric has shifted unexpectedly:

1. **Quantify the change** — Which metric, by how much, over what period. Is it statistically significant or normal variance?
2. **Isolate the dimension** — Compare period-over-period across campaigns, ad sets, creatives, placements. Which dimension explains the change?
3. **Drill to root cause** — Follow the investigation chain: account → campaign → ad set → specific factor (frequency, CPM, CTR, conversion rate)
4. **Compare against baseline** — Build a period-over-period metrics table. The metric that changed first in the chain reveals the root cause.
5. **Determine action** — Match root cause to the appropriate fix (new creatives for fatigue, audience expansion for saturation, wait for learning phase, debug for tracking issues).

### Key Investigation Chain
```
CPM up → Auction competition or seasonality
CTR down → Creative fatigue or audience mismatch
CVR down → Landing page, tracking, or audience quality issue
Frequency up → Audience saturation
```

### Common Misdiagnoses to Avoid
- CPA spike after edit → Likely learning phase, not a broken change (wait 48h)
- CTR decline over weeks → Usually creative fatigue, not wrong audience
- Sudden zero conversions → Check tracking before blaming the campaign

## Phase 3: Segmentation Analysis

Read `references/segmentation-strategies.md` for the three segment categories, "non-flirts" approach, and value-based segmentation.

When looking for deeper insights:

1. **Choose the segment category** — Acquisition (where they came from), Behavior (what they did), or Outcome (what they produced)
2. **Apply Ads Manager breakdowns** — Age, gender, placement, device, region, time
3. **Focus on engaged traffic first** — Analyze the "non-flirts" (people who took meaningful action) before investigating bounced/non-converting traffic
4. **Build value-based segments** — Rank customers by total value, profile top quartile, use for lookalike audiences
5. **Cross-cut segments** — Apply multiple dimensions: best audience × best placement × best device

### Segmentation Rules
- Minimum 50 conversions per segment for reliable comparison
- Always segment both best AND worst performers
- Refresh segment definitions quarterly as audiences evolve
- Avoid over-segmentation: 3-5 meaningful segments beat 20 tiny ones

## Phase 4: Statistical Significance

Read `references/statistical-significance.md` for confidence levels, sample size requirements, and A/B testing best practices.

When comparing options or validating results:

1. **Check sample size** — At least 50 conversions per option before comparing
2. **Assess the difference** — Relative differences > 20% with adequate sample sizes are usually actionable
3. **Control for time** — Run for at least 7 full days to capture day-of-week variation
4. **Use Meta's Experiments** when possible — Built-in tools handle significance calculations automatically
5. **Apply the checklist** — 50+ conversions, 7+ days, 20%+ relative difference, no external disruptions

### Quick Decision Guide
| Conversions per variant | Difference | Action |
|------------------------|-----------|--------|
| < 20 | Any | Too early to decide — keep running |
| 20-50 | < 30% | Not enough data — keep running |
| 20-50 | > 50% | Promising signal — keep running but prepare to act |
| 50-100 | > 20% | Likely significant — consider acting |
| 100+ | > 15% | High confidence — act on the result |

## Output Format

Adapt based on the user's need:

**Investigation Report:**
```
# Performance Investigation: [What Changed]

## Summary
[1-2 sentences: what happened and why]

## Investigation Path
[Dimension-by-dimension breakdown of the root cause]

## Root Cause
[Specific finding with supporting data]

## Recommended Actions
1. [Immediate fix]
2. [Prevention measure]
3. [Monitoring plan]
```

**Segmentation Analysis:**
```
# Segment Analysis: [Dimension]

## Key Finding
[1 sentence insight]

## Segment Comparison
| Segment | [Key Metric] | Conversions | CPA | ROAS |
|---------|-------------|-------------|-----|------|
| [Best] | | | | |
| [Average] | | | | |
| [Worst] | | | | |

## Recommended Actions
[Scaling, reallocation, or targeting changes based on findings]
```

## Cross-References

- **KPI selection**: See `metrics-kpis` skill for choosing what to measure before analyzing
- **Strategic context**: See `digital-strategy` skill for connecting analysis findings to business objectives
- **Funnel stage alignment**: See `see-think-do-care` skill for ensuring metrics match audience intent
- **Campaign optimization**: See `/optimize` command for acting on analysis findings
- **A/B testing**: See `ab-test-setup` skill for designing rigorous experiments

## References

- **Systematic audit**: `references/ten-step-analysis-framework.md` — 10-step investigation process, output template, quick vs. full audit
- **Segmentation**: `references/segmentation-strategies.md` — Three segment categories, non-flirts approach, value-based segmentation, Meta breakdowns
- **Root cause investigation**: `references/whats-changed-analysis.md` — Investigation process, period comparison, analysis ninja techniques, common misdiagnoses
- **Statistical significance**: `references/statistical-significance.md` — Confidence levels, sample sizes, A/B testing, decision guide
