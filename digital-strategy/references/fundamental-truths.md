# Fundamental Analytics Truths

Ten core principles for building a data-driven digital marketing practice, adapted from Avinash Kaushik's ground truths. These principles cut through vendor hype and common misconceptions.

## The Ten Truths

### 1. One Source of Truth
Use one analytics system as the single source of truth for each data domain. Multiple overlapping tools create a data reconciliation organization, not a data analysis organization.

**Meta Ads application**: Ads Manager is the source of truth for campaign delivery metrics (impressions, clicks, spend). Your analytics platform (GA4, etc.) is the source of truth for on-site behavior. Do not attempt to reconcile the two — they use different methodologies and will never match. Accept directional alignment.

### 2. Tools Don't Save You — You Save Yourself
No tool, no matter how expensive, delivers insights automatically. Tools deliver data. People deliver insights through analysis, context, and business understanding.

**Meta Ads application**: A $50K analytics suite provides no value without analysts who understand the business. Start with the free tools (Ads Manager, Events Manager) and invest in analytical skill before investing in additional tools.

### 3. Fail Fast, Learn Fast
It is faster and cheaper to test something than to find a case study proving it works for someone else. The web makes experimentation nearly free.

**Meta Ads application**: Don't wait for perfect strategy. Launch a small test (10% of budget), measure results after 7 days, learn, iterate. A $500 test answers more questions than a $50,000 strategy document.

### 4. Get Expert Help on Retainer
The field changes too fast for any in-house team to stay current on everything. A practitioner consultant (one who does the work, not just advises) on retainer is more cost-effective than spending weeks figuring things out alone.

**Meta Ads application**: Meta's ad platform changes quarterly. Attribution models, creative formats, targeting options, and optimization algorithms evolve constantly. Budget for expert consultation alongside media spend.

### 5. Focus on Customer Happiness and Bottom Line
Every analysis should connect to one of three outcomes: more revenue, reduced cost, or increased customer satisfaction. If analysis doesn't connect to one of these, it's a waste of time.

**Meta Ads application**: Before producing any report, ask: "What action will someone take based on this data?" If no action, don't report it. Replace weekly data dumps with actionable recommendations.

### 6. Kill 25% of Metrics Annually
Business priorities, marketing strategies, available technologies, and organizational skills change. Measurement must change with them. If your dashboard looks the same as last year, it's stale.

**Meta Ads application**: Review KPIs quarterly. Last quarter's focus on CPL may be irrelevant if the business shifted to an e-commerce model. Remove metrics nobody acts on. Add metrics for new initiatives.

### 7. Be Skeptical of Data Warehousing Promises
Massive data integration projects frequently over-promise and under-deliver. Start with the simplest analysis that answers the business question, not the most comprehensive data infrastructure project.

**Meta Ads application**: You don't need a data warehouse to get 80% of the insights. Ads Manager + a spreadsheet for trend tracking + Conversions API for offline events covers most needs. Only invest in warehouse infrastructure when the simple approach is genuinely insufficient.

### 8. Multichannel Attribution Has No Magic Bullet
No single tool or model perfectly attributes value across all channels. The problem is fundamentally about missing data (the "primary key" connecting the same person across touchpoints).

**Meta Ads application**: Use a portfolio of attribution approaches (see `multichannel-attribution.md`). Don't rely on any single attribution model. Use incrementality tests to validate what other models suggest.

### 9. Experiment or Die
Testing is not optional. Questions about creative effectiveness, audience quality, bid strategy, and landing page performance cannot be answered with historical analysis alone. Only controlled experiments reveal causation.

**Meta Ads application**: Run at least one A/B test per month (creative, audience, or landing page). Use Meta's Experiments feature for statistical rigor. Test big things that matter (different value propositions, audience strategies), not trivial things (button colors).

### 10. Build a Data-Driven Culture Through Results
You cannot convince stakeholders with opinions or data pukes. Demonstrate value by:
1. Showing competitive intelligence that reveals gaps
2. Sharing customer voice data (survey results, reviews)
3. Delivering quick wins that save money or increase revenue
4. Framing recommendations in business language, not analytics jargon

**Meta Ads application**: Don't present CTR and CPM tables. Present: "We're spending $X on audience Y that generates $0 in revenue. Shifting that budget to audience Z would generate an estimated $Y based on its current performance."

## Seven Steps to a Data-Driven Culture

From Kaushik's framework for organizational change:

1. **Start with quick wins** — Find one obvious waste and fix it. Results build credibility.
2. **Speak in business outcomes** — Revenue, profit, growth rate. Not impressions, CTR, CPM.
3. **Use competitive data** — Nothing motivates action faster than showing competitors outperforming.
4. **Democratize data access** — Make dashboards self-serve so stakeholders can answer their own questions.
5. **Celebrate testing** — Reward teams that test, even when tests fail (learning has value).
6. **Kill vanity metrics** — Remove any metric that makes people feel good but drives no action.
7. **Align incentives** — Ensure the metrics you measure align with how people are compensated and promoted.

## Meta Ads Application: The 10/90 Rule

Invest 10% in tools and 90% in people and processes.

| Investment | 10% (Tools) | 90% (People & Process) |
|-----------|-------------|----------------------|
| Budget | Ads Manager (free), Pixel setup, CAPI | Analyst time, creative development, testing |
| Time | Tool configuration, report setup | Analysis, strategy, optimization decisions |
| Focus | Data collection accuracy | Data interpretation and action |

An account with perfect tracking but no analyst is worth less than an account with basic tracking and a skilled analyst who acts on insights weekly.
