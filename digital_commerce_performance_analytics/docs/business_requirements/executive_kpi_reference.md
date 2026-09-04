# Executive KPI Reference

## Project

Digital Commerce Performance Analytics

## Phase

Phase 7 — Executive KPI Layer

---

# 1. Purpose

This document is the downstream reference for the governed Phase 7 Executive KPI Layer.

It summarizes the final executive models, metric formulas, semantic families, aggregation rules, driver semantics, limitations, and BI consumption requirements.

This document does not redefine KPI logic.

Authoritative business definitions remain governed by the Phase 6 KPI contracts and Phase 7 scope and technical-design documents.

---

# 2. Executive Models

| Model | Grain | Primary Purpose | Primary Upstream Source |
|---|---|---|---|
| `executive_kpi_daily` | one row per `date_day` | Headline executive KPI base | `mart_ecommerce_daily` |
| `executive_kpi_trends_daily` | one row per `date_day` | Rolling seven-day and Week-over-Week trends | `executive_kpi_daily` |
| `executive_channel_drivers_daily` | one row per `session_date × channel_key` | Governed channel contribution and conversion drivers | `mart_channel_daily` |

The headline KPI branch and channel-driver branch contain different analytical populations and must not be combined solely because they share calendar dates.

---

# 3. Headline Executive KPI Reference

| KPI | Field | Semantic Family | Governed Formula |
|---|---|---|---|
| Session Count | `session_count` | Session-date | additive governed session count |
| Purchasing Session Count | `purchasing_session_count` | Session-date | additive governed purchasing-session count |
| Conversion Rate | `conversion_rate` | Session-date | `purchasing_session_count / session_count` |
| Transaction Count | `transaction_count` | Transaction-date | additive governed transaction count |
| Purchase Revenue | `purchase_revenue` | Transaction-date | additive governed purchase revenue |
| Average Order Value | `average_order_value` | Transaction-date | `purchase_revenue / transaction_count` |
| Revenue per Session | `revenue_per_session` | Session-cohort | `session_attributed_purchase_revenue / session_count` |

Safe division is required for governed ratios.

A shared `date_day` does not mean all headline KPIs use the same underlying business-event date.

---

# 4. Supporting Executive Base Fields

The following additive components are retained to support correct downstream reaggregation:

- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`

These are session-attributed commercial measures.

They must remain distinguishable from:

- transaction-date `transaction_count`
- transaction-date `purchase_revenue`

---

# 5. Period Reaggregation Rules

Additive measures may be summed across compatible reporting periods.

Ratio metrics must be recalculated from their governed additive components.

## Conversion Rate

```text
SUM(purchasing_session_count)
/
SUM(session_count)
```

Do not use:

```text
AVG(conversion_rate)
```

## Average Order Value

```text
SUM(purchase_revenue)
/
SUM(transaction_count)
```

Do not use:

```text
AVG(average_order_value)
```

## Revenue per Session

```text
SUM(session_attributed_purchase_revenue)
/
SUM(session_count)
```

Do not calculate revenue per session using transaction-date purchase revenue.

---

# 6. Executive Trend Reference

## 6.1 Rolling Window

The governed short-term executive trend window is:

```text
current date + previous 6 calendar dates
```

The current reporting date is included.

Early observations may use fewer than seven dates when earlier governed history is unavailable.

Missing pre-observation history is not fabricated.

---

# 7. Rolling Revenue

## Metric

`revenue_7d`

## Formula

```text
SUM(purchase_revenue)
over current date and previous 6 dates
```

## Semantic Family

Transaction-date.

---

# 8. Rolling Conversion

Supporting fields:

- `sessions_7d`
- `purchasing_sessions_7d`

Governed formula:

```text
conversion_rate_7d
=
purchasing_sessions_7d
/
sessions_7d
```

The rolling conversion rate must not be calculated as the average of daily conversion rates.

Semantic family:

Session-date.

---

# 9. Week-over-Week Revenue

The governed comparison is:

> Current rolling seven-day revenue versus the rolling seven-day revenue ending seven calendar dates earlier.

Fields:

- `revenue_7d`
- `revenue_previous_7d`
- `revenue_wow_absolute_change`
- `revenue_wow_pct_change`

Absolute change:

```text
revenue_7d
-
revenue_previous_7d
```

Percentage change:

```text
(revenue_7d - revenue_previous_7d)
/
revenue_previous_7d
```

When the prior-period denominator is zero or unavailable, the percentage change is `NULL`.

---

# 10. Week-over-Week Conversion

Fields:

- `conversion_rate_7d`
- `conversion_rate_previous_7d`
- `conversion_wow_absolute_change`
- `conversion_wow_pct_change`

Absolute change:

```text
conversion_rate_7d
-
conversion_rate_previous_7d
```

The absolute change is expressed in rate units and may be formatted in BI as percentage points.

Percentage change:

```text
(conversion_rate_7d - conversion_rate_previous_7d)
/
conversion_rate_previous_7d
```

When the prior-period denominator is zero or unavailable, the percentage change is `NULL`.

---

# 11. Channel Driver Reference

The governed channel-driver model is:

`executive_channel_drivers_daily`

Grain:

```text
session_date × channel_key
```

Channel attributes:

- `channel_key`
- `channel_group`
- `channel_description`
- `sort_order`

Base driver measures:

- `session_count`
- `purchasing_session_count`
- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`

---

# 12. Channel Conversion

## Metric

`conversion_rate`

## Formula

```text
channel purchasing_session_count
/
channel session_count
```

This measures conversion efficiency within the governed channel.

It is not a contribution metric.

---

# 13. Channel Contribution Metrics

## Session Contribution

```text
session_contribution
=
channel session_count
/
daily total session_count
```

## Purchasing Session Contribution

```text
purchasing_session_contribution
=
channel purchasing_session_count
/
daily total purchasing_session_count
```

## Transaction Contribution

```text
transaction_contribution
=
channel session-attributed transaction count
/
daily total session-attributed transaction count
```

## Revenue Contribution

```text
revenue_contribution
=
channel session-attributed purchase revenue
/
daily total session-attributed purchase revenue
```

All contribution numerators and denominators must use compatible semantic populations.

---

# 14. Driver Reaggregation Rules

Daily contribution percentages are non-additive across dates.

Do not use:

```text
SUM(revenue_contribution)
```

or:

```text
AVG(revenue_contribution)
```

for a multi-day contribution.

Instead recalculate from additive components:

```text
SUM(channel session-attributed purchase revenue)
/
SUM(total session-attributed purchase revenue)
```

The same principle applies to:

- session contribution
- purchasing-session contribution
- transaction contribution
- channel conversion rate

---

# 15. Semantic Compatibility Rules

The following distinction is mandatory.

## Transaction-Date Commercial Metrics

- `transaction_count`
- `purchase_revenue`
- `average_order_value`
- `revenue_7d`
- revenue WoW metrics

These answer questions about commercial activity occurring on the transaction date.

## Session-Date Metrics

- `session_count`
- `purchasing_session_count`
- `conversion_rate`
- session rolling metrics
- conversion rolling and WoW metrics

These answer questions about sessions occurring on the session date.

## Session-Cohort / Session-Attributed Metrics

- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`
- `revenue_per_session`
- channel transaction contribution
- channel revenue contribution

These describe commercial outcomes attributed back to the originating session population.

Metrics from different semantic families must not be combined into new ratios unless an explicit governed contract permits it.

---

# 16. Explicitly Invalid Calculations

The following calculations are not governed:

```text
transaction-date purchase_revenue
/
session-date session_count
```

as revenue per session.

Likewise:

```text
transaction-date transaction_count
/
session-date purchasing_session_count
```

must not be interpreted as transactions per purchasing session.

Channel session-attributed commercial measures must not use transaction-date executive totals as their contribution denominators.

---

# 17. Downstream BI Responsibilities

BI may:

- aggregate governed additive measures
- recalculate governed ratios from compatible additive components
- use supplied rolling and WoW metrics
- format rates and contributions as percentages
- format conversion absolute change as percentage points
- filter and sort by governed channel attributes
- create presentation-oriented labels and navigation

BI must not:

- redefine governed KPI formulas
- average daily KPI ratios to create period-level KPIs
- sum contribution percentages across dates
- mix transaction-date and session-attributed commercial populations
- rebuild sessionization or attribution logic
- introduce alternative channel classification
- infer unsupported customer identity
- introduce unsupported attribution models

---

# 18. Current Scope Limitations

The current Executive KPI Layer does not govern:

- net revenue
- ROAS
- customer acquisition cost
- cost per acquisition
- profit
- gross margin
- authenticated customer counts
- customer lifetime value
- customer retention
- multi-touch attribution
- paid-media attribution

`refund_value` must not automatically be subtracted from `purchase_revenue` to create an undocumented net-revenue KPI.

`user_pseudo_id` must not be interpreted as authenticated customer identity.

---

# 19. Reconciliation Controls

Phase 7 outputs are protected by dbt reconciliation and semantic validation tests covering:

- executive base reconciliation to `mart_ecommerce_daily`
- executive trend reconciliation to `executive_kpi_daily`
- rolling-history semantics
- channel-driver reconciliation to `mart_channel_daily`
- channel-driver composite grain
- channel contribution behavior
- end-to-end reconciliation across executive base, trend, and driver branches

The end-to-end reconciliation intentionally compares only semantically compatible populations.

---

# 20. Consumption Principle

The Executive KPI Layer is the governed analytical interface for executive reporting.

Its purpose is to provide stable KPI, trend, and driver outputs without moving business logic into the BI layer.

When a downstream reporting requirement cannot be produced from the documented governed fields without introducing a new formula, attribution rule, semantic population, or unsupported metric, the requirement must be treated as a new analytics-engineering design change rather than implemented ad hoc in BI.