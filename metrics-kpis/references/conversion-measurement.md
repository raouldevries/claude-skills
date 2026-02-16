# Conversion Measurement: Macro, Micro & Economic Value

Framework for measuring complete campaign success beyond a single conversion metric, using macro/micro conversion classification and economic value assignment.

## The Macro/Micro Conversion Framework

Most campaigns optimize for a single conversion (purchase, lead). This captures only 2-5% of visitor activity. The rest is invisible — and often more valuable than it appears.

**Macro conversions**: The primary desired outcome of the campaign. The main reason the campaign exists.

**Micro conversions**: Secondary outcomes that indicate progress toward the macro conversion or create independent business value.

Key principle: Micro conversions do not need to lead directly to the macro conversion. They create independent value (brand lift, data collection, future remarketing audiences).

### Macro + Micro = Complete Measurement

```
Total Campaign Value = Macro Conversion Value + Sum(Micro Conversion Values)
```

For most businesses, the economic value of micro conversions is routinely 3-4x the macro conversion value.

## Identifying Macro and Micro Conversions

### By Campaign Objective

| Campaign Type | Macro Conversion | Micro Conversions |
|--------------|-----------------|-------------------|
| E-commerce (Sales) | Purchase | Add to cart, initiate checkout, view product, wishlist add, email sign-up |
| Lead Generation | Qualified lead submitted | Content download, pricing page view, demo video watched, newsletter sign-up |
| App Promotion | App install | Registration complete, first action, tutorial complete, in-app purchase |
| Brand Awareness | — (use micro only) | Video view (75%+), profile visit, page like, save, share |
| Traffic/Content | — (use micro only) | Scroll depth >75%, 2+ pages viewed, time on site >60s, email sign-up |

### Classification Rules

1. Each campaign should have exactly 1 macro conversion (or none for awareness)
2. Identify 3-5 micro conversions per campaign
3. Every micro conversion must pass the "so what" test — it must indicate genuine business value
4. Track micro conversions even when macro conversion is the optimization target

## Assigning Economic Value

Every conversion — macro and micro — needs an economic (goal) value. Without values, optimization is impossible.

### Five Techniques for Assigning Goal Values

**Technique 1: Direct Revenue Tracking**
For e-commerce, the value is the transaction amount. Track via Meta Pixel or Conversions API with purchase value parameter.

**Technique 2: Offline Conversion Matching**
Track online micro-conversions (lead form, quote request) through the offline pipeline. After 30-60 days, calculate:
> Average goal value = Total revenue from web-originated leads / Number of web leads

Update quarterly. Use Meta's Offline Conversions API to feed this data back for optimization.

**Technique 3: Borrow the Finance Number**
Ask the finance team what they currently value equivalent offline activities at. If a direct mail catalog costs $2.50 per send and converts at 3%, and your digital catalog request has a 6% conversion rate, the digital request is worth at least $5.00.

Use existing offline attribution models as starting points — they already have stakeholder buy-in.

**Technique 4: Relative Goal Values**
When no direct measurement exists, use relative valuation:

1. Rank all conversions by business importance
2. Anchor to the one conversion with a known value
3. Assign relative values through stakeholder consensus

Example for a SaaS campaign:
| Conversion | Relative Value |
|-----------|---------------|
| Free trial start (macro) | $50 (known: 10% convert to $500/yr plan) |
| Demo video watched | $5 (10% of trial value) |
| Pricing page view | $8 (indicates active evaluation) |
| Content download | $3 (early-stage interest) |
| Newsletter sign-up | $2 (future nurture opportunity) |

**Technique 5: The $1 Default**
Last resort when no one will help with valuation. Assign $1 to every goal. Report on "economic value per visit" segmented by source. When stakeholders see $1 values driving reporting, they will engage to provide real numbers.

### Value Assignment Principles

- Review and update goal values quarterly
- Values should reflect business reality, not analytics precision
- An imperfect value is infinitely more useful than no value
- Segment by acquisition source to detect value differences across channels
- Start with best estimates and refine with data over time

## Meta Ads Application

### Pixel Event Mapping to Macro/Micro

Configure the Meta Pixel (or Conversions API) to fire events for both macro and micro conversions:

| Standard Event | Type | Value Assignment |
|---------------|------|-----------------|
| `Purchase` | Macro | Transaction value |
| `Lead` | Macro | Average lead value from CRM |
| `CompleteRegistration` | Micro | Relative to macro |
| `AddToCart` | Micro | % of purchase value × cart completion rate |
| `InitiateCheckout` | Micro | % of purchase value × checkout completion rate |
| `ViewContent` | Micro | Relative value based on content type |
| `Subscribe` | Micro | Projected LTV of subscriber |
| `Contact` | Micro | % of contact-to-customer conversion × average deal |

### Using Economic Value for Optimization

1. **Bid strategy**: Use value-based bidding (Highest Value or Minimum ROAS) with accurate conversion values
2. **Audience evaluation**: Compare total economic value per audience, not just macro conversion rate
3. **Creative testing**: Evaluate creatives on total conversion value generated, not single-event performance
4. **Budget allocation**: Shift budget to campaigns generating highest total economic value, including micro-conversion value
5. **Attribution windows**: Set attribution windows based on typical days-to-conversion data for each event type

### Conversions API Integration

For accurate micro-conversion tracking:
- Send server-side events for offline conversions (phone calls, in-store visits, lead qualification)
- Match using hashed email, phone, or fbclid
- Include `event_value` with every event for economic value tracking
- Deduplicate with Pixel events using `event_id`
