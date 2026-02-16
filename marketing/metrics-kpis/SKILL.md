---
name: metrics-kpis
description: Guide KPI selection, conversion measurement, LTV calculation, and brand metrics for Meta Ads campaigns. Provides frameworks for choosing what to measure and why, assigning economic value to conversions, and connecting metrics to business objectives. Use when the user asks "what should I measure", "which KPIs", "how to calculate LTV", "goal values", "macro/micro conversions", "brand metrics", "measurement strategy", "what metrics matter", or needs help selecting campaign KPIs.
---

# Metrics & KPI Advisor

Select the right KPIs, assign economic value to conversions, calculate LTV, and measure brand campaigns — connecting every metric to a business objective.

## Quick Reference: Measurement Hierarchy

```
Business Objectives → Goals → KPIs → Metrics → Targets → Segments
```

Core principle: Without DUMB objectives (Doable, Understandable, Manageable, Beneficial), no amount of data produces insights. Define objectives before selecting KPIs.

## Decision Tree

Route to the right phase based on the user's need:

```
"What should I measure?" ──────────→ Phase 1 (KPI Selection)
"Is this the right KPI?" ──────────→ Phase 1 (KPI Validation)
"How do I value conversions?" ─────→ Phase 2 (Conversion Measurement)
"Calculate LTV" ───────────────────→ Phase 3 (LTV Calculation)
"Measure brand/awareness campaign" → Phase 4 (Brand Metrics)
"Set up measurement for new campaign" → Phase 1 → Phase 2 (full sequence)
```

## Phase 1: Select KPIs

Read `references/kpi-selection-framework.md` for the full framework, eight selection rules, and anti-patterns.

1. **Identify the business objective** — Ask: "What is this campaign trying to accomplish for the business?" Not "what do you want to optimize in Ads Manager."
2. **Map to the measurement hierarchy** — Business objective → goals → candidate KPIs.
3. **Apply the Eight Rules** — Validate each candidate KPI against the selection rules (outcomes-first, segmentable, pan-session, includes voice of customer).
4. **Run the "Three Layers of So What" test** — If the KPI cannot survive three rounds of "so what does that mean," discard it.
5. **Set targets** — Every KPI needs a numerical target before the campaign launches. Use historical data, finance input, or LTV-based calculations.
6. **Plan segmentation** — Define how each KPI will be segmented (by audience, placement, creative, time) before launch.

### KPI Quick Selection by Campaign Objective

| Objective | Start Here |
|-----------|-----------|
| OUTCOME_AWARENESS | Cost per 1,000 reached, ad recall lift |
| OUTCOME_TRAFFIC | Cost per landing page view, engaged visit rate |
| OUTCOME_ENGAGEMENT | Cost per engagement, video completion rate |
| OUTCOME_LEADS | Cost per lead, lead-to-customer rate |
| OUTCOME_SALES | ROAS, cost per purchase |
| OUTCOME_APP_PROMOTION | Cost per install, Day-7 retention |

## Phase 2: Measure Conversions Completely

Read `references/conversion-measurement.md` for macro/micro framework, economic value assignment techniques, and Pixel event mapping.

1. **Identify macro conversion** — The one primary outcome per campaign (or none for awareness).
2. **Identify 3-5 micro conversions** — Secondary outcomes that create independent business value.
3. **Assign economic value to each** — Use one of five techniques:
   - Direct revenue tracking (Pixel purchase value)
   - Offline conversion matching (CRM pipeline data)
   - Borrow the finance number (existing offline attribution values)
   - Relative goal values (stakeholder consensus on relative worth)
   - The $1 default (last resort to start the conversation)
4. **Configure tracking** — Map each conversion to a Meta Pixel standard event or custom conversion with value parameters.
5. **Report total economic value** — Campaign value = macro value + sum of micro values. This is the complete picture.

### Key Insight

For most businesses, micro-conversion economic value is 3-4x the macro-conversion value. Reporting only macro conversions dramatically understates campaign ROI.

## Phase 3: Calculate LTV

Read `references/ltv-calculation.md` for formulas, segmented analysis methodology, and Meta Ads bidding application.

1. **Gather data** — Pull 12-24 months of customer data from e-commerce platform, CRM, or ERP.
2. **Segment by acquisition source** — Group customers by the channel/campaign that acquired them.
3. **Calculate per-segment LTV** — AOV × Purchase Frequency × Customer Lifespan × Gross Margin.
4. **Set LTV-based CPA targets** — Target CPA = 20-33% of first-year LTV per segment.
5. **Configure value-based bidding** — Pass predicted LTV (not just first-purchase value) as conversion value in Meta Ads.
6. **Build LTV-informed audiences** — Create lookalike audiences from highest-LTV customer segments.

### When to Prioritize LTV

- Repeat purchase businesses (e-commerce, subscriptions, SaaS)
- High-CPA campaigns where first-purchase ROAS is below target
- Budget allocation decisions across channels
- Evaluating whether to increase bids on apparently expensive audiences

## Phase 4: Measure Brand Campaigns

Read `references/brand-metrics.md` for the seven-outcome framework and Meta-specific brand measurement tools.

1. **Define the brand outcome** — Which of the seven outcomes is this campaign pursuing? (New prospects, value proposition, purchase value, offline action, introduction, competitive positioning, brand recall)
2. **Select outcome-appropriate metrics** — Match metrics to the stated outcome, not to direct response defaults.
3. **Establish baseline** — Measure target metrics for 30 days before campaign launch.
4. **Use Meta Brand Lift studies** when budget qualifies ($30K+ spend).
5. **For smaller budgets** — Use branded search volume, direct traffic changes, engagement quality metrics, and holdout testing.
6. **Measure post-campaign** — Continue tracking for 2-4 weeks after campaign ends to capture delayed effects.

### Common Mistake

Evaluating brand/awareness campaigns on CPA or ROAS. These metrics are irrelevant for upper-funnel campaigns and will always make them appear to "fail." Match metrics to the campaign's stated purpose.

## Output Format

Adapt based on the user's need:

**KPI Recommendation:**
```
# KPI Selection: [Campaign/Account Name]

## Business Objective
[Statement]

## Recommended KPIs
| KPI | Target | Segmentation Plan |
|-----|--------|-------------------|
| [Primary KPI] | [Target] | [How to segment] |
| [Secondary KPI] | [Target] | [How to segment] |

## Conversion Tracking Setup
- Macro: [event + value]
- Micro 1: [event + value]
- Micro 2: [event + value]

## Measurement Schedule
[When to review, when to adjust targets]
```

**LTV Analysis:**
```
# LTV Analysis: [Business/Account]

## Segment Comparison
| Segment | AOV | Frequency | Retention | 1yr LTV | Target CPA |
|---------|-----|-----------|-----------|---------|------------|
| [Segment A] | | | | | |
| [Segment B] | | | | | |

## Bidding Recommendations
[LTV-based bid strategy adjustments]
```

## Cross-References

- **Funnel stage alignment**: See `see-think-do-care` skill for mapping KPIs to audience intent stages
- **Campaign diagnostics**: See `/optimize` command for performance troubleshooting using these KPIs
- **Dashboard creation**: See `/report` command for visualizing KPI performance
- **Strategic planning**: See `digital-strategy` skill for connecting KPIs to the DMMM framework

## References

- **KPI selection**: `references/kpi-selection-framework.md` — DUMB objectives, eight rules, measurement hierarchy, anti-patterns
- **Conversion measurement**: `references/conversion-measurement.md` — Macro/micro framework, five economic value techniques, Pixel event mapping
- **LTV calculation**: `references/ltv-calculation.md` — LTV formulas, segmented analysis, value-based bidding, data sources
- **Brand metrics**: `references/brand-metrics.md` — Seven brand outcomes, Meta Brand Lift studies, measurement without lift studies
