# Business Marts Technical Design

## Document Purpose

This document defines the technical design for the governed business mart layer of the Digital Commerce Performance Analytics project.

The business mart layer sits between the core analytical warehouse and downstream BI consumption. Its purpose is to convert reusable warehouse facts and dimensions into business-oriented analytical datasets with explicit grains, governed KPI logic, predictable relationships, and efficient consumption patterns.

This design follows the business requirements defined in:

- `docs/business_requirements/business_marts_requirements.md`
- `docs/business_requirements/kpi_contracts.md`

The core warehouse models remain the authoritative analytical inputs to this layer.

---

# 1. Architectural Position

The governed analytical flow is:

`GA4 source → staging models → intermediate models → core warehouse → business marts → BI / analytical consumption`

Business marts must not rebuild logic already governed upstream.

In particular, business marts must consume:

- `fct_sessions`
- `fct_transactions`
- `dim_date`
- `dim_channel`

where appropriate.

Business marts must not independently reconstruct:

- session identity
- transaction identity
- transaction deduplication
- channel classification
- core warehouse relationships

---

# 2. Design Principles

The business mart layer follows these principles.

## 2.1 Consumer-oriented grain

Each mart must have an explicit grain based on the analytical question it serves.

The grain must be documented before implementation.

## 2.2 Governed KPI definitions

Metrics must follow the definitions established in `kpi_contracts.md`.

Equivalent business metrics must not use different formulas across marts.

## 2.3 Warehouse-first dependencies

Business marts must consume governed warehouse entities rather than staging or source-aligned models.

This keeps transformation responsibilities separated:

- staging standardizes source data
- intermediate models establish analytical entities
- warehouse models establish reusable dimensional structures
- business marts provide business-facing aggregations

## 2.4 Additive measures where possible

Base additive measures should be stored where useful.

Examples include:

- session count
- purchasing session count
- transaction count
- purchase revenue
- refund value
- shipping value
- tax value
- item quantity

Derived ratios should be calculated from governed numerator and denominator measures.

## 2.5 Avoid unnecessary grain expansion

Attributes must not be added to a mart if they change the intended grain without a clear consumer requirement.

More detailed analytical needs should use a separate mart where necessary.

## 2.6 BI-ready semantics

Business marts should expose stable names and business-readable dimensions so downstream BI models do not need to reconstruct analytical logic.

---

# 3. Phase 6 Planned Mart Architecture

The approved Phase 6 mart scope is:

| Work Package | Mart Area | Primary Purpose |
|---|---|---|
| P6C | Marketing / Channel | Acquisition and channel performance |
| P6D | Ecommerce Performance | Commercial and transaction performance |
| P6E | Customer Behavior | User and session behavior |
| P6F | Device / Geography | Performance segmentation |
| P6G | Validation | Mart integrity and reconciliation |
| P6H | Performance Optimization | Serving efficiency and final optimization |

Each mart will be implemented only after its grain and KPI contract are confirmed.

---

# 4. Marketing / Channel Mart

## 4.1 Business Purpose

The Marketing / Channel Mart provides a governed daily view of acquisition-channel performance.

It is designed to answer questions such as:

- How much traffic does each governed channel generate?
- Which channels generate purchasing sessions?
- Which channels generate transactions?
- How much purchase revenue is associated with each channel?
- What is the session conversion rate by channel?
- How does channel performance change over time?
- Which channels contribute the largest share of traffic and commercial outcomes?

The mart is intended for marketing, commercial, and management reporting.

---

# 5. Marketing / Channel Mart Grain

The approved grain is:

> One row per `session_date` and `channel_key`.

Conceptually:

`session_date + channel_key`

uniquely identifies a mart row.

This grain supports daily channel-performance analysis while remaining compact and stable for BI consumption.

---

# 6. Grain Validation

Profiling of the governed session fact produced the following results:

| Metric | Observed Value |
|---|---:|
| Sessions | 360,129 |
| Governed channels | 8 |
| Distinct sources | 235 |
| Distinct mediums | 8 |
| Distinct campaigns | 12 |
| Distinct acquisition combinations | 252 |
| Observed date + channel combinations | 668 |
| Observed detailed acquisition grain combinations | 2,653 |

The detailed acquisition grain was evaluated as:

`session_date + channel_key + source + medium + campaign`

This produces substantially more rows and represents a different analytical purpose from governed channel-level reporting.

The primary Marketing / Channel Mart therefore remains at:

`session_date + channel_key`

---

# 7. Source, Medium, and Campaign Decision

`source`, `medium`, and `campaign` will not be part of the primary Marketing / Channel Mart grain.

This is intentional.

The governed `channel_key` already represents the approved business-facing acquisition classification.

Including source-level attributes would change the semantic meaning of the mart from channel performance to detailed acquisition performance.

Profiling also shows that source cardinality varies significantly by governed channel.

For example, the Referral channel contains 224 distinct observed sources.

Therefore, source-level analysis should not be mixed into the governed daily channel mart.

If detailed acquisition analysis becomes a downstream requirement, it should be implemented as a separate mart with its own explicit grain and contract.

A potential future grain would be:

`session_date + channel_key + source + medium + campaign`

This is outside the primary P6C mart contract.

---

# 8. Marketing / Channel Mart Inputs

The primary source model is:

`fct_sessions`

The mart also uses:

`dim_channel`

for governed channel attributes.

`dim_date` remains the governed warehouse calendar dimension and provides the date semantics associated with `session_date`.

The mart must not derive channel classification directly from raw `source`, `medium`, or `campaign` values.

The existing `channel_key` from `fct_sessions` must be used.

---

# 9. Planned Marketing / Channel Mart Model

The planned model name is:

`mart_channel_daily`

Planned location:

`models/marts/business/mart_channel_daily.sql`

The mart will be aggregated from `fct_sessions`.

---

# 10. Planned Dimensions

The mart should expose the following analytical dimensions.

| Column | Purpose |
|---|---|
| `session_date` | Reporting date |
| `channel_key` | Stable governed acquisition-channel key |
| `channel_group` | Business-facing acquisition-channel label |
| `channel_description` | Governed channel definition |
| `sort_order` | Stable channel display order |

The composite grain is:

`session_date + channel_key`

---

# 11. Planned Base Measures

The mart should expose governed additive measures derived from the session fact.

| Measure | Definition |
|---|---|
| `session_count` | Number of governed sessions |
| `purchasing_session_count` | Number of sessions containing at least one governed purchase |
| `transaction_count` | Sum of governed transaction count across sessions |
| `purchase_revenue` | Sum of governed purchase revenue |
| `refund_value` | Sum of governed refund value |
| `shipping_value` | Sum of governed shipping value |
| `tax_value` | Sum of governed tax value |
| `total_item_quantity` | Sum of purchased item quantity |
| `unique_items` | Sum of session-level unique-item measures |

Base measures must reconcile to the governed warehouse inputs at equivalent aggregation levels.

---

# 12. Planned Derived KPIs

Derived KPIs must follow the definitions in `kpi_contracts.md`.

The initial mart should support:

## Session Conversion Rate

`purchasing_session_count / session_count`

## Transactions per Session

`transaction_count / session_count`

## Revenue per Session

`purchase_revenue / session_count`

## Revenue per Purchasing Session

`purchase_revenue / purchasing_session_count`

Derived KPI calculations must use safe division behavior when the denominator is zero.

Where practical, downstream BI tools should calculate ratios from governed base measures rather than summing pre-calculated percentages across rows.

---

# 13. Aggregation Strategy

The mart will aggregate `fct_sessions` by:

- `session_date`
- `channel_key`

The governed channel attributes will be obtained from `dim_channel`.

The aggregation must preserve the totals of additive measures from `fct_sessions`.

For any selected date range:

`sum(mart_channel_daily.session_count)`

must reconcile with the equivalent session population in `fct_sessions`.

Likewise, commercial measures must reconcile at equivalent scopes.

---

# 14. Relationship Strategy

The primary dimensional relationships are:

`dim_date → mart_channel_daily ← dim_channel`

Relationship keys:

- `dim_date.date_day → mart_channel_daily.session_date`
- `dim_channel.channel_key → mart_channel_daily.channel_key`

Expected relationship behavior:

- each mart date must exist in `dim_date`
- each mart channel key must exist in `dim_channel`
- each `session_date + channel_key` combination must be unique in the mart
- no null channel key is permitted
- no null session date is permitted

---

# 15. Expected Data Volume

Current profiling identified:

`668`

observed `session_date + channel_key` combinations in the governed session fact.

The initial mart is therefore expected to contain approximately 668 rows for the current static dataset.

The exact number remains data-dependent and must be validated after implementation.

The low row count is intentional because this mart is an aggregated serving model rather than a session-grain analytical fact.

---

# 16. Validation Requirements

The Marketing / Channel Mart must pass the following controls.

## Structural validation

- model builds successfully
- required columns exist
- required keys are non-null
- composite grain is unique

## Referential integrity

- every `session_date` exists in `dim_date`
- every `channel_key` exists in `dim_channel`

## Reconciliation

The mart must reconcile with `fct_sessions` for:

- session count
- purchasing session count
- transaction count
- purchase revenue
- refund value
- shipping value
- tax value
- total item quantity
- unique-item measure

## Business-rule validation

- session counts must not be negative
- purchasing session counts must not be negative
- purchasing session count must not exceed session count
- transaction count must not be negative
- commercial measures must respect the approved KPI contracts
- derived ratios must use safe denominator handling

---

# 17. Testing Strategy

Tests should be implemented at two levels.

## Generic dbt tests

Generic tests should cover:

- non-null required fields
- accepted dimensional relationships
- composite-grain uniqueness where supported by the project testing strategy

## Singular business tests

Singular SQL tests should cover business invariants that cannot be expressed clearly through generic schema tests.

Examples include:

- purchasing sessions cannot exceed total sessions
- mart dates must resolve to the governed date dimension
- mart channel keys must resolve to the governed channel dimension
- aggregated mart measures must reconcile with `fct_sessions`

Validation SQL outside transformation models may also be retained as explicit QA evidence.

---

# 18. Materialization Strategy

The initial business mart should be materialized as a table.

Rationale:

- it represents a stable BI-serving dataset
- its grain is significantly smaller than the underlying session fact
- repeated BI aggregation of the session fact is unnecessary
- materialization provides predictable downstream performance
- the current dataset is static and does not require incremental loading

Planned configuration:

`materialized = table`

Incremental materialization is not required for the current dataset.

---

# 19. Downstream Consumption

`mart_channel_daily` is intended to support:

- channel performance dashboards
- acquisition trend analysis
- traffic contribution analysis
- purchasing-session analysis
- channel conversion analysis
- channel revenue analysis
- management reporting

BI consumers should use governed mart measures rather than independently reconstructing channel classification or session-level KPI logic.

---

# 20. Known Limitations

The current design has the following limitations:

- the underlying GA4 dataset is a static public sample
- authenticated user identity is unavailable
- acquisition attributes are limited to the values available in the source dataset
- channel classification is based on the governed Phase 5 mapping
- source, medium, and campaign drill-down is intentionally excluded from the primary channel mart
- attribution modeling beyond the governed session acquisition fields is outside the current scope
- paid-media cost data is unavailable, so ROAS and cost-based acquisition KPIs cannot be calculated
- incremental processing is not required for the current static dataset

These limitations must not be hidden through unsupported derived metrics.

---

# 21. Future Extension

If a future business requirement requires detailed acquisition analysis, a separate mart may be introduced.

Potential model:

`mart_acquisition_daily`

Potential grain:

`session_date + channel_key + source + medium + campaign`

This model would complement rather than replace `mart_channel_daily`.

The decision to implement it must be driven by an explicit consumer requirement.

---

# 22. P6C Implementation Contract

P6C is approved to implement:

`mart_channel_daily`

with grain:

`one row per session_date + channel_key`

using:

- `fct_sessions`
- `dim_channel`

as the primary warehouse inputs.

The implementation must:

1. preserve governed channel classification
2. aggregate only at the approved grain
3. expose governed additive measures
4. support KPI calculations defined in `kpi_contracts.md`
5. maintain referential integrity with warehouse dimensions
6. reconcile with `fct_sessions`
7. avoid introducing unsupported source-level attribution logic

---

# 23. Next Implementation Step

After this design is approved, P6C proceeds with:

1. create the business mart model directory
2. implement `mart_channel_daily.sql`
3. add mart documentation and schema tests
4. add targeted business-rule tests
5. build the mart
6. validate the mart grain
7. validate dimensional relationships
8. reconcile mart measures with `fct_sessions`
9. commit the completed P6C implementation