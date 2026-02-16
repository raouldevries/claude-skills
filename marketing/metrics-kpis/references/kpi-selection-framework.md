# KPI Selection Framework

Systematic approach to selecting KPIs that connect business objectives to measurable outcomes, based on Avinash Kaushik's measurement hierarchy.

## The Measurement Hierarchy

Every measurement effort follows this chain:

```
Business Objectives → Goals → KPIs → Metrics → Targets → Segments
```

- **Business Objectives**: Answer "Why does this campaign/account exist?" Must be DUMB: Doable, Understandable, Manageable, Beneficial.
- **Goals**: Specific strategies to accomplish objectives. One level more concrete.
- **KPIs**: Metrics that measure progress toward objectives. Not all metrics are KPIs.
- **Metrics**: Numbers — either Counts (totals) or Ratios (divisions). KPIs are a subset.
- **Targets**: Pre-determined numerical values indicating success or failure. Every KPI needs one.
- **Segments**: Groups defined by dimensions (source, behavior, geography) used to slice KPI data.

Without DUMB objectives defined first, no amount of data will produce insights.

## The Eight Rules for KPI Selection

1. **Start with Outcomes** — Begin with what the business achieved, not what it acquired. Lead with results (purchases, leads, sign-ups), not vanity metrics (impressions, reach).
2. **Measure where effort is greatest** — KPIs should reflect the areas receiving the most investment. If 60% of budget goes to prospecting, the primary KPI should measure prospecting effectiveness.
3. **Require pan-session thinking** — Reject "one night stand" metrics that only measure a single interaction. Favor metrics that capture the full customer journey across multiple touchpoints.
4. **Ensure segmentability** — If a KPI cannot be meaningfully segmented (by audience, placement, creative, time period), it is the wrong KPI. Segmented data reveals causes; aggregate data hides them.
5. **Include customer voice** — At least one KPI should capture direct customer feedback or intent signals, not just behavioral proxies.
6. **Measure brand impact when relevant** — Loyalty and recency metrics can measure "brand" and "engagement" campaigns where direct response metrics fail.
7. **Connect to legacy metrics** — When stakeholders think in traditional terms (reach, frequency, GRPs), provide KPIs that bridge old-world thinking to new-world measurement.
8. **Include competitive context** — Internal-only KPIs create blind spots. Include at least one metric that benchmarks performance against competitors or category norms.

## KPI Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Vanity metrics as KPIs | Impressions/reach feel good but don't indicate business impact | Replace with outcome-based metrics (cost per result, ROAS) |
| Too many KPIs | Decision paralysis, no clear priority | Maximum 3-5 KPIs per campaign objective |
| No targets set | Cannot distinguish success from failure | Set targets before launching, using historical data or finance input |
| Aggregate-only reporting | Hides what's working and what isn't | Always segment by audience, placement, creative, and time |
| Same KPIs for all stages | Measuring awareness campaigns on conversion metrics | Match KPIs to funnel stage (see STDC framework) |
| "Engagement" as a KPI | Undefined, unmeasurable, an excuse | Replace with specific measurable actions (video views to 75%, link clicks, saves) |

## The "Three Layers of So What" Test

Apply this test to every proposed KPI:

1. **Layer 1**: "So what?" — What does this number mean for the business?
2. **Layer 2**: "So what?" — What action can be taken based on this information?
3. **Layer 3**: "So what?" — What is the expected business impact of that action?

If a metric cannot survive three layers of "so what," it is not a KPI — it is noise.

## Meta Ads Application

### Mapping the Hierarchy to Campaign Structure

| Hierarchy Level | Meta Ads Equivalent | Example |
|----------------|--------------------|---------|
| Business Objective | Account-level goal | Grow online revenue by 25% this quarter |
| Goal | Campaign objective | Drive qualified traffic that converts within 14 days |
| KPI | Primary campaign metric | Cost per purchase, ROAS, cost per qualified lead |
| Metric | Supporting metrics | CPM, CTR, CPC, frequency, reach |
| Target | Benchmarks | CPA < $45, ROAS > 3.5x, CPL < $12 |
| Segment | Breakdowns | By ad set (audience), placement, creative, age/gender, device |

### KPI Selection by Campaign Objective

| Objective | Primary KPI | Secondary KPIs | Avoid |
|-----------|------------|----------------|-------|
| OUTCOME_AWARENESS | Cost per 1,000 people reached, ad recall lift | Frequency, reach %, ThruPlay rate | Conversion rate, ROAS |
| OUTCOME_TRAFFIC | Cost per landing page view, bounce rate | CTR, CPC, session duration | Impressions, reach |
| OUTCOME_ENGAGEMENT | Cost per engagement, video completion rate | Saves, shares, comment rate | Follower count, impressions |
| OUTCOME_LEADS | Cost per lead, lead-to-customer rate | Lead form completion rate, lead quality score | CPM, reach |
| OUTCOME_SALES | ROAS, cost per purchase | AOV, purchase volume, conversion rate | CTR, CPC |
| OUTCOME_APP_PROMOTION | Cost per install, Day-7 retention | In-app purchase rate, session frequency | Downloads alone |

### Setting Targets

1. Pull 90-day historical averages from Ads Manager as baseline
2. Consult with finance on acceptable customer acquisition cost
3. Calculate LTV-based targets (see `ltv-calculation.md`)
4. Set improvement targets at 10-20% increments, not arbitrary round numbers
5. Review and adjust targets monthly based on performance data
