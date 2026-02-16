# Ten-Step Analysis Framework

Systematic investigation process for analyzing campaign and account performance, adapted from Avinash Kaushik's beginner's guide to web data analysis.

## The Framework

A structured approach for analyzing any Meta Ads account or campaign, even without prior context. Each step builds on the previous one, moving from broad context to specific insights.

### Step 1: Review the Account Setup
Before touching data, review the account structure. Note campaign objectives, audience targeting, creative themes, and landing pages. Visit the landing pages as a customer would. Identify macro and micro conversions the account should be tracking.

**Ask**: What is this account trying to accomplish? What does the conversion flow look like?

### Step 2: Assess the Acquisition Strategy
Examine the traffic source portfolio across campaigns. A healthy Meta Ads account has diversified campaign types — not all spend concentrated in one objective or audience.

**Look for**:
- Over-reliance on a single campaign type (e.g., all conversion campaigns, no prospecting)
- Missing funnel stages (awareness, consideration, conversion)
- Budget imbalance between prospecting and retargeting (healthy ratio: 70-80% prospecting, 20-30% retargeting)
- Channel mix: Is Meta the only paid channel? Over-reliance creates fragility

### Step 3: Evaluate Audience Engagement Depth
Measure how strongly audiences engage beyond the first interaction.

**Key signals**:
- Frequency distribution: How many times do people see ads before converting?
- Time-to-conversion: Days between first impression and conversion
- Multi-touch patterns: Do converters interact with multiple ad sets or campaigns?
- Retention: Do acquired customers return and purchase again?

### Step 4: Find Broken Elements (Quick Wins)
Identify the highest-impact broken elements — the "landing page bounce rate" equivalents.

**Check**:
- Ad sets with high spend but zero conversions
- Landing pages with high traffic but high bounce rates (check via analytics)
- Creatives with CTR significantly below account average
- Audiences with CPA 2x+ above account average
- Ads disapproved or in review for extended periods

### Step 5: Identify Highest-Value Performers
Find what's generating the most economic value (not just the most volume).

**Analyze by**:
- ROAS or value per conversion by ad set
- Revenue contribution by creative
- Economic value by audience segment
- AOV by campaign (higher AOV may justify higher CPA)

### Step 6: Audit Creative Strategy
Assess creative diversity and freshness — the equivalent of "search strategy sophistication."

**Evaluate**:
- Creative format mix (static, video, carousel, collection)
- Hook diversity (different opening angles for the same product)
- Age of active creatives (creative fatigue signals)
- Testing cadence: How often are new creatives introduced?

### Step 7: Validate Goals and Conversion Tracking
Verify that the account is measuring what matters.

**Check**:
- Are macro and micro conversions configured?
- Are conversion values assigned accurately?
- Is the Pixel firing correctly on all conversion events?
- Are there attribution window mismatches (1-day click vs. 7-day click)?

### Step 8: Evaluate Budget Efficiency
Determine where budget is being wasted and where it should be reallocated.

**Compare**:
- Cost per result by campaign, ad set, and placement
- Budget utilization (campaigns not spending full budget = targeting too narrow)
- Diminishing returns: CPA trend as spend increases per ad set
- Placement performance: Automatic vs. manual placement efficiency

### Step 9: Analyze the Conversion Funnel
Map the structured path from impression to conversion and find where prospects drop off.

**Funnel metrics**:
- Impression → Click (CTR)
- Click → Landing page view (page load rate)
- Landing page view → Add to cart / Lead (on-site conversion)
- Add to cart → Purchase (checkout completion)

The biggest drop-off point is the highest-leverage fix.

### Step 10: Detect Anomalies and Unknown Unknowns
Look for statistical anomalies that standard reports hide.

**Methods**:
- Compare current period performance to statistical norms (2+ standard deviations = investigate)
- Check for sudden changes in any metric over the past 7, 14, 30 days
- Look for audience segments or placements with dramatically different performance
- Use automated rules or alerts to flag anomalies

## Meta Ads Application

### Running a Full Account Audit

Execute all 10 steps sequentially. Typical timeline: 2-3 hours for initial analysis.

1. **Steps 1-2** (15 min): Account structure review and acquisition assessment
2. **Steps 3-4** (30 min): Engagement depth and broken elements identification
3. **Steps 5-6** (30 min): Top performers and creative audit
4. **Steps 7-8** (30 min): Conversion tracking validation and budget efficiency
5. **Steps 9-10** (30 min): Funnel analysis and anomaly detection

### Output Template

```
# Account Analysis: [Account Name]
Date: [Date]

## Executive Summary
[2-3 sentences on account health]

## Quick Wins (Fix Immediately)
1. [Broken element + recommended fix]
2. [Budget waste + reallocation recommendation]

## Top Performers (Scale These)
1. [High-value campaign/ad set + scaling recommendation]
2. [Best creative + expansion recommendation]

## Strategic Gaps
1. [Missing funnel stage or audience]
2. [Measurement gap]

## 30-Day Action Plan
- Week 1: [Quick fixes]
- Week 2: [Creative refresh]
- Week 3: [Audience expansion]
- Week 4: [Measurement improvements]
```
