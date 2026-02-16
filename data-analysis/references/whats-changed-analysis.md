# What's Changed Analysis

Root cause investigation methodology for diagnosing performance changes, adapted from Avinash Kaushik's "What's Changed" approach and analysis ninja techniques.

## Core Principle

Unless there is a major external event, the top-level metrics for any stable account rarely change dramatically. When they do, the cause is hidden "below the surface." Standard reports show what happened; What's Changed analysis reveals why.

Most dashboards report on the same things every period. This creates three problems:
1. Analysts report data nobody acts on
2. Decision-makers get frustrated by irrelevant reports
3. The real changes stay hidden until it's too late

**Solution**: Focus analytical effort on what changed, not what stayed the same.

## The What's Changed Investigation Process

### Step 1: Quantify the Change
Define the change precisely before investigating.

- What metric changed? (CPA, ROAS, CTR, conversion rate, spend)
- By how much? (absolute and percentage)
- Over what time period?
- Is the change statistically significant or within normal variance?

**Rule of thumb**: Changes of less than 15% week-over-week for small accounts, or 10% for large accounts, may be normal variance. Check against historical volatility before investigating.

### Step 2: Isolate the Dimension
Determine which dimension is causing the change by comparing period-over-period across all breakdowns.

**Investigation order** (from most to least common causes):

1. **Audience changes** — Did a specific ad set's performance shift? New audiences added or existing ones exhausted?
2. **Creative changes** — Did creative fatigue set in? Were new creatives launched that underperform?
3. **Auction/competition changes** — Did CPMs increase? (Indicates increased competition or seasonal demand)
4. **Placement changes** — Did the delivery shift to different placements?
5. **External factors** — Seasonality, competitor activity, landing page changes, tracking issues

### Step 3: Drill Down to Root Cause
Once the dimension is isolated, drill deeper.

**Example investigation path for CPA increase:**
```
Account CPA up 30% ──→ Which campaign? ──→ Campaign X
Campaign X CPA up 40% ──→ Which ad set? ──→ Ad Set Y
Ad Set Y CPA up 50% ──→ Why?
  ├── Frequency increased from 2.1 to 3.8 (audience saturation)
  ├── CTR dropped 25% (creative fatigue)
  └── CPM increased 15% (auction competition)
Root cause: Audience saturation + creative fatigue
```

### Step 4: Compare Against Baseline
Use the "two-period comparison" method:

| Metric | Previous Period | Current Period | Change | Significant? |
|--------|----------------|----------------|--------|-------------|
| Spend | | | | |
| Impressions | | | | |
| CPM | | | | |
| CTR | | | | |
| CPC | | | | |
| Conversions | | | | |
| CPA | | | | |
| ROAS | | | | |

The metric that changed first in the chain typically reveals the root cause. If CPM increased but CTR held steady, the issue is auction competition, not creative quality.

### Step 5: Determine Action
Based on root cause, select the appropriate response:

| Root Cause | Action |
|-----------|--------|
| Creative fatigue | Launch new creatives, pause fatigued ones |
| Audience saturation | Expand audience, refresh targeting |
| Auction competition | Adjust bids, shift to less competitive placements/times |
| Landing page issue | Fix page, test alternatives |
| Tracking breakage | Debug Pixel/CAPI, check event firing |
| Seasonality | Adjust targets, don't overreact |
| Algorithm learning | Wait 48-72 hours before making changes |

## Three Analysis Ninja Techniques

### Technique 1: Post-Facto CPA Including Micro-Conversions
Standard CPA only counts the macro conversion. Calculate the "real" CPA including downstream value from micro-conversions.

```
Apparent CPA = Campaign Spend / Macro Conversions
Real CPA = Campaign Spend / (Macro Conversions + Micro-Conversion Value Equivalent)
```

Example: A campaign generates 30 purchases (CPA $16.70) plus 100 email sign-ups that later produce 20 additional purchases. Real CPA = $500 / 50 = $10.00.

### Technique 2: Raw Numbers for Impact
Percentages and ratios can mask the true scale of problems.

Instead of: "CTR is 0.5%"
Present: "For every 1,000 impressions, 5 people clicked. Of those 5, 0.1 converted. That's 1 purchase per 10,000 impressions."

Raw numbers create urgency. Ratios create complacency.

### Technique 3: Convertible Audience Calculation
Not every person who sees an ad is a realistic conversion candidate. Calculate the "real" conversion rate on the convertible audience.

```
Convertible Audience = Total Reach − (Non-target impressions + Already-converted + Frequency > 5)
Real Conversion Rate = Conversions / Convertible Audience
```

This prevents the false despair of a "0.5% conversion rate" when the real convertible conversion rate is 3-5%.

## Meta Ads Application

### Period-over-Period Comparison Checklist

When performance changes significantly, check each factor:

- [ ] **CPM changes** → Auction competition, seasonality, audience quality score
- [ ] **CTR changes** → Creative fatigue, audience-creative mismatch, placement shift
- [ ] **Conversion rate changes** → Landing page issues, tracking problems, audience quality shift
- [ ] **Frequency changes** → Audience saturation, budget vs. audience size mismatch
- [ ] **Delivery changes** → Learning phase re-entry, budget reallocation by algorithm
- [ ] **External factors** → Competitor launches, seasonal patterns, iOS/privacy changes

### Common Misdiagnoses

| Symptom | Common Misdiagnosis | Actual Cause |
|---------|--------------------|----|
| CPA spike after edit | "The change broke it" | Algorithm re-entering learning phase (wait 48h) |
| CTR decline over weeks | "Audience is wrong" | Creative fatigue (check frequency) |
| ROAS drop after scaling | "Can't scale this campaign" | Audience expansion beyond optimal core (check demographic shifts) |
| Sudden zero conversions | "Campaign stopped working" | Pixel/CAPI tracking issue (check Events Manager) |
| Weekend performance dip | "Weekends don't convert" | Different user intent on weekends (check by device and placement) |
