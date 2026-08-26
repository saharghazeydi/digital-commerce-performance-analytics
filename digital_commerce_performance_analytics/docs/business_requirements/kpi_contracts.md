# KPI Contracts

## Project

Digital Commerce Performance Analytics

## Phase

Phase 6 — Business Marts

## Purpose

Define the governed business metrics used across the Business Marts and downstream BI layer.

These contracts establish one approved definition for each KPI so that metric logic remains consistent across analytical marts, dashboards, and business reporting.

Business marts must consume governed Core Warehouse measures and must not independently redefine upstream session or transaction logic.

---

# KPI Design Principles

All governed KPIs must:

- have one explicit business definition
- identify the required analytical grain
- identify the numerator and denominator where applicable
- define null and zero-denominator behavior
- use governed Core Warehouse entities
- remain reconcilable to upstream facts
- produce consistent results across marts
- avoid BI-specific reinterpretation of metric logic

Ratios must be calculated from aggregated numerator and denominator values.

Pre-calculated row-level ratios must not be summed or averaged to produce higher-level KPI values unless explicitly approved.

---

# Base Measures

## Session Count

### Business Definition

Number of governed analytical sessions.

### Source

`fct_sessions`

### Calculation

```text
COUNT(*)
```

when calculated directly from `fct_sessions`.

### Governed Field Name

`session_count`

### Grain Behavior

Additive across mutually exclusive session populations.

### Notes

`fct_sessions` contains one row per governed session.

---

## Purchasing Session Count

### Business Definition

Number of governed sessions containing at least one valid purchase.

### Source

`fct_sessions`

### Calculation

```text
COUNTIF(has_purchase)
```

### Governed Field Name

`purchasing_session_count`

### Grain Behavior

Additive across mutually exclusive session populations.

### Notes

A session with multiple transactions is counted once.

---

## Transaction Count

### Business Definition

Number of governed valid ecommerce transactions.

### Primary Source

`fct_transactions`

### Calculation

```text
COUNT(*)
```

when calculated directly from `fct_transactions`.

### Governed Field Name

`transaction_count`

### Grain Behavior

Additive.

### Notes

`fct_transactions` contains one row per governed valid transaction.

Where an approved session-level mart uses the governed `transaction_count` measure from `fct_sessions`, the aggregated result must reconcile to `fct_transactions`.

---

## Purchase Revenue

### Business Definition

Total governed purchase revenue associated with valid ecommerce activity.

### Primary Source

`fct_transactions`

### Governed Field Name

`purchase_revenue`

### Calculation

```text
SUM(purchase_revenue)
```

### Grain Behavior

Additive.

### Notes

The metric uses the governed upstream GA4 purchase-revenue definition.

Business marts must not reconstruct purchase revenue from raw event or item records.

---

## Refund Value

### Business Definition

Total governed refund value.

### Primary Source

`fct_transactions`

### Governed Field Name

`refund_value`

### Calculation

```text
SUM(refund_value)
```

### Grain Behavior

Additive.

### Important Rule

`refund_value` is reported separately from `purchase_revenue`.

It must not automatically be subtracted from purchase revenue unless a separate governed net-revenue KPI is explicitly introduced.

---

## Shipping Value

### Business Definition

Total governed shipping value associated with transactions.

### Primary Source

`fct_transactions`

### Governed Field Name

`shipping_value`

### Calculation

```text
SUM(shipping_value)
```

### Grain Behavior

Additive.

---

## Tax Value

### Business Definition

Total governed tax value associated with transactions.

### Primary Source

`fct_transactions`

### Governed Field Name

`tax_value`

### Calculation

```text
SUM(tax_value)
```

### Grain Behavior

Additive.

---

## Total Item Quantity

### Business Definition

Total quantity of purchased items represented by governed transactions.

### Primary Source

`fct_transactions`

### Governed Field Name

`total_item_quantity`

### Calculation

```text
SUM(total_item_quantity)
```

### Grain Behavior

Additive.

---

# Derived KPIs

## Session Conversion Rate

### Business Definition

Percentage of governed sessions that contain at least one valid purchase.

### Governed KPI Name

`conversion_rate`

### Numerator

`purchasing_session_count`

### Denominator

`session_count`

### Formula

```text
purchasing_session_count / session_count
```

### SQL Pattern

```sql
safe_divide(
    purchasing_session_count,
    session_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

### Interpretation

Measures the proportion of sessions that convert to at least one purchase.

### Important Rule

This KPI is session-based.

It must not be calculated as:

```text
transaction_count / session_count
```

because one purchasing session may contain multiple transactions.

---

## Average Order Value

### Business Definition

Average governed purchase revenue per valid transaction.

### Governed KPI Name

`average_order_value`

### Numerator

`purchase_revenue`

### Denominator

`transaction_count`

### Formula

```text
purchase_revenue / transaction_count
```

### SQL Pattern

```sql
safe_divide(
    purchase_revenue,
    transaction_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

### Interpretation

Measures the average purchase-revenue value associated with a governed transaction.

### Important Rule

AOV is transaction-based, not purchasing-session-based.

---

## Revenue per Session

### Business Definition

Average governed purchase revenue generated per analytical session.

### Governed KPI Name

`revenue_per_session`

### Numerator

`purchase_revenue`

### Denominator

`session_count`

### Formula

```text
purchase_revenue / session_count
```

### SQL Pattern

```sql
safe_divide(
    purchase_revenue,
    session_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

### Interpretation

Measures commercial value generated relative to traffic volume.

---

## Transactions per Purchasing Session

### Business Definition

Average number of valid transactions generated by sessions that contain at least one purchase.

### Governed KPI Name

`transactions_per_purchasing_session`

### Numerator

`transaction_count`

### Denominator

`purchasing_session_count`

### Formula

```text
transaction_count / purchasing_session_count
```

### SQL Pattern

```sql
safe_divide(
    transaction_count,
    purchasing_session_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

### Interpretation

Provides visibility into purchasing sessions that contain more than one governed transaction.

---

## Items per Transaction

### Business Definition

Average purchased item quantity per governed transaction.

### Governed KPI Name

`items_per_transaction`

### Numerator

`total_item_quantity`

### Denominator

`transaction_count`

### Formula

```text
total_item_quantity / transaction_count
```

### SQL Pattern

```sql
safe_divide(
    total_item_quantity,
    transaction_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

---

# User-Level Measures

## Active Pseudo-User Count

### Business Definition

Number of distinct available GA4 pseudo-user identifiers represented in the analytical population.

### Source

`fct_sessions`

### Calculation

```text
COUNT(DISTINCT user_pseudo_id)
```

### Governed Field Name

`active_user_count`

### Important Limitation

This metric represents GA4 pseudo-users.

It must not be described as authenticated customers or known individuals.

---

## Purchasing Pseudo-User Count

### Business Definition

Number of distinct pseudo-users associated with at least one purchasing session.

### Source

`fct_sessions`

### Calculation

Conceptually:

```text
COUNT(DISTINCT user_pseudo_id WHERE has_purchase = TRUE)
```

### Governed Field Name

`purchasing_user_count`

### Important Limitation

This metric inherits the identity limitations of `user_pseudo_id`.

---

# Channel-Level Rules

Channel analysis must use the governed relationship:

```text
fct_sessions.channel_key
    →
dim_channel.channel_key
```

Business marts must not independently recreate channel classification from `source` or `medium`.

The approved channel groups are governed by `dim_channel`.

Source, medium, and campaign may remain available as analytical attributes where the mart grain supports them, but they must not replace the governed channel classification.

---

# Date Rules

Business marts must use the governed analytical date associated with the relevant fact grain.

Session metrics use:

```text
fct_sessions.session_date
```

Transaction metrics use the governed transaction date available from:

```text
fct_transactions
```

Calendar attributes must be obtained from `dim_date` where dimensional date analysis is required.

---

# Aggregation Rules

Additive measures such as:

- session_count
- purchasing_session_count
- transaction_count
- purchase_revenue
- refund_value
- shipping_value
- tax_value
- total_item_quantity

may be summed across compatible mutually exclusive mart rows.

Derived ratios such as:

- conversion_rate
- average_order_value
- revenue_per_session
- transactions_per_purchasing_session
- items_per_transaction

must be recalculated from their aggregated numerator and denominator when the reporting grain changes.

They must not be summed.

They must not be averaged across mart rows unless that averaging method is explicitly part of a separate governed metric.

---

# Null Handling

Null handling must preserve business meaning.

The following rules apply:

- zero denominators produce `NULL` ratios
- missing acquisition classification must use the governed fallback channel mapping
- missing pseudo-user identity must not be silently converted into a known customer
- missing commercial measures must follow the upstream governed model contract
- marts must not introduce arbitrary zero replacement where zero and unknown have different business meanings

---

# Reconciliation Requirements

For every implemented business mart:

- session counts must reconcile to the relevant `fct_sessions` population
- transaction counts must reconcile to the relevant `fct_transactions` population
- purchase revenue must reconcile to the relevant governed fact population
- additive commercial measures must reconcile at equivalent filters and grains
- derived KPIs must reproduce the approved formulas in this document

Any intentional difference must be documented as part of the mart contract.

---

# BI Consumption Rules

Downstream BI may:

- aggregate governed additive measures
- recalculate governed ratios from supplied numerators and denominators
- filter and slice approved mart dimensions
- create presentation-specific formatting

Downstream BI must not:

- redefine conversion rate
- redefine average order value
- reconstruct channel classification
- reconstruct sessionization
- reconstruct valid transaction populations
- create competing definitions of governed business KPIs

---

# KPI Governance Decision

The KPI contracts in this document are the approved metric definitions for Phase 6 Business Marts.

Implementation models must conform to these contracts unless a documented design change is approved before implementation.