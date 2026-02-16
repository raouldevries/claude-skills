---
name: digital-strategy
description: Strategic planning frameworks for connecting business objectives to Meta Ads execution. Provides the Digital Marketing & Measurement Model (DMMM) for structured campaign planning, the Acquisition-Behavior-Outcomes trifecta for holistic analysis, multichannel attribution guidance, and core analytics principles for building data-driven marketing. Use when the user asks about "marketing strategy", "DMMM", "measurement model", "attribution", "strategic planning", "campaign planning", "new product launch", "multichannel", "cross-channel", "offline conversions", "how to structure my account", or needs to connect business goals to campaign execution.
---

# Digital Strategy Advisor

Connect business objectives to Meta Ads execution through structured measurement models, cross-channel attribution, and evidence-based strategic planning.

## Quick Reference: The DMMM

```
Objectives → Goals → KPIs → Targets → Segments
```

This five-step model is the difference between data-driven marketing and faith-based marketing. Complete it before launching campaigns, not after.

## Decision Tree

Route to the right framework based on the user's need:

```
"Plan a new campaign/launch" ──────→ Phase 1 (Create DMMM)
"Structure my measurement" ────────→ Phase 1 (Create DMMM)
"Full account strategy" ───────────→ Phase 1 + Phase 2 (DMMM + Trifecta)
"Track offline conversions" ───────→ Phase 3 (Multichannel Attribution)
"Cross-channel measurement" ───────→ Phase 3 (Multichannel Attribution)
"Build data-driven practice" ──────→ Phase 4 (Fundamental Truths)
"Attribution model selection" ─────→ Phase 3 (Multichannel Attribution)
"Connect ads to business goals" ───→ Phase 1 (Create DMMM)
```

## Phase 1: Create a DMMM

Read `references/dmmm-framework.md` for the full five-step process. Use `assets/dmmm-template.md` as a structured worksheet.

Walk the user through all five steps:

1. **Identify Business Objectives** (with executives/client)
   - Ask: "Why does this campaign / account exist?"
   - Validate: Are objectives DUMB? (Doable, Understandable, Manageable, Beneficial)
   - Limit to 3-5 objectives maximum

2. **Define Goals for Each Objective** (with marketing team)
   - Each objective should have 2-4 specific goals
   - Goals must cover acquisition, behavior, AND outcomes
   - Include both macro and micro conversions

3. **Select KPIs** (analyst-led)
   - One KPI per goal, chosen using the `metrics-kpis` skill guidelines
   - Prefer ratios over counts, outcomes over activity
   - Ensure every KPI is segmentable

4. **Set Targets** (with finance/management)
   - Every KPI needs a numerical target before launch
   - Source targets from: historical data, finance calculations, benchmarks, or reasonable estimates
   - No target = no way to know if results are good or bad

5. **Define Analysis Segments** (analyst-led, with executive input)
   - Pre-define which acquisition, behavior, and outcome segments to analyze
   - Use the `data-analysis` skill for detailed segmentation guidance
   - Prevents aimless data exploration after launch

### Output
Deliver a completed DMMM document using the template in `assets/dmmm-template.md`, formatted for the user's specific business and campaigns.

## Phase 2: Apply the A-B-O Trifecta

Read `references/acquisition-behavior-outcomes.md` for the full model, diagnostic framework, and STDC integration.

For every campaign or account, ensure measurement covers all three phases:

1. **Acquisition** — How people arrive
   - Traffic source mix, cost efficiency, audience quality
   - Is the portfolio diversified? (prospecting 60-70%, retargeting 15-25%, re-engagement 5-15%)
   - Are we reaching the right people or just any people?

2. **Behavior** — What people do after arrival
   - On-site engagement (bounce rate, scroll depth, pages per session)
   - Micro-conversion progress (ViewContent, AddToCart)
   - Behavioral signals that predict conversion

3. **Outcomes** — What results are produced
   - Macro + micro conversion value
   - Three ultimate outcomes: more revenue, reduced cost, increased satisfaction
   - Total economic value, not just primary conversion count

### Trifecta Diagnostic
When a campaign underperforms, use the trifecta to isolate which phase is failing:
- Good acquisition, bad behavior → Landing page or message mismatch
- Good behavior, bad outcomes → Conversion friction or tracking issue
- Bad acquisition → Wrong audience or weak creative

## Phase 3: Multichannel Attribution

Read `references/multichannel-attribution.md` for five attribution strategies, Meta-specific tools, and implementation priorities.

1. **Choose attribution approach** based on data available:
   - Vanity URLs / offer codes for offline-to-online tracking
   - Conversions API for online-to-offline event tracking
   - Correlation analysis for cross-channel impact
   - Controlled experiments for true incrementality measurement

2. **Configure Meta attribution settings**:
   - Select attribution window based on consideration cycle (1-day, 7-day, or 28-day click)
   - Implement Conversions API for server-side event tracking
   - Set up offline conversion uploads for store/phone events

3. **Design incrementality tests**:
   - Geographic lift tests (ads in Region A, not in Region B)
   - Conversion lift studies (Meta's built-in test/control methodology)
   - Holdout tests (pause Meta in one market, compare total sales)

### When to Use Each Attribution Approach

| Situation | Recommended Approach |
|-----------|---------------------|
| "How much revenue does Meta drive?" | Conversion lift study (incrementality) |
| "Which campaign type drives most value?" | Multi-touch attribution comparison |
| "Do our Meta ads drive store visits?" | Offline conversion upload + geo-test |
| "What's the impact of our TV ads on Meta?" | Traffic correlation analysis |
| "Should we credit view-through conversions?" | A/B test: compare with and without view-through |

## Phase 4: Build a Data-Driven Practice

Read `references/fundamental-truths.md` for ten core principles, the seven steps to a data-driven culture, and the 10/90 rule.

When the user needs strategic guidance on analytics maturity:

1. **Assess current state** — Where does the organization sit? (Data collection only? Reporting? Analysis? Optimization? Data-driven culture?)
2. **Apply the 10/90 rule** — Invest 10% in tools, 90% in people and processes
3. **Start with quick wins** — Find obvious waste, fix it, build credibility
4. **Establish experimentation** — At least one test per month
5. **Kill vanity metrics** — If nobody acts on it, stop reporting it
6. **Review quarterly** — Kill 25% of metrics annually as business evolves

## Output Format

Adapt based on the user's need:

**DMMM Document:**
Use `assets/dmmm-template.md` structure, filled in for the user's specific business.

**Strategic Recommendation:**
```
# Strategic Recommendation: [Topic]

## Current State
[Assessment of current measurement/strategy]

## Gap Analysis
[What's missing or misaligned]

## Recommended Approach
[Specific framework or model to apply]

## Implementation Plan
1. [Week 1 action]
2. [Week 2 action]
3. [Week 3-4 action]

## Expected Impact
[Projected improvement with reasoning]
```

**Attribution Plan:**
```
# Attribution Plan: [Account/Business]

## Current Attribution Setup
[What's tracked, what's missing]

## Recommended Attribution Stack
- Primary: [approach]
- Secondary: [approach]
- Validation: [incrementality test design]

## Implementation Priorities
1. [Foundation: tracking setup]
2. [Intermediate: cross-channel measurement]
3. [Advanced: incrementality testing]
```

## Cross-References

- **KPI selection for Step 3**: See `metrics-kpis` skill for choosing the right KPIs and setting targets
- **Segmentation for Step 5**: See `data-analysis` skill for detailed segmentation strategies
- **Audience stages**: See `see-think-do-care` skill for mapping STDC stages to campaign objectives
- **Campaign execution**: See `/strategy` command for budget allocation and scaling based on DMMM
- **Performance analysis**: See `/analyze` command for evaluating campaigns against DMMM targets

## References

- **DMMM framework**: `references/dmmm-framework.md` — Five-step model, DUMB objectives, Meta Ads mapping, quarterly review
- **Trifecta model**: `references/acquisition-behavior-outcomes.md` — A-B-O phases, diagnostic framework, STDC integration
- **Attribution**: `references/multichannel-attribution.md` — Five strategies, Conversions API, attribution windows, incrementality testing
- **Core principles**: `references/fundamental-truths.md` — Ten truths, 10/90 rule, data-driven culture, experimentation mandate
- **DMMM worksheet**: `assets/dmmm-template.md` — Structured template for creating a complete measurement model
