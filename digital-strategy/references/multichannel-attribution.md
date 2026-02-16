# Multichannel Attribution & Cross-Channel Measurement

Framework for measuring impact across channels, tracking offline conversions, and understanding the complete customer journey.

## The Multichannel Challenge

The world is not online or offline — it is "nonline." Customers move between channels: they see a Meta ad, search on Google, visit a store, and buy online. Measuring only the last touchpoint dramatically misattributes value.

The fundamental problem: **the missing primary key.** Connecting the same person across multiple touchpoints and channels requires deliberate tracking infrastructure.

## Five Strategies for Cross-Channel Measurement

### Strategy 1: Vanity URLs and Redirects
For offline-to-online tracking, use memorable URLs in offline media that redirect to campaign-tagged landing pages.

**Meta Ads application**: When running campaigns that drive offline action (store visits, phone calls), create dedicated landing pages with UTM parameters that distinguish Meta-originated traffic from other sources.

### Strategy 2: Unique Offer Codes
Use channel-specific offer codes to track which media drove the action.

**Meta Ads application**:
- Include unique promo codes in ad creative (e.g., "Use code META20")
- Track code redemption in e-commerce system
- Match codes to campaigns for attribution
- Use the same code across online and offline to measure channel preference

### Strategy 3: Correlation Analysis
Overlay media schedules with traffic and conversion patterns to detect the online impact of all marketing activities.

**Meta Ads application**:
- Compare branded search volume during Meta campaign flights vs. off periods
- Track direct traffic changes correlated with Meta Ads awareness campaigns
- Measure total conversion volume across all channels during campaign periods (not just Meta-attributed conversions)

### Strategy 4: Survey-Based Attribution
Use post-purchase or on-site surveys to ask customers about their journey.

**Meta Ads application**:
- Post-purchase survey: "How did you first hear about us?" with Meta/Facebook/Instagram as options
- Use Meta's conversion lift studies to measure incremental impact
- Deploy brand lift studies for awareness campaign attribution

### Strategy 5: Controlled Experiments
The gold standard. Run geographic or audience holdout tests to measure true incremental impact.

**Meta Ads application**:
- **Geographic lift test**: Run Meta Ads in Region A, not in Region B, compare total sales
- **Conversion lift study**: Meta shows ads to test group, holds out control group, measures incremental conversions
- **Incrementality test**: Pause Meta Ads for 2 weeks in one market, compare to a running market

## Meta-Specific Attribution Tools

### Conversions API (CAPI)
Server-side event tracking that captures conversions Meta's Pixel cannot.

**Key use cases**:
- **Offline conversions**: Upload in-store purchases matched to Meta ad exposure via hashed customer data (email, phone)
- **Phone call conversions**: Track calls driven by Meta Ads using call tracking + CAPI integration
- **CRM events**: Send lead qualification, deal closed, and LTV events back to Meta for optimization
- **Cross-device attribution**: Server-side matching provides better cross-device coverage than browser-only Pixel

### Attribution Settings

| Setting | Option | When to Use |
|---------|--------|------------|
| Attribution window | 1-day click | Products with short consideration cycle, impulse purchases |
| | 7-day click (default) | Most e-commerce and lead gen campaigns |
| | 7-day click, 1-day view | When view-through credit matters (video/awareness campaigns) |
| | 28-day click | Long consideration cycles (B2B, high-ticket items) |
| Optimization | Conversions | Enough conversion volume (50+/week per ad set) |
| | Value | High-volume accounts with variable order values |

### Multi-Touch Attribution Approaches

| Model | How It Works | Best For |
|-------|-------------|----------|
| Last-click | 100% credit to last touchpoint | Simple analysis, bottom-funnel campaigns |
| First-click | 100% credit to first touchpoint | Understanding acquisition channel value |
| Linear | Equal credit to all touchpoints | When all stages contribute equally |
| Time-decay | More credit to closer touchpoints | Moderate consideration cycles |
| Data-driven | ML model assigns credit based on patterns | Large accounts with rich conversion data |

Meta Ads uses a default last-touch attribution model. For multi-touch analysis, export data and use external attribution tools or Meta's built-in attribution comparison reports.

## Building a Multichannel Measurement Framework

### The Nonline Tracking Flow

```
Offline Stimulus ──→ Online Behavior ──→ Offline/Online Outcome
(TV ad, print, event)  (Website visit, ad click)  (In-store purchase, online order)
```

Track both directions:
- **Offline → Online**: Vanity URLs, offer codes, traffic correlation, surveys
- **Online → Offline**: CAPI offline events, call tracking, in-store attribution, geo-testing

### Implementation Priorities

1. **Foundation** (implement first):
   - Meta Pixel on all conversion pages
   - Conversions API for server-side event deduplication
   - UTM parameters on all campaign links

2. **Intermediate** (implement second):
   - Offline conversion uploads via CAPI (store visits, phone calls)
   - Cross-channel attribution reporting
   - Branded search correlation analysis

3. **Advanced** (implement when ready):
   - Conversion lift studies
   - Geographic incrementality tests
   - Multi-touch attribution modeling
   - Marketing mix modeling (MMM)

### Common Attribution Mistakes

| Mistake | Consequence | Fix |
|---------|------------|-----|
| Only measuring last-click Meta conversions | Undervalues awareness and consideration campaigns | Use view-through attribution for upper-funnel campaigns |
| Ignoring offline conversions | Undervalues campaigns that drive store/phone activity | Implement CAPI offline event uploads |
| Different attribution windows across channels | Apples-to-oranges channel comparison | Standardize attribution windows for cross-channel analysis |
| No incrementality testing | Unclear if Meta Ads are driving net-new conversions or cannibalizing organic | Run conversion lift or holdout tests quarterly |
| Crediting Meta for branded search conversions | Inflates Meta's contribution | Segment branded vs. non-branded conversions; use incrementality tests |
