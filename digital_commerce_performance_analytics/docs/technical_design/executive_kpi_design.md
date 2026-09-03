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

---

# 3. P7C Trend Metric Design

## 3.1 Business Purpose

Trend metrics provide leadership with a less volatile view of current performance and a controlled comparison with the immediately preceding equivalent period.

The Phase 7 daily executive layer therefore uses rolling seven-day windows.

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

Calendar ordering must use the governed `date_day`.

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

The trend layer must calculate:

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

The latter may be useful for operational daily analysis but is not the approved Phase 7 executive WoW definition.

---

# 8. Week-over-Week Revenue

## 8.1 Current Metric

```text
revenue_7d
```

## 8.2 Prior Metric

```text
revenue_previous_7d
```

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

```text
conversion_rate_7d
```

## 9.2 Prior Metric

```text
conversion_rate_previous_7d
```

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

The approved behavior is:

- rolling metrics may use the available dates within the governed dataset
- prior-period WoW metrics remain `NULL` when the required prior rolling observation is unavailable
- missing history must not be replaced with zero
- the trend layer must not fabricate pre-observation data

Downstream BI may suppress incomplete early-period comparisons where appropriate.

---

# 11. Aggregation Rules

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

# 12. Planned Trend Model

P7C will implement:

`executive_kpi_trends_daily`

with grain:

> One row per `date_day`.

Primary input:

`executive_kpi_daily`

The model will preserve the base executive KPI values while adding governed trend and comparison fields.

No Phase 6 business logic will be reconstructed in the trend model.

---

# 13. P7C Initial Metric Set

The approved initial trend set is:

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

# 14. Validation Requirements

P7C must validate that:

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

---

# P7C Design Decision

The Phase 7 executive trend layer will use rolling seven-day performance as the primary short-term executive trend perspective.

Week-over-Week comparisons will compare the current rolling seven-day period with the equivalent rolling seven-day period ending seven calendar days earlier.

Revenue retains transaction-date semantics.

Conversion retains session-date semantics.

All rolling ratios must be recalculated from compatible rolling numerator and denominator measures rather than averaging daily ratios.