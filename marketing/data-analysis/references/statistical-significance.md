# Statistical Significance for Campaign Analysis

Framework for determining when performance differences are real signals versus random noise.

## Core Principle

The goal of statistical significance is to separate **signal** from **noise**. A campaign with 1.2% conversion rate vs. another at 1.0% may appear better — but with small sample sizes, that difference could be random chance.

Three benefits of applying statistical significance:
1. **Remove opinion** — "According to statistics, here are the results" beats "I think this campaign is better"
2. **Focus on signal quality** — Report only differences that are real, not noise
3. **Drive action** — Either the difference is significant (act on it) or it isn't (keep testing). No endless debate.

## When to Apply Statistical Significance

| Decision | Apply Stats? | Minimum Sample |
|----------|-------------|---------------|
| Which creative wins an A/B test | Yes, always | 100+ conversions per variant |
| Is this week's CPA spike real or noise? | Yes | Compare to 4+ weeks of baseline data |
| Which audience performs better | Yes | 50+ conversions per audience |
| Should I pause this campaign? | Yes | At least 7 days of data |
| Which placement converts best? | Usually | 30+ conversions per placement |
| Daily performance fluctuations | No — too noisy | Wait for weekly trends |

## Key Concepts

### Confidence Level
The probability that the observed difference is not due to chance.

- **95% confidence** (standard threshold): 5% chance the result is noise. Use for most decisions.
- **90% confidence** (acceptable): 10% chance of noise. Use for low-stakes decisions or early reads.
- **99% confidence** (high bar): 1% chance of noise. Use for high-stakes decisions (budget reallocation, campaign shutdown).

### Sample Size Requirements

Approximate conversions needed per variant for 95% confidence:

| Baseline Conversion Rate | Minimum Detectable Effect | Required Conversions (per variant) |
|--------------------------|--------------------------|-----------------------------------|
| 1% | 20% relative lift (to 1.2%) | ~16,000 clicks |
| 2% | 20% relative lift (to 2.4%) | ~8,000 clicks |
| 5% | 20% relative lift (to 6%) | ~3,000 clicks |
| 10% | 20% relative lift (to 12%) | ~1,500 clicks |

Smaller expected differences require larger sample sizes. This is why micro-optimizations (button color tests) need enormous traffic to validate.

### Practical Rule: The "50 Conversions" Minimum
For most Meta Ads decisions, a minimum of 50 conversions per option provides a reasonable foundation for comparison. Below 50, treat any difference as preliminary.

## Meta Ads Application

### A/B Testing in Ads Manager

Meta's built-in A/B testing (Experiments) handles statistical significance automatically:
- Set up via Experiments tab in Ads Manager
- Meta determines the winner at the specified confidence level
- Results include estimated lift range and confidence percentage

**Best practices**:
- Run tests for at least 7 days (captures day-of-week variation)
- Test one variable at a time (creative, audience, or placement — not multiple)
- Use the recommended budget split (Meta suggests based on required sample size)
- Don't peek and stop early — let the test run to completion

### Manual Significance Checks

When not using formal A/B tests, apply these rules:

**For creative comparison:**
```
Creative A: 200 clicks, 12 conversions (6.0% CVR)
Creative B: 200 clicks, 8 conversions (4.0% CVR)
```
With only 12 and 8 conversions, this difference is NOT statistically significant. Continue running both.

**For audience comparison:**
```
Audience A: 500 clicks, 45 conversions (9.0% CVR)
Audience B: 500 clicks, 25 conversions (5.0% CVR)
```
With 45 and 25 conversions and a large relative difference (80%), this is approaching significance. Continue collecting data but begin preparing to reallocate.

### Statistical Significance Checklist

Before acting on performance differences:

- [ ] Do both options have 50+ conversions?
- [ ] Has the test run for at least 7 days?
- [ ] Is the relative difference > 20%? (Smaller differences need more data)
- [ ] Have external factors been controlled? (No major budget changes, creative launches, or seasonal events during the test)
- [ ] Is the sample representative? (Not skewed by a single day's anomaly)

If all boxes are checked and the difference exceeds 20% with 50+ conversions each, the result is likely actionable.

### Common Statistical Mistakes in Meta Ads

| Mistake | Problem | Fix |
|---------|---------|-----|
| Declaring a winner after 24 hours | Way too few conversions; random noise dominates | Wait for 50+ conversions per variant minimum |
| Comparing campaigns with different budgets | Delivery differences bias the comparison | Normalize to per-impression or per-click metrics |
| Peeking and stopping early | Inflates false positive rate ("peeking problem") | Pre-set test duration and stick to it |
| Testing multiple variables simultaneously | Cannot isolate which variable caused the difference | Test one variable at a time |
| Ignoring day-of-week effects | Weekday vs. weekend performance varies significantly | Run for full weeks (7, 14, or 21 days) |
