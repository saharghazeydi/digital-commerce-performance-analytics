# BI Serving Technical Design

## Project

Digital Commerce Performance Analytics

## Phase

Phase 8 — BI Serving Layer

## Work Package

P8B — Serving Architecture & Model Contracts

---

# 1. Purpose

This document defines the approved technical architecture and model contracts for the BI Serving Layer.

The BI Serving Layer provides the controlled interface between the governed analytical outputs produced in Phases 5–7 and the Power BI semantic model implemented in Phase 9.

The design translates the consumption requirements defined in P8A into explicit serving-model boundaries, grains, dependencies, keys, field responsibilities, and semantic constraints.

The serving layer must improve downstream usability without duplicating analytical logic or creating unnecessary pass-through models.

---

# 2. Design Principles

The BI Serving Layer follows these principles:

1. Governed business logic remains upstream.
2. Serving models are organized around downstream analytical purpose.
3. Existing models are not mechanically duplicated with BI-specific names.
4. Models with incompatible grains or semantic populations remain separate.
5. Compatible governed outputs may be consolidated when doing so removes unnecessary downstream duplication.
6. Serving models expose only fields required for BI consumption, relationships, filtering, governed recalculation, or validation.
7. Ratio and contribution semantics must remain traceable to compatible additive components.
8. Technical optimization must be evidence-based.
9. Power BI must not become an alternative transformation or attribution layer.
10. The serving architecture must remain understandable and defensible without unnecessary model proliferation.

---

# 3. Upstream Analytical Inputs

The serving architecture is based on the following governed upstream models.

## 3.1 Dimensions

- `dim_date`
- `dim_channel`

## 3.2 Business Marts

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_user_behavior`
- `mart_segment_daily`

## 3.3 Executive Models

- `executive_kpi_daily`
- `executive_kpi_trends_daily`
- `executive_channel_drivers_daily`

These models already contain governed business logic and validated analytical grains.

The BI Serving Layer must not reconstruct their upstream logic.

---

# 4. Serving Architecture Decision

The approved serving architecture contains four BI-oriented fact or analytical datasets and two governed dimensions.

The planned serving datasets are:

```text
bi_executive_daily
bi_channel_daily
bi_commerce_daily
bi_user_behavior
bi_segment_daily
```

with governed dimensions:

```text
dim_date
dim_channel
```

The five analytical serving datasets have intentionally different grains and analytical purposes.

They must not be collapsed into a single wide reporting table.

---

# 5. Why a Single Wide BI Table Is Rejected

A single flattened BI table would require combining models with incompatible grains such as:

```text
date
date × channel
date × device × country
pseudo-user
```

Such a design would create one or more of the following problems:

- row multiplication
- duplicated measures
- ambiguous aggregation
- incompatible attribution populations
- difficult reconciliation
- unnecessary storage
- confusing Power BI relationships
- increased risk of invalid KPI calculations

The serving layer therefore preserves separate analytical datasets where grain or semantic purpose differs.

---

# 6. Executive Serving Model

## 6.1 Model

```text
bi_executive_daily
```

## 6.2 Grain

One row per:

```text
date_day
```

## 6.3 Primary Source

```text
executive_kpi_trends_daily
```

## 6.4 Design Decision

`executive_kpi_trends_daily` already preserves the governed daily KPI fields from `executive_kpi_daily` while adding the approved rolling and Week-over-Week metrics.

Therefore the BI serving architecture does not require separate serving copies of both:

```text
executive_kpi_daily
```

and:

```text
executive_kpi_trends_daily
```

Doing so would expose two overlapping daily executive datasets to Power BI without providing a distinct analytical grain or purpose.

`bi_executive_daily` therefore consumes `executive_kpi_trends_daily` as the consolidated executive reporting interface.

`executive_kpi_daily` remains an upstream governed dependency and validation layer.

---

# 7. Executive Serving Contract

`bi_executive_daily` must expose the governed fields required for executive reporting and correct period-level aggregation.

Required fields include:

## Date

- `date_day`

## Daily Additive KPI Components

- `session_count`
- `purchasing_session_count`
- `transaction_count`
- `purchase_revenue`
- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`

## Daily Governed Ratios

- `conversion_rate`
- `average_order_value`
- `revenue_per_session`

## Rolling Components and Metrics

- `revenue_7d`
- `sessions_7d`
- `purchasing_sessions_7d`
- `conversion_rate_7d`

## Prior-Period and Week-over-Week Metrics

- `revenue_previous_7d`
- `conversion_rate_previous_7d`
- `revenue_wow_absolute_change`
- `revenue_wow_pct_change`
- `conversion_wow_absolute_change`
- `conversion_wow_pct_change`

The additive components must remain available even when some are hidden from report consumers in Phase 9.

---

# 8. Executive Semantic Contract

The executive serving model contains multiple governed semantic families.

## Session-Date

- `session_count`
- `purchasing_session_count`
- `conversion_rate`
- `sessions_7d`
- `purchasing_sessions_7d`
- `conversion_rate_7d`
- conversion Week-over-Week metrics

## Transaction-Date

- `transaction_count`
- `purchase_revenue`
- `average_order_value`
- `revenue_7d`
- revenue Week-over-Week metrics

## Session-Cohort

- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`
- `revenue_per_session`

These families may share `date_day` as a reporting field but must not be interpreted as the same analytical population.

---

# 9. Channel Serving Model

## 9.1 Model

```text
bi_channel_daily
```

## 9.2 Grain

One row per:

```text
session_date × channel_key
```

## 9.3 Primary Source

```text
executive_channel_drivers_daily
```

## 9.4 Purpose

The model provides the governed acquisition and channel-performance interface for Power BI.

It supports:

- traffic mix
- purchasing-session mix
- channel conversion
- session-attributed transaction contribution
- session-attributed revenue contribution
- channel filtering and ordering

---

# 10. Channel Serving Contract

Required fields include:

## Keys and Dimensions

- `session_date`
- `channel_key`
- `channel_group`
- `channel_description`
- `sort_order`

## Additive Measures

- `session_count`
- `purchasing_session_count`
- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`

## Governed Ratios and Contributions

- `conversion_rate`
- `session_contribution`
- `purchasing_session_contribution`
- `transaction_contribution`
- `revenue_contribution`

The channel model must preserve explicit session-attributed naming for commercial measures.

It must not rename these fields to generic transaction-date terminology.

---

# 11. Channel Aggregation Contract

Daily channel contribution values are valid at their governed daily grain.

For multi-day reporting, Power BI must not calculate:

```text
SUM(revenue_contribution)
```

or:

```text
AVG(revenue_contribution)
```

Instead, contribution must be recalculated from compatible additive components.

For example:

```text
SUM(channel session-attributed purchase revenue)
/
SUM(total compatible session-attributed purchase revenue)
```

Channel conversion across multiple dates must likewise be calculated as:

```text
SUM(purchasing_session_count)
/
SUM(session_count)
```

and not as the average of daily channel conversion rates.

---

# 12. Commerce Serving Model

## 12.1 Model

```text
bi_commerce_daily
```

## 12.2 Grain

One row per:

```text
date_day
```

## 12.3 Primary Source

```text
mart_ecommerce_daily
```

## 12.4 Purpose

The model provides the transaction-date commerce interface required for detailed commercial reporting beyond the narrower executive KPI presentation.

The commerce serving model is intentionally separate from `bi_executive_daily`.

Although both use a daily grain, they serve different downstream purposes:

- `bi_executive_daily` provides governed executive KPI and trend reporting.
- `bi_commerce_daily` provides broader transaction-date commerce detail.

Sharing the same grain does not by itself justify merging the models.

---

# 13. Commerce Serving Contract

Required fields include:

## Date

- `date_day`

## Transaction-Date Additive Measures

- `transaction_count`
- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`

## Governed Transaction-Date Ratios

- `average_order_value`
- `items_per_transaction`

The model may retain additional date attributes only where P8C implementation shows that they materially improve downstream consumption.

The governed date dimension remains the preferred source of reusable calendar attributes.

---

# 14. Commerce Semantic Contract

The commerce serving model is specifically intended for transaction-date commercial analysis.

It must not silently substitute session-attributed measures for transaction-date measures.

`refund_value` remains a separate governed measure.

The model must not introduce:

```text
net_revenue = purchase_revenue - refund_value
```

unless a future governed KPI contract explicitly defines that metric.

Period-level Average Order Value must be recalculated as:

```text
SUM(purchase_revenue)
/
SUM(transaction_count)
```

Period-level Items per Transaction must be recalculated as:

```text
SUM(total_item_quantity)
/
SUM(transaction_count)
```

Daily ratio averages are not governed period-level calculations.

---

# 15. User Behaviour Serving Model

## 15.1 Model

```text
bi_user_behavior
```

## 15.2 Grain

One row per:

```text
user_pseudo_id
```

## 15.3 Primary Source

```text
mart_user_behavior
```

## 15.4 Purpose

The model provides a controlled analytical interface for observed pseudo-user behaviour across the available observation window.

It supports behavioral segmentation and descriptive analysis without implying authenticated customer identity.

---

# 16. User Behaviour Serving Contract

Required fields include:

## Analytical Identifier

- `user_pseudo_id`

## Session Behaviour

- `session_count`
- `active_date_count`
- `purchasing_session_count`
- `purchasing_date_count`

## Observation Dates

- `first_observed_session_date`
- `last_observed_session_date`
- `first_observed_purchase_date`
- `last_observed_purchase_date`
- `observed_user_span_days`

## Commercial Activity

- `transaction_count`
- `purchase_revenue`
- `refund_value`
- `total_item_quantity`

## Behavioural Flags

- `is_purchasing_user`
- `is_multi_session_user`
- `returned_on_later_date`
- `is_repeat_purchasing_session_user`
- `is_repeat_purchasing_date_user`

The serving model must preserve the distinction between observed pseudo-user behaviour and authenticated customer behaviour.

---

# 17. User Behaviour Limitations

`user_pseudo_id` must not be renamed or described as:

- customer_id
- authenticated_user_id
- account_id

unless a future source provides governed authenticated identity.

The following concepts must not be derived from the current pseudo-user mart without a new governed analytical design:

- customer lifetime value
- production-grade customer retention
- authenticated customer count
- customer tenure
- customer churn

Observed first and last dates are bounded by the available dataset and do not necessarily represent true lifetime first or last activity.

---

# 18. Segment Serving Model

## 18.1 Model

```text
bi_segment_daily
```

## 18.2 Grain

One row per:

```text
session_date × device_category × country
```

## 18.3 Primary Source

```text
mart_segment_daily
```

## 18.4 Purpose

The model provides the governed device and geography performance interface for Power BI.

It supports comparison of session and commercial performance across device and country segments.

---

# 19. Segment Serving Contract

Required fields include:

## Dimensions

- `session_date`
- `device_category`
- `country`

## Additive Measures

- `session_count`
- `purchasing_session_count`
- `transaction_count`
- `purchase_revenue`

## Governed Ratios

- `conversion_rate`
- `revenue_per_session`

Within this model:

- `transaction_count` is session-attributed.
- `purchase_revenue` is session-attributed.

These fields must not be compared directly with transaction-date executive or commerce measures as though they represented the same population.

P8C may introduce clearer BI-facing aliases if required to protect this semantic distinction.

---

# 20. Date Dimension Contract

## 20.1 Model

```text
dim_date
```

## 20.2 Grain

One row per:

```text
date_day
```

## 20.3 Serving Decision

The governed `dim_date` is already the authoritative calendar dimension.

Phase 8 will not create a duplicate BI-specific date dimension unless implementation evidence demonstrates a genuine serving requirement.

Power BI should consume the governed date dimension for reusable calendar attributes.

Final date relationships and semantic-model configuration belong to Phase 9.

---

# 21. Channel Dimension Contract

## 21.1 Model

```text
dim_channel
```

## 21.2 Grain

One row per governed channel.

## 21.3 Serving Decision

The governed `dim_channel` remains the authoritative channel dimension.

Phase 8 will not create a duplicate BI-specific channel dimension solely for naming symmetry.

The dimension provides the governed channel key, classification, description, and presentation order.

Final relationship configuration belongs to Phase 9.

---

# 22. Relationship-Key Requirements

Serving datasets must expose the keys required for downstream semantic-model relationships.

Expected relationship fields include:

| Serving Dataset | Relationship Field | Dimension |
|---|---|---|
| `bi_executive_daily` | `date_day` | `dim_date.date_day` |
| `bi_channel_daily` | `session_date` | `dim_date.date_day` |
| `bi_channel_daily` | `channel_key` | `dim_channel.channel_key` |
| `bi_commerce_daily` | `date_day` | `dim_date.date_day` |
| `bi_segment_daily` | `session_date` | `dim_date.date_day` |

`bi_user_behavior` does not require a conventional many-to-one relationship to `dim_date` based on its multiple observation-date fields.

Those fields represent descriptive pseudo-user lifecycle observations rather than a single fact-date grain.

The exact Power BI relationship configuration is deferred to Phase 9.

---

# 23. No Fact-to-Fact Join Requirement

The serving models are not designed to be joined directly to one another.

In particular, Power BI must not create direct fact-to-fact relationships between:

- `bi_executive_daily`
- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_segment_daily`
- `bi_user_behavior`

Shared governed dimensions should provide filtering where appropriate.

Cross-subject comparisons must respect semantic compatibility rather than rely on direct joins between serving datasets.

---

# 24. Field Naming Strategy

The serving layer will preserve governed upstream names where those names are already clear and semantically safe.

Renaming is justified when it:

- improves business readability
- removes implementation-specific terminology
- makes attribution semantics clearer
- prevents downstream misinterpretation
- creates consistency across serving interfaces

Renaming is not justified merely to make every serving field look different from its upstream source.

P8D will finalize the business-facing naming and field-exposure interface.

---

# 25. Materialization Strategy

P8B does not assume that every serving model requires a physically materialized table.

The appropriate materialization will be determined during implementation and performance review based on:

- model complexity
- downstream reuse
- BigQuery scan behavior
- Power BI refresh requirements
- data volume
- operational simplicity

Simple serving projections should not be materialized unnecessarily merely to make the architecture appear more complex.

Likewise, materialization should not be avoided where it provides a measurable downstream benefit.

---

# 26. Power BI Storage Assumption

The initial downstream design assumes Power BI Import mode.

This is appropriate for the current bounded analytical dataset unless later performance evidence indicates otherwise.

The serving architecture therefore prioritizes:

- compact datasets
- stable grains
- controlled column exposure
- predictable refresh
- clear relationships
- minimal semantic ambiguity

DirectQuery or composite storage is not introduced without a demonstrated requirement.

---

# 27. dbt Calculation Ownership

The following calculations remain owned by dbt:

- sessionization
- purchasing-session classification
- transaction deduplication
- channel classification
- transaction-date revenue
- session-attributed revenue
- governed daily conversion
- governed daily Average Order Value
- governed daily Revenue per Session
- governed executive rolling metrics
- governed executive Week-over-Week metrics
- governed channel contribution metrics

Serving models may expose these calculations but must not independently redefine them.

---

# 28. Power BI Calculation Ownership

Power BI may create measures required for changing report filter context when those measures are direct reaggregations of governed additive components.

Examples include:

```text
period conversion
=
SUM(purchasing_session_count)
/
SUM(session_count)
```

and:

```text
period AOV
=
SUM(purchase_revenue)
/
SUM(transaction_count)
```

These calculations do not redefine the governed KPI.

They reproduce the governed formula at the active reporting grain.

Power BI may also own:

- formatting
- percentage display
- percentage-point display
- report labels
- display folders
- field visibility
- navigation
- visual interaction logic

---

# 29. Rejected Serving Patterns

The following patterns are explicitly rejected.

## 29.1 Mechanical One-to-One Wrappers

Creating a BI model for every upstream model using only:

```sql
select *
from {{ ref('upstream_model') }}
```

without a consumption, naming, semantic, or performance purpose.

## 29.2 Single Wide Reporting Table

Flattening all subject areas into one dataset despite incompatible grains.

## 29.3 BI-Side Business Logic Reconstruction

Rebuilding governed metrics or attribution logic in DAX or Power Query.

## 29.4 Fact-to-Fact Semantic Relationships

Connecting serving facts directly because they share dates or apparent dimensions.

## 29.5 Semantic Renaming That Hides Attribution

Renaming session-attributed revenue or transactions in a way that causes them to appear equivalent to transaction-date commercial measures.

## 29.6 Premature Physical Optimization

Introducing incremental models, partitioning, clustering, DirectQuery, or complex aggregation structures without evidence that the current workload requires them.

---

# 30. Planned Dependency Flow

The planned serving dependency flow is:

```text
executive_kpi_daily
        |
        v
executive_kpi_trends_daily
        |
        v
bi_executive_daily
```

```text
mart_channel_daily
        |
        v
executive_channel_drivers_daily
        |
        v
bi_channel_daily
```

```text
mart_ecommerce_daily
        |
        v
bi_commerce_daily
```

```text
mart_user_behavior
        |
        v
bi_user_behavior
```

```text
mart_segment_daily
        |
        v
bi_segment_daily
```

Governed dimensions remain:

```text
dim_date
dim_channel
```

and are consumed directly rather than duplicated without justification.

---

# 31. Planned Serving Model Summary

| Model | Grain | Primary Source | Primary BI Purpose |
|---|---|---|---|
| `bi_executive_daily` | date | `executive_kpi_trends_daily` | Executive KPIs and trends |
| `bi_channel_daily` | session date × channel | `executive_channel_drivers_daily` | Acquisition and channel drivers |
| `bi_commerce_daily` | date | `mart_ecommerce_daily` | Transaction-date commerce analysis |
| `bi_user_behavior` | pseudo-user | `mart_user_behavior` | Observed user behaviour |
| `bi_segment_daily` | session date × device × country | `mart_segment_daily` | Device and geography performance |
| `dim_date` | date | Core Warehouse | Governed calendar dimension |
| `dim_channel` | channel | Core Warehouse | Governed channel dimension |

---

# 32. Implementation Requirements for P8C

P8C must implement the approved serving architecture while preserving the contracts in this document.

Implementation must verify for each serving model:

- source dependency
- declared grain
- required keys
- required measures
- semantic-family preservation
- business-field exposure
- absence of unintended row multiplication

P8C must not introduce new KPI definitions.

If implementation reveals that a proposed serving model adds no meaningful consumption boundary and is only a mechanical copy of its source, that model must be reconsidered rather than retained solely because it appears in this design.

Any such change must be documented before the architecture is treated as final.

---

# 33. Validation Expectations

Later Phase 8 validation must confirm:

- serving grain uniqueness
- dimension-key integrity
- row-count behavior
- date coverage
- additive-measure reconciliation
- KPI reconciliation
- semantic compatibility
- no unintended duplication
- stable downstream schema
- Power BI consumption readiness

The executive, channel, commerce, user-behaviour, and segment branches must be reconciled independently against their compatible upstream sources.

---

# 34. P8B Design Decision

The BI Serving Layer will use a small set of purpose-driven serving datasets rather than mechanically reproducing the upstream warehouse.

The approved planned analytical serving interfaces are:

```text
bi_executive_daily
bi_channel_daily
bi_commerce_daily
bi_user_behavior
bi_segment_daily
```

The governed dimensions:

```text
dim_date
dim_channel
```

will be consumed directly unless later implementation evidence justifies a BI-specific derivative.

`executive_kpi_trends_daily` will serve as the source of the consolidated executive serving dataset because it already carries the governed base executive KPIs together with approved rolling and Week-over-Week metrics.

The channel-driver branch remains separate because its grain and session-attributed commercial semantics differ from the headline executive branch.

Commerce remains separate to provide broader transaction-date commercial analysis.

Observed pseudo-user behaviour remains separate because its grain is the pseudo-user rather than date.

Device and geography performance remain separate because their grain is session date × device × country.

This architecture establishes the model contracts for P8C while deliberately avoiding unnecessary duplication, incompatible flattening, and migration of governed business logic into Power BI.