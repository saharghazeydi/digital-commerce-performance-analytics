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
- preserve the governed date and attribution semantics of their component measures

Ratios must be calculated from aggregated numerator and denominator values.

Pre-calculated row-level ratios must not be summed or averaged to produce higher-level KPI values unless explicitly approved.

Where a KPI combines measures whose native facts use different date semantics, the KPI contract must explicitly define the required attribution basis before those measures are combined.

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

Where an approved session-level analysis uses the governed `transaction_count` measure available from `fct_sessions`, or attributes transactions from `fct_transactions` to sessions through `session_key`, the aggregated result must reconcile to the governed transaction population at an equivalent scope.

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

Where purchase revenue is required at a session-cohort grain, governed transaction revenue must be attributed to its originating session through `session_key` before aggregation by session attributes.

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

When calculated at a date grain, both the numerator and denominator use the governed `session_date`.

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

When calculated at a date grain, both `purchase_revenue` and `transaction_count` must use the governed `transaction_date`.

---

## Revenue per Session

### Business Definition

Average governed purchase revenue generated by analytical sessions.

### Governed KPI Name

`revenue_per_session`

### Numerator

Governed `purchase_revenue` attributed to the relevant session population through `session_key`.

### Denominator

`session_count`

### Formula

```text
session-attributed purchase_revenue / session_count
```

### SQL Pattern

```sql
safe_divide(
    session_attributed_purchase_revenue,
    session_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

### Interpretation

Measures the average commercial value generated by the governed session population.

### Attribution Rule

This is a session-cohort KPI.

When calculated at a date or other session-based grain, transaction revenue must first be attributed to the originating governed session through `session_key`.

The attributed revenue must then use the analytical attributes of that session, including `session_date` where the reporting grain is daily.

The KPI must not be calculated by dividing purchase revenue aggregated independently by `transaction_date` by sessions aggregated independently by `session_date`, because transaction activity may occur on a different calendar date from the originating session.

---

## Transactions per Purchasing Session

### Business Definition

Average number of valid transactions generated by sessions that contain at least one valid purchase.

### Governed KPI Name

`transactions_per_purchasing_session`

### Numerator

Governed transactions attributed to the relevant purchasing-session population through `session_key`.

### Denominator

`purchasing_session_count`

### Formula

```text
session-attributed transaction_count / purchasing_session_count
```

### SQL Pattern

```sql
safe_divide(
    session_attributed_transaction_count,
    purchasing_session_count
)
```

### Zero-Denominator Behavior

Return `NULL`.

### Interpretation

Measures the average number of governed transactions generated by purchasing sessions, including sessions that generate more than one transaction.

### Attribution Rule

This is a session-cohort KPI.

When calculated at a date or other session-based grain, governed transactions must first be attributed to the originating session through `session_key`.

The attributed transactions must then use the analytical attributes of that session, including `session_date` where the reporting grain is daily.

The KPI must not be calculated by dividing transactions aggregated independently by `transaction_date` by purchasing sessions aggregated independently by `session_date`.

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

### Interpretation

Measures the average purchased item quantity represented by each governed transaction.

### Important Rule

This KPI is transaction-based.

When calculated at a date grain, both `total_item_quantity` and `transaction_count` must use the governed `transaction_date`.

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

# P6E User-Behavior Measures and Attributes

The P6E Customer Behavior Mart operates at one row per `user_pseudo_id`.

All measures and behavioral attributes in this section describe activity observed within the governed dataset observation window.

`user_pseudo_id` is an analytical GA4 pseudo-user identifier and must not be interpreted as authenticated customer identity.

## Session Count per Pseudo-User

### Business Definition

Number of governed sessions associated with the pseudo-user.

### Source

`fct_sessions`

### Calculation

`COUNT(*)`

at `user_pseudo_id` grain.

### Governed Field Name

`session_count`

### Interpretation

Measures observed session activity generated by the pseudo-user within the governed observation window.

---

## Active Date Count

### Business Definition

Number of distinct governed session dates on which the pseudo-user is observed.

### Source

`fct_sessions`

### Calculation

`COUNT(DISTINCT session_date)`

### Governed Field Name

`active_date_count`

### Interpretation

Multiple sessions occurring on the same calendar date contribute one active date.

---

## Purchasing Session Count per Pseudo-User

### Business Definition

Number of governed sessions associated with the pseudo-user that contain at least one governed purchase.

### Source

`fct_sessions`

### Calculation

`COUNTIF(has_purchase)`

at `user_pseudo_id` grain.

### Governed Field Name

`purchasing_session_count`

### Important Rule

A purchasing session contributes once even when it contains multiple governed transactions.

---

## Transaction Count per Pseudo-User

### Business Definition

Number of governed transactions associated with the pseudo-user.

### Source

`fct_transactions`

### Calculation

`COUNT(*)`

at `user_pseudo_id` grain.

### Governed Field Name

`transaction_count`

### Important Rule

`transaction_count > 1` must not be used by itself to identify repeat purchasing-session behavior because multiple transactions may occur within one purchasing session.

---

## Purchase Revenue per Pseudo-User

### Business Definition

Total governed purchase revenue associated with the pseudo-user.

### Source

`fct_transactions`

### Calculation

`SUM(purchase_revenue)`

### Governed Field Name

`purchase_revenue`

---

## Refund Value per Pseudo-User

### Business Definition

Total governed refund value associated with the pseudo-user.

### Source

`fct_transactions`

### Calculation

`SUM(refund_value)`

### Governed Field Name

`refund_value`

---

## Total Item Quantity per Pseudo-User

### Business Definition

Total governed purchased-item quantity associated with the pseudo-user.

### Source

`fct_transactions`

### Calculation

`SUM(total_item_quantity)`

### Governed Field Name

`total_item_quantity`

---

## Purchasing Date Count

### Business Definition

Number of distinct governed session dates on which the pseudo-user generated at least one purchasing session.

### Source

`fct_sessions`

### Calculation

`COUNT(DISTINCT session_date)`

over governed purchasing sessions.

### Governed Field Name

`purchasing_date_count`

### Important Rule

This measure uses purchasing-session dates rather than transaction activity dates.

Multiple purchasing sessions occurring on the same session date contribute one purchasing date.

---

## First Observed Session Date

### Business Definition

Earliest governed session date visible for the pseudo-user within the observation window.

### Source

`fct_sessions`

### Calculation

`MIN(session_date)`

### Governed Field Name

`first_observed_session_date`

### Important Limitation

This is the first observed session in the governed dataset, not necessarily the pseudo-user's true first-ever session.

---

## Last Observed Session Date

### Business Definition

Latest governed session date visible for the pseudo-user within the observation window.

### Source

`fct_sessions`

### Calculation

`MAX(session_date)`

### Governed Field Name

`last_observed_session_date`

### Important Limitation

This is the last observed session in the governed dataset, not necessarily the pseudo-user's true last-ever interaction.

---

## First Observed Purchase Date

### Business Definition

Earliest governed purchasing-session date visible for the pseudo-user within the observation window.

### Source

`fct_sessions`

### Calculation

`MIN(session_date)`

over governed purchasing sessions.

### Governed Field Name

`first_observed_purchase_date`

### Important Rule

This measure uses the originating purchasing-session date rather than transaction activity date.

---

## Last Observed Purchase Date

### Business Definition

Latest governed purchasing-session date visible for the pseudo-user within the observation window.

### Source

`fct_sessions`

### Calculation

`MAX(session_date)`

over governed purchasing sessions.

### Governed Field Name

`last_observed_purchase_date`

### Important Rule

This measure uses the originating purchasing-session date rather than transaction activity date.

---

## Observed User Span Days

### Business Definition

Calendar-day difference between the pseudo-user's first and last observed governed session dates.

### Calculation

`DATE_DIFF(last_observed_session_date, first_observed_session_date, DAY)`

### Governed Field Name

`observed_user_span_days`

### Interpretation

A pseudo-user observed on only one calendar date has an observed span of zero days.

This is an observation-window measure and must not be interpreted as true customer tenure.

---

## Is Purchasing User

### Business Definition

Boolean attribute identifying whether the pseudo-user generated at least one governed purchasing session.

### Calculation

`purchasing_session_count > 0`

### Governed Field Name

`is_purchasing_user`

---

## Is Multi-Session User

### Business Definition

Boolean attribute identifying repeated governed session activity.

### Calculation

`session_count > 1`

### Governed Field Name

`is_multi_session_user`

### Important Rule

This does not imply that the pseudo-user returned on a later calendar date because multiple sessions may occur on the same date.

---

## Returned on Later Date

### Business Definition

Boolean attribute identifying whether the pseudo-user was observed on more than one distinct governed session date.

### Calculation

`active_date_count > 1`

### Governed Field Name

`returned_on_later_date`

### Important Limitation

This represents observed temporal return behavior and must not be labelled as a returning-customer classification.

---

## Is Repeat Purchasing Session User

### Business Definition

Boolean attribute identifying pseudo-users with purchasing activity across more than one governed session.

### Calculation

`purchasing_session_count > 1`

### Governed Field Name

`is_repeat_purchasing_session_user`

### Important Rule

This is the governed definition of repeat purchasing-session behavior.

It must not be derived from `transaction_count > 1`.

---

## Is Repeat Purchasing Date User

### Business Definition

Boolean attribute identifying pseudo-users with purchasing activity on more than one distinct governed purchasing-session date.

### Calculation

`purchasing_date_count > 1`

### Governed Field Name

`is_repeat_purchasing_date_user`

### Interpretation

This is a stricter temporal definition than repeat purchasing-session behavior.

Multiple purchasing sessions occurring on the same date do not satisfy this definition.

---

## New / Returning Customer Classification

No production-grade `new_customer` or `returning_customer` KPI is approved for P6E.

This restriction exists because:

- `user_pseudo_id` is not authenticated customer identity
- the dataset represents a bounded observation window
- first observed activity is not necessarily first-ever activity
- `ga_session_number` is not perfectly unique or consistent within every observed pseudo-user history

`ga_session_number` may be used as a supporting behavioral or diagnostic attribute where required, but it must not independently establish customer lifecycle status.

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

# Date and Attribution Rules

Business marts must preserve the governed analytical date associated with the metric being reported.

## Session-Date Metrics

Session-native metrics use:

```text
fct_sessions.session_date
```

This includes session-based measures such as `session_count`, `purchasing_session_count`, and `conversion_rate`.

## Transaction-Date Metrics

Transaction-activity metrics use:

```text
fct_transactions.transaction_date
```

This includes transaction-native measures such as `transaction_count`, `purchase_revenue`, `refund_value`, `shipping_value`, `tax_value`, `total_item_quantity`, `average_order_value`, and `items_per_transaction` when they are reported as transaction activity over time.

## Session-Cohort Attribution

A KPI that combines a transaction-derived numerator with a session-derived denominator must not independently aggregate the two components using different date semantics and then divide them.

Where the KPI represents commercial outcomes generated by a session population, governed transactions must first be associated with their originating session through:

```text
fct_transactions.session_key
    →
fct_sessions.session_key
```

The transaction-derived measure must then be aggregated using the relevant session attributes.

For daily session-cohort KPIs, this means using:

```text
fct_sessions.session_date
```

as the reporting date for both the session denominator and the transaction-derived numerator attributed to those sessions.

This rule applies to governed session-cohort KPIs including:

- `revenue_per_session`
- `transactions_per_purchasing_session`

Transaction activity reporting and session-cohort attribution answer different analytical questions and must remain explicitly distinguishable.

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

may be summed across compatible mutually exclusive mart rows when their grain and attribution semantics are preserved.

Derived ratios such as:

- conversion_rate
- average_order_value
- revenue_per_session
- transactions_per_purchasing_session
- items_per_transaction

must be recalculated from their aggregated governed numerator and denominator when the reporting grain changes.

They must not be summed.

They must not be averaged across mart rows unless that averaging method is explicitly part of a separate governed metric.

For session-cohort ratios, both numerator and denominator must be aggregated using the same governed session-cohort attribution before the ratio is recalculated.

For transaction-based ratios, both numerator and denominator must remain on the governed transaction attribution basis.

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
- additive commercial measures must reconcile at equivalent filters, grains, and attribution semantics
- derived KPIs must reproduce the approved formulas and attribution rules in this document
- session-cohort transaction and revenue measures must reconcile to the governed transaction population after attribution through `session_key`

Any intentional difference must be documented as part of the mart contract.

---

# BI Consumption Rules

Downstream BI may:

- aggregate governed additive measures at compatible grains
- recalculate governed ratios from supplied compatible numerators and denominators
- filter and slice approved mart dimensions
- create presentation-specific formatting

Downstream BI must not:

- redefine conversion rate
- redefine average order value
- mix session-date and transaction-date measures into an ungoverned cross-fact ratio
- reconstruct session-cohort attribution independently
- reconstruct channel classification
- reconstruct sessionization
- reconstruct valid transaction populations
- create competing definitions of governed business KPIs

Where both transaction-activity and session-cohort measures are exposed downstream, their different date and attribution semantics must remain clear to BI consumers.

---

# KPI Governance Decision

The KPI contracts in this document are the approved metric definitions for Phase 6 Business Marts.

Implementation models must conform to these contracts unless a documented design change is approved before implementation.

The governed KPI layer explicitly distinguishes transaction-activity reporting from session-cohort attribution so that measures from different fact grains are not combined under incompatible date semantics.