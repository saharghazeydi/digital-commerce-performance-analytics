# Executive KPI Technical Design

## Project

Digital Commerce Performance Analytics

## Phase

Phase 7 — Executive KPI Layer

---

# 1. Purpose

This document defines the technical design of the Executive KPI Layer.

The Executive KPI Layer consumes governed Phase 6 business marts and must not reconstruct upstream sessionization, transaction logic, attribution logic, channel classification, or governed KPI definitions.

The design supports:

- executive KPI calculation
- rolling trend metrics
- period-over-period comparison
- executive driver analysis
- reconciliation and downstream BI consumption

The layer preserves the semantic distinctions established upstream. A shared reporting date does not imply that session-date, transaction-date, and session-cohort metrics belong to the same analytical population.

---

# 2. Executive KPI Base Layer

## 2.1 Model

`executive_kpi_daily`

## 2.2 Grain

One row per:

```text
date_day
```

## 2.3 Primary Input

`mart_ecommerce_daily`

## 2.4 Responsibility

The model exposes the governed headline executive KPI population and the additive components required for correct downstream reaggregation.

It preserves three analytical metric families:

- session-date
- transaction-date
- session-cohort

It must not reinterpret a shared `date_day` as evidence that all metrics have the same underlying event-date semantics.

## 2.5 Headline KPIs

The executive base layer exposes:

- `session_count`
- `purchasing_session_count`
- `transaction_count`
- `purchase_revenue`
- `conversion_rate`
- `average_order_value`
- `revenue_per_session`

Supporting additive components include:

- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`

These components are retained so period-level ratios can be recalculated from compatible numerators and denominators.

## 2.6 Governed Ratio Definitions

`conversion_rate` is calculated as:

```text
purchasing_session_count
/
session_count
```

using session-date semantics.

`average_order_value` is calculated as:

```text
purchase_revenue
/
transaction_count
```

using transaction-date semantics.

`revenue_per_session` is calculated as:

```text
session_attributed_purchase_revenue
/
session_count
```

using session-cohort semantics.

Ratios must be recalculated from compatible additive components when reporting across periods. Daily ratios must not be averaged to produce larger-period KPI values.

---

# 3. Executive Trend Layer

## 3.1 Model

`executive_kpi_trends_daily`

## 3.2 Grain

One row per:

```text
date_day
```

## 3.3 Primary Input

`executive_kpi_daily`

## 3.4 Responsibility

The trend model preserves the governed base executive KPI values while adding rolling seven-day metrics and Week-over-Week comparisons.

It does not reconstruct Phase 6 business logic.

Revenue trend measures retain transaction-date semantics.

Conversion trend measures retain session-date semantics.

---

# 4. Rolling Window Definition

The standard rolling window is:

```text
current date
+
previous 6 calendar dates
```

Therefore each rolling metric represents a maximum seven-calendar-day period ending on `date_day`.

Conceptually:

```text
date_day - 6 days
through
date_day
```

The window includes the current reporting date.

Calendar ordering uses the governed `date_day`.

The executive daily base contains the governed daily date spine required for the row-based seven-day window implementation.

---

# 5. Seven-Day Rolling Revenue

## 5.1 Metric

`revenue_7d`

## 5.2 Definition

```text
SUM(purchase_revenue)

over current date and previous 6 dates
```

## 5.3 Semantic Family

Transaction-date.

The metric represents governed transaction-date purchase revenue occurring during the rolling seven-day period.

It must not use session-attributed purchase revenue.

---

# 6. Seven-Day Rolling Conversion

## 6.1 Supporting Measures

The trend layer calculates:

```text
purchasing_sessions_7d
```

as:

```text
SUM(purchasing_session_count)

over current date and previous 6 dates
```

and:

```text
sessions_7d
```

as:

```text
SUM(session_count)

over current date and previous 6 dates
```

## 6.2 Metric

`conversion_rate_7d`

## 6.3 Definition

```text
purchasing_sessions_7d
/
sessions_7d
```

using safe division.

## 6.4 Semantic Family

Session-date.

The metric must not be calculated as:

```text
AVG(conversion_rate)
```

because daily conversion rates may represent different session populations.

---

# 7. Week-over-Week Comparison Strategy

For the daily executive trend layer, Week-over-Week comparison is defined as:

> Current rolling seven-day period versus the equivalent rolling seven-day period ending seven calendar days earlier.

This provides a like-for-like comparison between equivalent seven-day windows while reducing single-day volatility.

It is intentionally different from comparing only:

```text
current date
vs.
same weekday seven days earlier
```

The latter may be useful for operational daily analysis but is not the governed Phase 7 executive WoW definition.

---

# 8. Week-over-Week Revenue

## 8.1 Current Metric

`revenue_7d`

## 8.2 Prior Metric

`revenue_previous_7d`

The prior-period value is the rolling seven-day revenue associated with:

```text
date_day - 7 days
```

## 8.3 Absolute Variance

```text
revenue_wow_absolute_change
=
revenue_7d
-
revenue_previous_7d
```

## 8.4 Percentage Variance

```text
revenue_wow_pct_change
=
(revenue_7d - revenue_previous_7d)
/
revenue_previous_7d
```

using safe division.

When the prior-period denominator is zero or unavailable, the percentage change returns `NULL`.

---

# 9. Week-over-Week Conversion

## 9.1 Current Metric

`conversion_rate_7d`

## 9.2 Prior Metric

`conversion_rate_previous_7d`

The prior-period value represents the governed seven-day conversion rate for the rolling period ending:

```text
date_day - 7 days
```

## 9.3 Absolute Variance

```text
conversion_wow_absolute_change
=
conversion_rate_7d
-
conversion_rate_previous_7d
```

The absolute change is expressed in rate units.

Downstream BI may format this difference as percentage points.

## 9.4 Percentage Variance

```text
conversion_wow_pct_change
=
(conversion_rate_7d - conversion_rate_previous_7d)
/
conversion_rate_previous_7d
```

using safe division.

When the prior-period denominator is zero or unavailable, the percentage change returns `NULL`.

---

# 10. Early-Window Handling

The dataset begins at a bounded observation date.

For early rows, fewer than seven prior calendar dates may exist.

The governed behavior is:

- rolling metrics may use the available dates within the governed dataset
- prior-period WoW metrics remain `NULL` when the required prior rolling observation is unavailable
- missing history must not be replaced with zero
- the trend layer must not fabricate pre-observation data

Downstream BI may suppress incomplete early-period comparisons where appropriate.

---

# 11. Trend Aggregation Rules

Rolling additive measures may be calculated using windowed sums.

Rolling ratios must be recalculated from rolling additive components.

Therefore:

```text
conversion_rate_7d
=
SUM(purchasing_session_count)
/
SUM(session_count)
```

and not:

```text
AVG(conversion_rate)
```

The same principle applies to any future rolling ratio introduced into the executive layer.

---

# 12. Executive Trend Metric Set

The governed P7C trend set is:

- `revenue_7d`
- `sessions_7d`
- `purchasing_sessions_7d`
- `conversion_rate_7d`
- `revenue_previous_7d`
- `revenue_wow_absolute_change`
- `revenue_wow_pct_change`
- `conversion_rate_previous_7d`
- `conversion_wow_absolute_change`
- `conversion_wow_pct_change`

Supporting rolling numerator and denominator measures are retained because they are required for governed ratio calculation and validation.

---

# 13. Trend Validation Requirements

The trend layer validates that:

- the model remains one row per `date_day`
- base KPI values reconcile to `executive_kpi_daily`
- rolling revenue reproduces independently calculated seven-day transaction-date revenue
- rolling conversion uses rolling purchasing sessions divided by rolling sessions
- rolling conversion is not calculated as the average of daily conversion rates
- prior-period values represent the rolling window ending seven dates earlier
- absolute variance formulas are correct
- percentage variance formulas are correct
- zero denominators return `NULL`
- unavailable prior-period history remains `NULL`
- no row multiplication is introduced

The implemented reconciliation and history-semantics tests enforce these requirements independently of the production trend calculations.

---

# 14. P7C Design Decision

The Phase 7 executive trend layer uses rolling seven-day performance as the primary short-term executive trend perspective.

Week-over-Week comparisons compare the current rolling seven-day period with the equivalent rolling seven-day period ending seven calendar days earlier.

Revenue retains transaction-date semantics.

Conversion retains session-date semantics.

All rolling ratios are recalculated from compatible rolling numerator and denominator measures rather than averaging daily ratios.

---

# 15. Executive Driver Layer

## 15.1 Business Purpose

Headline KPIs explain what happened at the total-business level.

The Executive Driver Layer provides controlled dimensional context for understanding which governed channels contributed to daily performance and how effectively each channel converted its session population.

The driver layer must preserve the attribution semantics established in Phase 6 rather than combining incompatible transaction-date and session-attributed populations.

---

# 16. Channel Driver Model

## 16.1 Model

`executive_channel_drivers_daily`

## 16.2 Grain

One row per:

```text
session_date
×
channel_key
```

## 16.3 Primary Input

`mart_channel_daily`

## 16.4 Responsibility

The model exposes governed daily channel performance and contribution metrics for executive driver analysis.

It consumes the already-governed channel mart and must not reconstruct:

- sessionization
- channel classification
- purchase deduplication
- transaction logic
- revenue logic
- attribution logic

Channel metadata is inherited from the governed upstream channel mart.

---

# 17. Channel Driver Semantic Families

The channel driver model contains two related but distinct semantic families.

## 17.1 Session-Date Measures

The following metrics describe sessions originating on `session_date`:

- `session_count`
- `purchasing_session_count`
- `conversion_rate`
- `session_contribution`
- `purchasing_session_contribution`

## 17.2 Session-Attributed Commercial Measures

The following commercial metrics are attributed to sessions originating on `session_date`:

- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`
- `transaction_contribution`
- `revenue_contribution`

These measures must not be interpreted as transaction-date metrics.

In particular, `session_attributed_purchase_revenue` in the driver layer is not directly interchangeable with transaction-date `purchase_revenue` in `executive_kpi_daily`.

The different naming is intentional and protects downstream consumers from silently mixing attribution populations.

---

# 18. Channel Conversion Rate

## 18.1 Metric

`conversion_rate`

## 18.2 Definition

```text
purchasing_session_count
/
session_count
```

using safe division.

## 18.3 Interpretation

This metric measures the conversion efficiency of the individual governed channel.

It is not a contribution metric.

For example, a channel may have a high conversion rate while representing only a small share of total daily sessions or revenue.

---

# 19. Session Contribution

## 19.1 Metric

`session_contribution`

## 19.2 Definition

```text
channel session_count
/
total session_count for session_date
```

## 19.3 Interpretation

The metric represents the channel's share of the governed session population for the reporting date.

For dates with a valid session population, channel-level session contributions must sum to 1.0 within an accepted floating-point tolerance.

---

# 20. Purchasing Session Contribution

## 20.1 Metric

`purchasing_session_contribution`

## 20.2 Definition

```text
channel purchasing_session_count
/
total purchasing_session_count for session_date
```

using safe division.

## 20.3 Zero-Denominator Behavior

When the total daily purchasing-session population is zero, the metric returns `NULL`.

Zero purchasing activity must not be represented as a fabricated contribution percentage.

---

# 21. Transaction Contribution

## 21.1 Metric

`transaction_contribution`

## 21.2 Definition

```text
channel session-attributed transaction count
/
total session-attributed transaction count for session_date
```

using safe division.

## 21.3 Semantic Requirement

Both numerator and denominator use the same session-attributed transaction population.

The denominator must not be taken from transaction-date `transaction_count` in `executive_kpi_daily`.

## 21.4 Zero-Denominator Behavior

When the total daily session-attributed transaction count is zero, the metric returns `NULL`.

---

# 22. Revenue Contribution

## 22.1 Metric

`revenue_contribution`

## 22.2 Definition

```text
channel session-attributed purchase revenue
/
total session-attributed purchase revenue for session_date
```

using safe division.

## 22.3 Semantic Requirement

Both numerator and denominator use the same session-attributed revenue population.

The denominator must not be taken from transaction-date `purchase_revenue` in `executive_kpi_daily`.

This prevents transaction-date and session-cohort populations from being mixed in a single ratio.

## 22.4 Zero-Denominator Behavior

When total daily session-attributed purchase revenue is zero, the metric returns `NULL`.

---

# 23. Driver Contribution Denominator Strategy

Daily contribution denominators are calculated by aggregating `mart_channel_daily` across all governed channels for the same `session_date`.

Conceptually:

```text
channel numerator
/
SUM(corresponding channel metric across session_date)
```

This design is intentional.

It guarantees that:

- numerator and denominator originate from the same governed mart
- numerator and denominator use the same attribution basis
- channel contribution does not depend on an incompatible executive KPI semantic family
- the contribution population can be independently reconciled to the Phase 6 channel mart

---

# 24. Channel Driver Metric Set

The governed P7D channel-driver set is:

- `session_count`
- `purchasing_session_count`
- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`
- `conversion_rate`
- `session_contribution`
- `purchasing_session_contribution`
- `transaction_contribution`
- `revenue_contribution`

Supporting governed channel attributes include:

- `channel_key`
- `channel_group`
- `channel_description`
- `sort_order`

---

# 25. Driver Aggregation Rules

Contribution metrics are non-additive across dates.

For example, the following is not a governed multi-day revenue contribution:

```text
SUM(revenue_contribution)
```

and the following is also not valid:

```text
AVG(revenue_contribution)
```

For a multi-day reporting period, contribution must be recalculated from compatible additive components:

```text
SUM(channel session-attributed purchase revenue)
/
SUM(total session-attributed purchase revenue)
```

The same rule applies to session, purchasing-session, and transaction contribution.

Channel conversion for a multi-day period must likewise be recalculated as:

```text
SUM(channel purchasing_session_count)
/
SUM(channel session_count)
```

and not as an average of daily channel conversion rates.

Downstream BI must preserve these rules.

---

# 26. Driver Validation Requirements

The channel driver layer validates that:

- the model grain is unique at `session_date × channel_key`
- no row multiplication is introduced
- governed dates relate to `dim_date`
- governed channel keys relate to `dim_channel`
- required channel attributes and additive measures are non-null
- session totals reconcile to `mart_channel_daily`
- purchasing-session totals reconcile to `mart_channel_daily`
- session-attributed transaction totals reconcile to `mart_channel_daily`
- session-attributed purchase revenue reconciles to `mart_channel_daily`
- channel metadata reconciles to the upstream governed channel mart
- session contributions sum to 1.0 for dates with a valid denominator
- purchasing-session contributions sum to 1.0 for dates with a valid denominator
- transaction contributions sum to 1.0 for dates with a valid denominator
- revenue contributions sum to 1.0 for dates with a valid denominator
- zero denominators produce `NULL` rather than fabricated percentages

The implemented singular tests independently enforce composite-grain uniqueness, upstream reconciliation, and daily contribution behavior.

---

# 27. P7D Design Decision
The implemented Executive Driver Layer uses governed channel performance as the primary executive driver perspective.

Channel contribution is calculated only from semantically compatible session-date or session-attributed populations.

Transaction-date headline revenue and transaction metrics are not used as denominators for session-attributed channel contribution.

This preserves the analytical contracts established in Phase 6 while providing leadership with a controlled explanation of traffic mix, purchasing-session mix, commercial contribution, and channel conversion efficiency.

The Phase 7 driver layer does not introduce unsupported attribution models or redefine channel classification.

---

# 28. Executive Layer Dependency Flow

The implemented Phase 7 dependency flow is:

```text
mart_ecommerce_daily
        |
        v
executive_kpi_daily
        |
        v
executive_kpi_trends_daily
```

and:

```text
mart_channel_daily
        |
        v
executive_channel_drivers_daily
```

The two executive branches serve different analytical purposes:

- `executive_kpi_daily` and `executive_kpi_trends_daily` provide governed headline KPI and trend reporting
- `executive_channel_drivers_daily` provides governed channel-driver analysis

They must not be joined or compared solely because they contain daily reporting dates. Metric semantic family and attribution basis must be considered first.

---

# 29. Downstream BI Contract

Downstream BI may:

- aggregate additive components
- recalculate ratios from compatible additive components
- format governed rates and contribution values as percentages
- use channel metadata for filtering, ordering, and display
- use rolling and WoW fields directly according to their documented semantics

Downstream BI must not:

- redefine governed KPI formulas
- average daily ratios to create period-level KPIs
- sum daily contribution percentages across dates
- mix transaction-date revenue with session-attributed channel revenue in a single ratio
- reinterpret session-attributed transactions as transaction-date transactions
- introduce unsupported attribution logic
- reconstruct upstream session or purchase logic

These restrictions preserve a single governed metric contract from the warehouse through the executive reporting layer.
---

# 30. Phase 7 Implementation Status

The approved Executive KPI Layer was implemented through three governed models:

- `executive_kpi_daily`
- `executive_kpi_trends_daily`
- `executive_channel_drivers_daily`

The implemented layer preserves the approved headline KPI definitions, rolling and Week-over-Week semantics, channel-driver attribution rules, ratio reaggregation requirements, and upstream business-logic ownership defined in this design.

The Executive KPI outputs were validated and subsequently consumed by the downstream BI Serving Layer and Power BI semantic model.
