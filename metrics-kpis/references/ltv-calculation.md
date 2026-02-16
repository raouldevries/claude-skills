# Customer Lifetime Value (LTV) Calculation

Framework for computing Customer Lifetime Value and applying it to acquisition strategy and bid optimization.

## Why LTV Matters for Acquisition

Single-session metrics (CPA, conversion rate) evaluate only the first transaction — a "one night stand." LTV answers three fundamental questions:

1. **Did you pay enough** to acquire customers from each channel?
2. **Did you acquire the right kind** of customers?
3. **How much can you spend** on retention to keep them buying?

Channels with high CPA may deliver customers with 3-5x higher lifetime value. Without LTV, budget decisions systematically underspend on high-value channels and overspend on low-value ones.

## LTV Calculation Framework

### Basic LTV Formula

```
LTV = Average Order Value × Purchase Frequency × Customer Lifespan
```

### Net Profit LTV (Recommended)

```
Net LTV = (AOV × Gross Margin %) × Purchase Frequency × Customer Lifespan − Acquisition Cost
```

### Segmented LTV Comparison

The power of LTV is in segment comparison, not averages. Compare LTV across:

| Segment Dimension | What It Reveals |
|------------------|-----------------|
| Acquisition channel | Which channels bring the most valuable long-term customers |
| First purchase category | Which entry products predict high lifetime value |
| Geographic region | Where the most valuable customers are located |
| Time to first purchase | Whether quick converters or slow researchers have higher LTV |

### Step-by-Step LTV Analysis

1. **Pull customer data** for the past 2-3 years (orders, revenue, acquisition source)
2. **Segment** by acquisition channel or campaign type
3. **Calculate per-segment**: Average orders per year, average order value, gross margin, retention rate
4. **Model forward** 1-3 years using observed retention rates
5. **Subtract acquisition cost** per segment to get Net LTV
6. **Compare segments** to identify where to increase or decrease acquisition spend

### Value-Based Segmentation Model

| Metric | Average Customer | Best Customer |
|--------|-----------------|---------------|
| Year 1 orders | 2 | 4 |
| Average order value | $80 | $112 (+40%) |
| Year 1 gross profit | $48 | $134 |
| Acquisition cost | $20 | $28 |
| Year 1 net profit | $28 | $106 |
| Retention rate | 20% | 55% |
| 3-year net profit | $42 | $285 |

Spending $8 more to acquire a "best" customer yields $243 more in 3-year net profit.

### Retention Economics

The cost of retaining a customer is typically 5-20x less than acquiring a new one.

```
Retention ROI = (LTV increase from retention) − (Retention marketing cost)
```

If increasing repeat purchase rate from 20% to 40% through $1/customer retention spend avoids $20/customer acquisition cost, the net saving is $19 per retained customer.

## Meta Ads Application

### LTV-Based Bid Strategy

1. **Calculate segment-level LTV** by campaign or ad set (using offline data joined with Meta attribution)
2. **Set target CPA by segment**: Target CPA = LTV × Acceptable Acquisition Cost Ratio (typically 20-33% of first-year LTV)
3. **Use value-based optimization**: Pass predicted LTV as the conversion value in Meta's optimization, not just first-purchase value

### Configuring Value-Based Bidding

For campaigns optimizing on `Purchase`:
- Instead of passing the first order value, pass the predicted LTV for the customer segment
- Use Conversions API to update conversion values retroactively as repeat purchases occur
- Set campaign bid strategy to "Highest Value" or "Minimum ROAS" using LTV-adjusted values

### LTV-Informed Audience Strategy

| LTV Insight | Meta Ads Action |
|------------|-----------------|
| Channel X delivers 2x LTV | Increase budget allocation to Channel X campaigns |
| Customers who buy Product A have 3x LTV | Create lookalike audiences from Product A buyers |
| Repeat buyers have specific demographic profile | Layer demographic targeting on prospecting campaigns |
| First-purchase AOV > $100 predicts high LTV | Optimize for high-value first purchases using minimum ROAS |
| Email subscribers have 40% higher LTV | Value email sign-up micro-conversion at 40% premium |

### Practical LTV Data Sources

| Data Source | What It Provides |
|------------|-----------------|
| Shopify/WooCommerce | Order history, repeat purchase rate, AOV by segment |
| CRM (HubSpot, Salesforce) | Lead-to-customer conversion rate, deal value, retention |
| Meta Ads + Conversions API | Acquisition source linked to downstream conversions |
| Finance team | Gross margins, acceptable CAC ratios, retention costs |
| Google Analytics / GA4 | Cross-channel attribution, user lifetime value reports |

### LTV Calculation Checklist

- [ ] Identify available customer data sources (e-commerce platform, CRM, ERP)
- [ ] Pull minimum 12 months of order data per customer
- [ ] Segment by acquisition channel (Meta Ads, Google, organic, etc.)
- [ ] Calculate AOV, purchase frequency, retention rate per segment
- [ ] Model 1-year and 3-year LTV per segment
- [ ] Set Meta Ads target CPA at 20-33% of first-year LTV per segment
- [ ] Configure value-based bidding with LTV-adjusted conversion values
- [ ] Schedule quarterly LTV refresh to keep targets current
