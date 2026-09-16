# BI Interface Contract

## Project

Digital Commerce Performance Analytics

## Phase

Phase 8 — BI Serving Layer

## Work Package

P8D — Business Naming & BI Interface

---

# 1. Purpose

This document defines the business-facing interface contract for the governed BI Serving Layer.

It establishes how serving-model fields are interpreted and presented in the implemented Power BI semantic model.


The contract defines:

- business-facing terminology
- field visibility expectations
- technical and helper fields
- aggregation behaviour
- semantic-model measure ownership
- formatting expectations
- non-additive metric handling
- semantic distinctions that must remain visible to report developers

This document does not define the implementation details of Power BI relationships, DAX measures, display folders, or report visuals.

Those responsibilities are implemented and documented in the downstream Power BI semantic-model and report layers.

---

# 2. Interface Principles

The BI interface follows these principles:

1. Business-facing names should be concise and understandable.
2. Governed semantic meaning must take priority over cosmetic naming.
3. Technical keys should remain available for relationships but should normally be hidden from report consumers.
4. Additive components required for governed DAX calculations must remain available even when hidden.
5. Daily ratios, rolling metrics, and contribution metrics must not receive misleading default aggregations.
6. Session-date, transaction-date, and session-attributed measures must remain distinguishable.
7. The semantic model may improve presentation but must not redefine governed business logic.
8. A field should not be exposed merely because it exists upstream.
9. Report authors should primarily work with explicit measures rather than raw numeric columns.
10. Naming should remain stable across reports once the semantic model is published.

---

# 3. Field Classification

Every imported field should conceptually belong to one of the following interface classes.

## 3.1 Business Dimension

A descriptive field intended for:

- filtering
- slicing
- grouping
- labels
- report navigation

Examples:

- Date
- Channel
- Device Category
- Country

## 3.2 Relationship Key

A technical field required to establish semantic-model relationships.

Examples:

- `channel_key`

These fields should normally be hidden after relationships are configured.

## 3.3 Additive Component

A governed numeric field that may be summed across compatible dimensions and dates.

Examples:

- sessions
- purchasing sessions
- transactions
- purchase revenue

These fields may support DAX measures but should generally not be exposed as implicit report measures.

## 3.4 Governed Ratio

A governed ratio whose correct value depends on compatible numerator and denominator populations.

Examples:

- Conversion Rate
- Average Order Value
- Revenue per Session

For broader filter contexts, these metrics should be recalculated from their governed additive components where those components are available.

## 3.5 Governed Trend Metric

A metric whose time-window logic has already been defined upstream.

Examples:

- 7-Day Revenue
- 7-Day Conversion Rate
- Revenue WoW %
- Conversion WoW %

These fields must not be casually reaggregated across dates.

## 3.6 Governed Contribution Metric

A share calculated relative to a compatible daily population.

Examples:

- Session Contribution
- Revenue Contribution

Contribution values are non-additive across dates.

## 3.7 Behavioural Attribute

A pseudo-user-level attribute or flag describing observed behaviour across the available observation window.

Examples:

- Is Purchasing User
- Returned on Later Date
- Observed User Span Days

These fields must not be interpreted as authenticated customer lifecycle measures.

---

# 4. Naming Convention

Physical dbt field names remain in `snake_case`.

Power BI business-facing labels should use readable Title Case.

Examples:

| Physical Field | Business-Facing Label |
|---|---|
| `date_day` | Date |
| `session_date` | Session Date |
| `session_count` | Sessions |
| `purchasing_session_count` | Purchasing Sessions |
| `transaction_count` | Transactions |
| `purchase_revenue` | Purchase Revenue |
| `conversion_rate` | Conversion Rate |
| `average_order_value` | Average Order Value |
| `revenue_per_session` | Revenue per Session |
| `device_category` | Device Category |
| `channel_group` | Channel |
| `sort_order` | Channel Sort Order |

Physical warehouse names do not need to be changed merely to achieve presentation formatting.

Power BI may apply business-facing display names while preserving the governed physical schema.

---

# 5. Semantic Naming Rule

Business-facing naming must not hide material semantic differences.

For example:

```text
purchase_revenue
```

in a transaction-date commerce dataset may be presented as:

```text
Purchase Revenue
```

However:

```text
session_attributed_purchase_revenue
```

must not also be presented simply as:

```text
Purchase Revenue
```

when both concepts could appear in the same semantic model.

The preferred business-facing label is:

```text
Session-Attributed Purchase Revenue
```

The same rule applies to transactions.

This protects the distinction between transaction-date and session-attributed commercial populations.

---

# 6. `bi_executive_daily` Interface

## 6.1 Purpose

Executive KPI and governed trend reporting.

## 6.2 Field Contract

| Physical Field | Business-Facing Label | Classification | Default Visibility | Aggregation Behaviour |
|---|---|---|---|---|
| `date_day` | Date | Business Dimension | Visible | Do not summarize |
| `session_count` | Sessions | Additive Component | Hidden / measure source | Sum |
| `purchasing_session_count` | Purchasing Sessions | Additive Component | Hidden / measure source | Sum |
| `conversion_rate` | Daily Conversion Rate | Governed Ratio | Hidden | Do not summarize |
| `transaction_count` | Transactions | Additive Component | Hidden / measure source | Sum |
| `purchase_revenue` | Purchase Revenue | Additive Component | Hidden / measure source | Sum |
| `average_order_value` | Daily Average Order Value | Governed Ratio | Hidden | Do not summarize |
| `session_attributed_transaction_count` | Session-Attributed Transactions | Additive Component | Hidden / measure source | Sum |
| `session_attributed_purchase_revenue` | Session-Attributed Purchase Revenue | Additive Component | Hidden / measure source | Sum |
| `revenue_per_session` | Daily Revenue per Session | Governed Ratio | Hidden | Do not summarize |
| `revenue_7d` | 7-Day Purchase Revenue | Governed Trend Metric | Hidden / measure source | Do not summarize |
| `sessions_7d` | 7-Day Sessions | Governed Trend Component | Hidden | Do not summarize |
| `purchasing_sessions_7d` | 7-Day Purchasing Sessions | Governed Trend Component | Hidden | Do not summarize |
| `conversion_rate_7d` | 7-Day Conversion Rate | Governed Trend Metric | Hidden / measure source | Do not summarize |
| `revenue_previous_7d` | Previous 7-Day Purchase Revenue | Governed Trend Metric | Hidden | Do not summarize |
| `conversion_rate_previous_7d` | Previous 7-Day Conversion Rate | Governed Trend Metric | Hidden | Do not summarize |
| `revenue_wow_absolute_change` | Revenue WoW Change | Governed Trend Metric | Hidden / measure source | Do not summarize |
| `revenue_wow_pct_change` | Revenue WoW % | Governed Trend Metric | Hidden / measure source | Do not summarize |
| `conversion_wow_absolute_change` | Conversion WoW Change | Governed Trend Metric | Hidden / measure source | Do not summarize |
| `conversion_wow_pct_change` | Conversion WoW % | Governed Trend Metric | Hidden / measure source | Do not summarize |

---

# 7. Executive Measure Interface

The implemented Power BI semantic model exposes explicit measures for the main executive KPIs.

Expected business measures include:

```text
Sessions
Purchasing Sessions
Transactions
Purchase Revenue
Conversion Rate
Average Order Value
Revenue per Session
```

Period-level ratios must use governed additive components.

For example:

```text
Conversion Rate
=
SUM(Purchasing Sessions)
/
SUM(Sessions)
```

```text
Average Order Value
=
SUM(Purchase Revenue)
/
SUM(Transactions)
```

```text
Revenue per Session
=
SUM(Session-Attributed Purchase Revenue)
/
SUM(Sessions)
```

The existing daily ratio columns should not be averaged to produce period-level KPIs.

---

# 8. Executive Trend Interface

The following fields contain governed upstream trend logic:

```text
revenue_7d
conversion_rate_7d
revenue_previous_7d
conversion_rate_previous_7d
revenue_wow_absolute_change
revenue_wow_pct_change
conversion_wow_absolute_change
conversion_wow_pct_change
```

These fields are date-specific analytical outputs.

They must not be summed or averaged across multiple dates.

The implemented Power BI semantic model exposes these metrics through explicit measures that return the appropriate value for the active date context.

The semantic model must not reconstruct a competing definition of the governed seven-day or Week-over-Week logic.

---

# 9. `bi_channel_daily` Interface

## 9.1 Purpose

Acquisition and channel-driver analysis.

## 9.2 Field Contract

| Physical Field | Business-Facing Label | Classification | Default Visibility | Aggregation Behaviour |
|---|---|---|---|---|
| `session_date` | Session Date | Business Dimension | Visible | Do not summarize |
| `channel_key` | Channel Key | Relationship Key | Hidden | Do not summarize |
| `channel_group` | Channel | Business Dimension | Hidden when `dim_channel` is used | Do not summarize |
| `channel_description` | Channel Description | Business Dimension | Hidden when `dim_channel` is used | Do not summarize |
| `sort_order` | Channel Sort Order | Technical Presentation Field | Hidden | Do not summarize |
| `session_count` | Sessions | Additive Component | Hidden / measure source | Sum |
| `purchasing_session_count` | Purchasing Sessions | Additive Component | Hidden / measure source | Sum |
| `conversion_rate` | Daily Channel Conversion Rate | Governed Ratio | Hidden | Do not summarize |
| `session_attributed_transaction_count` | Session-Attributed Transactions | Additive Component | Hidden / measure source | Sum |
| `session_attributed_purchase_revenue` | Session-Attributed Purchase Revenue | Additive Component | Hidden / measure source | Sum |
| `session_contribution` | Daily Session Contribution | Governed Contribution Metric | Hidden | Do not summarize |
| `purchasing_session_contribution` | Daily Purchasing Session Contribution | Governed Contribution Metric | Hidden | Do not summarize |
| `transaction_contribution` | Daily Transaction Contribution | Governed Contribution Metric | Hidden | Do not summarize |
| `revenue_contribution` | Daily Revenue Contribution | Governed Contribution Metric | Hidden | Do not summarize |

---

# 10. Channel Measure Interface

For broader date contexts, channel ratios and contributions must be recalculated from compatible additive components.

Examples:

```text
Channel Conversion Rate
=
SUM(Channel Purchasing Sessions)
/
SUM(Channel Sessions)
```

```text
Session Contribution
=
SUM(Channel Sessions)
/
SUM(All Compatible Sessions)
```

```text
Revenue Contribution
=
SUM(Channel Session-Attributed Purchase Revenue)
/
SUM(All Compatible Session-Attributed Purchase Revenue)
```

The exact DAX implementation and filter-context handling are owned by the implemented Power BI semantic model.

Daily contribution columns must not be summed or averaged across dates.

---

# 11. Channel Dimension Interface

`dim_channel` remains the authoritative channel dimension.

Expected business-facing fields include:

```text
Channel
Channel Description
Channel Sort Order
```

`channel_key` is required for relationships but should normally be hidden from report authors.

Where the same descriptive channel fields also exist in `bi_channel_daily`, the semantic model should prefer the authoritative dimension fields for slicing and grouping.

Redundant fact-side descriptive fields may be hidden in the Power BI semantic model.

---

# 12. `bi_commerce_daily` Interface

## 12.1 Purpose

Detailed transaction-date commerce analysis.

## 12.2 Field Contract

| Physical Field | Business-Facing Label | Classification | Default Visibility | Aggregation Behaviour |
|---|---|---|---|---|
| `date_day` | Date | Business Dimension | Visible | Do not summarize |
| `transaction_count` | Transactions | Additive Component | Hidden / measure source | Sum |
| `purchase_revenue` | Purchase Revenue | Additive Component | Hidden / measure source | Sum |
| `refund_value` | Refund Value | Additive Component | Hidden / measure source | Sum |
| `shipping_value` | Shipping Value | Additive Component | Hidden / measure source | Sum |
| `tax_value` | Tax Value | Additive Component | Hidden / measure source | Sum |
| `total_item_quantity` | Items Purchased | Additive Component | Hidden / measure source | Sum |
| `average_order_value` | Daily Average Order Value | Governed Ratio | Hidden | Do not summarize |
| `items_per_transaction` | Daily Items per Transaction | Governed Ratio | Hidden | Do not summarize |

---

# 13. Commerce Measure Interface

Expected business measures include:

```text
Transactions
Purchase Revenue
Refund Value
Shipping Value
Tax Value
Items Purchased
Average Order Value
Items per Transaction
```

Period-level calculations must use compatible additive components.

```text
Average Order Value
=
SUM(Purchase Revenue)
/
SUM(Transactions)
```

```text
Items per Transaction
=
SUM(Items Purchased)
/
SUM(Transactions)
```

The semantic model must not introduce Net Revenue from Purchase Revenue and Refund Value unless a new governed KPI contract explicitly defines it.

---

# 14. `bi_user_behavior` Interface

## 14.1 Purpose

Observed pseudo-user behavioural analysis across the available observation window.

## 14.2 Field Contract

| Physical Field | Business-Facing Label | Classification | Default Visibility | Aggregation Behaviour |
|---|---|---|---|---|
| `user_pseudo_id` | Pseudo-User ID | Analytical Identifier | Hidden | Do not summarize |
| `session_count` | Observed Sessions | Additive User Attribute | Hidden / measure source | Sum with caution |
| `active_date_count` | Active Dates | Behavioural Attribute | Hidden / measure source | Sum with caution |
| `purchasing_session_count` | Purchasing Sessions | Additive User Attribute | Hidden / measure source | Sum with caution |
| `purchasing_date_count` | Purchasing Dates | Behavioural Attribute | Hidden / measure source | Sum with caution |
| `first_observed_session_date` | First Observed Session Date | Behavioural Attribute | Visible | Do not summarize |
| `last_observed_session_date` | Last Observed Session Date | Behavioural Attribute | Visible | Do not summarize |
| `first_observed_purchase_date` | First Observed Purchase Date | Behavioural Attribute | Visible | Do not summarize |
| `last_observed_purchase_date` | Last Observed Purchase Date | Behavioural Attribute | Visible | Do not summarize |
| `observed_user_span_days` | Observed User Span (Days) | Behavioural Attribute | Hidden / measure source | Do not summarize |
| `transaction_count` | Observed Transactions | Additive User Attribute | Hidden / measure source | Sum with caution |
| `purchase_revenue` | Observed Purchase Revenue | Additive User Attribute | Hidden / measure source | Sum with caution |
| `refund_value` | Observed Refund Value | Additive User Attribute | Hidden / measure source | Sum with caution |
| `total_item_quantity` | Observed Items Purchased | Additive User Attribute | Hidden / measure source | Sum with caution |
| `is_purchasing_user` | Purchasing User | Behavioural Attribute | Visible | Do not summarize |
| `is_multi_session_user` | Multi-Session User | Behavioural Attribute | Visible | Do not summarize |
| `returned_on_later_date` | Returned on Later Date | Behavioural Attribute | Visible | Do not summarize |
| `is_repeat_purchasing_session_user` | Repeat Purchasing-Session User | Behavioural Attribute | Visible | Do not summarize |
| `is_repeat_purchasing_date_user` | Repeat Purchasing-Date User | Behavioural Attribute | Visible | Do not summarize |

---

# 15. Pseudo-User Terminology

The term:

```text
Customer
```

must not replace:

```text
Pseudo-User
```

in fields or measures derived solely from `user_pseudo_id`.

Allowed terminology includes:

- Pseudo-User
- Observed User
- Observed User Behaviour
- Purchasing User

Unsupported terminology includes:

- Authenticated Customer
- Customer Account
- Customer Lifetime
- Customer Churn
- Customer Retention

unless future governed data supports those concepts.

`returned_on_later_date` must not be relabeled as:

```text
Retained Customer
```

or:

```text
Customer Retention
```

It represents only observed later-date activity within the available observation window.

---

# 16. `bi_segment_daily` Interface

## 16.1 Purpose

Device and geography performance analysis using session-date and session-attributed semantics.

## 16.2 Field Contract

| Physical Field | Business-Facing Label | Classification | Default Visibility | Aggregation Behaviour |
|---|---|---|---|---|
| `session_date` | Session Date | Business Dimension | Visible | Do not summarize |
| `device_category` | Device Category | Business Dimension | Visible | Do not summarize |
| `country` | Country | Business Dimension | Visible | Do not summarize |
| `session_count` | Sessions | Additive Component | Hidden / measure source | Sum |
| `purchasing_session_count` | Purchasing Sessions | Additive Component | Hidden / measure source | Sum |
| `conversion_rate` | Daily Segment Conversion Rate | Governed Ratio | Hidden | Do not summarize |
| `session_attributed_transaction_count` | Session-Attributed Transactions | Additive Component | Hidden / measure source | Sum |
| `session_attributed_purchase_revenue` | Session-Attributed Purchase Revenue | Additive Component | Hidden / measure source | Sum |
| `revenue_per_session` | Daily Revenue per Session | Governed Ratio | Hidden | Do not summarize |

---

# 17. Segment Measure Interface

Period-level segment conversion must be calculated from compatible components:

```text
Segment Conversion Rate
=
SUM(Purchasing Sessions)
/
SUM(Sessions)
```

Period-level Revenue per Session must use:

```text
SUM(Session-Attributed Purchase Revenue)
/
SUM(Sessions)
```

The segment model's commercial measures are session-attributed.

They must not be presented as equivalent to transaction-date commerce measures.

---

# 18. Date Dimension Interface

`dim_date` is the authoritative reusable calendar dimension.

The Power BI semantic model should use it for common calendar filtering and grouping rather than relying on duplicated date attributes embedded in fact datasets.

Expected business-facing calendar fields may include:

- Date
- Year
- Quarter
- Month
- Month Number
- Week
- Day

The exposed calendar fields are governed by the existing `dim_date` schema and the implemented Power BI semantic-model design.

The semantic model should mark the appropriate field as the model date column where required by the chosen Power BI design.

---

# 19. Default Summarization Rules

Power BI default summarization must follow these rules.

## Sum

Appropriate for governed additive components such as:

- Sessions
- Purchasing Sessions
- Transactions
- Purchase Revenue
- Refund Value
- Shipping Value
- Tax Value
- Item Quantity
- Session-Attributed Transactions
- Session-Attributed Purchase Revenue

## Do Not Summarize

Required for:

- keys
- dates used as attributes
- descriptive dimensions
- boolean flags
- daily ratios
- rolling metrics
- Week-over-Week metrics
- contribution metrics
- pseudo-user identifiers

Explicit DAX measures should be preferred over implicit aggregation of raw numeric columns.

---

# 20. Percentage Formatting

The following metric families should normally use percentage formatting:

- Conversion Rate
- 7-Day Conversion Rate
- Revenue WoW %
- Conversion WoW %
- Session Contribution
- Purchasing Session Contribution
- Transaction Contribution
- Revenue Contribution

`conversion_wow_absolute_change` represents an absolute difference between conversion rates and should normally be displayed as a percentage-point change rather than interpreted as relative percent growth.

Formatting must not change the underlying governed calculation.

---

# 21. Currency Formatting

The following fields and measures represent monetary values and should use consistent currency formatting:

- Purchase Revenue
- Session-Attributed Purchase Revenue
- Refund Value
- Shipping Value
- Tax Value
- Average Order Value
- 7-Day Purchase Revenue
- Previous 7-Day Purchase Revenue
- Revenue WoW Change

The dataset itself does not establish a currency-conversion layer.

Power BI must not imply converted or normalized currency unless such logic is introduced through a future governed requirement.

---

# 22. Hidden Technical Fields

The following categories should normally be hidden from report consumers after semantic-model configuration:

- surrogate keys
- relationship keys
- sort-order helpers
- additive numerator and denominator columns used only by measures
- duplicate fact-side dimension descriptions
- raw daily ratios replaced by explicit measures
- raw governed trend columns surfaced through explicit semantic measures

Hidden does not mean unused.

Many hidden fields remain essential for:

- relationships
- DAX
- sorting
- reconciliation
- governance

---

# 23. Measure-First Reporting

Report visuals should primarily consume explicit semantic-model measures rather than dragging raw numeric columns directly into visuals.

This provides:

- controlled aggregation
- consistent naming
- predictable formatting
- reusable KPI logic
- safer filter-context behaviour
- clearer report authoring

Raw additive columns may remain available to measures while being hidden from the report field list.

---

# 24. Cross-Dataset Naming

The same business label may be reused only when the underlying semantic meaning is compatible.

For example, `Sessions` may be used across session-based serving datasets when it represents governed session counts under the same session definition.

However, the label:

```text
Purchase Revenue
```

must not be used interchangeably for both:

- transaction-date purchase revenue
- session-attributed purchase revenue

where doing so could obscure the population distinction.

Session-attributed measures must retain an explicit attribution qualifier when ambiguity is possible.

---

# 25. Semantic Model Boundaries

The Power BI semantic model may:

- rename fields for presentation
- hide technical fields
- create explicit measures from governed components
- format measures
- organize display folders
- configure sorting
- configure relationships
- configure date behaviour

The Power BI semantic model must not:

- redefine sessionization
- redefine purchasing sessions
- redefine transaction identity
- redefine channel classification
- rebuild attribution
- average daily ratios to create period KPIs
- sum contribution percentages
- mix transaction-date and session-attributed revenue populations
- introduce unsupported customer identity
- introduce unsupported Net Revenue
- introduce unsupported CAC, CPA, ROAS, profit, margin, CLV, churn, or retention

A requirement for new business logic must return to the governed analytics-engineering layer rather than being implemented ad hoc in the report.

---

# 26. Power BI Implementation Handoff

The Power BI semantic model was implemented using the governed BI interface defined by this contract, including:

- the five governed BI serving datasets
- `dim_date`
- `dim_channel`
- the BI serving technical design
- the Executive KPI Reference
- the upstream KPI contracts

The implemented semantic model includes:

- BigQuery connectivity
- semantic-model relationships
- a governed date model
- explicit DAX measures
- controlled field visibility
- business-facing labels
- measure formatting
- sorting
- display folders
- semantic-model validation

The Power BI implementation preserves the governed metric definitions, grains, attribution semantics, and aggregation rules defined upstream.

---

# 27. P8D Decision

The BI Serving Layer preserves stable technical field names while the Power BI semantic model provides the final business-facing presentation layer.

The interface deliberately distinguishes:

- business dimensions
- relationship keys
- additive components
- governed ratios
- governed trend metrics
- governed contribution metrics
- pseudo-user behavioural attributes

Technical and helper fields remain available where required but should normally be hidden from report authors.

Explicit semantic-model measures are preferred over implicit aggregation.

Most importantly, business-friendly naming must never erase the governed distinctions between:

- session-date metrics
- transaction-date metrics
- session-attributed metrics
- pseudo-user observations
- authenticated customer concepts

This contract defines the approved BI-facing interface implemented in the downstream Power BI semantic model and report.
