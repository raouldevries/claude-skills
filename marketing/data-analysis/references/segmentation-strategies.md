# Segmentation Strategies

Frameworks for segmenting campaign data to find actionable insights hidden in aggregate metrics, adapted from Avinash Kaushik's segmentation principles.

## Core Principle

In aggregate, almost all data is useless. The rallying cry: **Segment or Die.**

Averages conceal all the interesting information beneath the surface. A "3% conversion rate" hides the fact that one audience converts at 8% and another at 0.5%. Segmentation reveals causes; aggregation hides them.

## Three Categories of Segments

Every meaningful segment falls into one of three categories:

### 1. Acquisition Segments
How people arrived. Segments by source, campaign, creative, or targeting.

| Segment | What It Reveals | Meta Ads Dimension |
|---------|----------------|-------------------|
| By campaign objective | Which funnel stage performs best | Campaign |
| By audience type | Which targeting approach delivers results | Ad set |
| By creative format | Which format drives engagement | Ad (image vs. video vs. carousel) |
| By placement | Where ads perform best | Placement (Feed, Stories, Reels, etc.) |
| By device | Mobile vs. desktop behavior | Device platform |

### 2. Behavior Segments
What people did after seeing or clicking the ad.

| Segment | What It Reveals | How to Measure |
|---------|----------------|---------------|
| Non-flirts (3+ page views) | Engaged visitors worth analyzing | Analytics: session depth > 2 |
| Quick converters (same session) | Impulse buyers / high-intent audiences | Attribution: 0-day conversion |
| Slow converters (7+ days) | Research-heavy buyers needing nurture | Attribution: 7-28 day conversion window |
| Cart abandoners | Conversion friction points | Pixel: AddToCart without Purchase |
| Repeat visitors | Brand loyalty signals | Frequency > 3 in attribution window |

### 3. Outcome Segments
What results people produced.

| Segment | What It Reveals | How to Measure |
|---------|----------------|---------------|
| High-value customers (AOV > 2x average) | "Whale" profile to replicate | Purchase value filter |
| Multi-purchasers | Best customers for lookalikes | Custom audience: 2+ purchases |
| Micro-converters only | Nurture opportunities | Goal completion without macro conversion |
| Zero-outcome visits | Wasted spend candidates | Clicks with no conversion events |

## The "Non-Flirts" Approach

Instead of analyzing bounced or non-converting traffic (the "flirts"), focus first on people who gave the campaign a chance — those who engaged meaningfully.

**Application to Meta Ads:**
1. Identify the engagement threshold (e.g., landing page view + at least one additional action)
2. Segment to show only visitors who exceeded that threshold
3. Analyze what made them engage: which creative, which audience, which placement
4. Scale what's working for the engaged group, rather than trying to fix what's broken for the disengaged

This approach is more productive than obsessing over high bounce rates or low CTR.

## Value-Based Segmentation

Segment customers by total value, not just conversion count.

### Process
1. Export customer data with total purchase value over 6-12 months
2. Rank by total value and divide into quartiles
3. Profile each quartile: acquisition source, first product, demographics
4. Use top-quartile profile to build lookalike audiences

### Common Findings
- Top 20% of customers generate 60-80% of revenue
- High-value customers often come from "expensive" channels (high CPA but high LTV)
- First purchase category predicts long-term value
- Geographic clusters of high-value customers often exist

## Meta Ads Application

### Segmentation in Ads Manager

Use breakdowns to segment performance data:

| Breakdown Type | Dimensions Available |
|---------------|---------------------|
| **Delivery** | Age, gender, placement, device, platform, region, time of day |
| **Action** | Conversion device, destination, video view type |
| **Time** | Day, week, 2 weeks, month |

### Building Analysis Segments

**Step 1: Start broad** — Compare performance by campaign objective type
**Step 2: Go one level deeper** — Within best-performing campaign, compare by ad set (audience)
**Step 3: Go to creative level** — Within best ad set, compare by creative
**Step 4: Cross-cut** — Apply placement and device breakdowns to best performers

### Advanced Segmentation via Custom Audiences

Create segments for deeper analysis:

| Segment | Custom Audience Definition | Analysis Purpose |
|---------|--------------------------|-----------------|
| High-intent visitors | ViewContent + AddToCart, no Purchase (last 7 days) | Cart abandonment analysis |
| Engaged prospects | 75% video view or 2+ page views, no conversion (last 30 days) | Nurture opportunity sizing |
| Best customers | Top 25% by purchase value (last 180 days) | Lookalike seed analysis |
| Churned customers | Purchased 90+ days ago, no recent activity | Win-back campaign sizing |
| Multi-touch converters | Converted after 3+ ad interactions | Attribution pattern analysis |

### Segmentation Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Only analyzing aggregate account metrics | Hides all actionable variation | Break down every metric by at least one dimension |
| Segmenting too finely | Small sample sizes, unreliable data | Minimum 100 conversions per segment for statistical reliability |
| Only segmenting winners | Misses the "why" behind failures | Segment both best and worst performers |
| Static segments | Audiences evolve; yesterday's segment may be stale | Refresh segment definitions quarterly |
| Ignoring the "middle" | Focus on best/worst ignores the bulk | Analyze median performers for scale opportunities |
