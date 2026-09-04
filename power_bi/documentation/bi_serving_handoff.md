# BI Serving Layer Handoff

## 1. Purpose

This document defines the handoff from the governed dbt BI serving layer to the Power BI semantic-model implementation.

It is the operational contract between:

- **Phase 8 — BI Serving Layer**, which owns the Power BI-ready analytical datasets and their governed upstream semantics; and
- **Phase 9 — Power BI Semantic Model**, which will consume those datasets and implement relationships, explicit measures, formatting, visibility, and semantic-model behavior.

The Power BI layer must consume the approved serving interfaces without reconstructing or redefining governed upstream business logic.

---

## 2. Approved Power BI Data Sources

Power BI should import the following analytical serving datasets:

| Model | Grain | Primary Analytical Purpose |
|---|---|---|
| `bi_executive_daily` | One row per governed calendar date | Executive KPIs and governed trend metrics |
| `bi_channel_daily` | One row per session date × channel | Channel performance and contribution analysis |
| `bi_commerce_daily` | One row per governed calendar date | Transaction-date commercial performance |
| `bi_user_behavior` | One row per `user_pseudo_id` across the observation window | Pseudo-user behavior and repeat-activity analysis |
| `bi_segment_daily` | One row per session date × device category × country | Device and geography performance analysis |

Power BI should also consume the governed dimensions:

| Dimension | Purpose |
|---|---|
| `dim_date` | Shared governed calendar dimension |
| `dim_channel` | Governed channel classification, descriptions, and sort order |

These seven datasets form the approved initial Power BI import boundary.

---

## 3. Dataset Roles

### `bi_executive_daily`

Purpose:

- executive KPI cards;
- executive time-series analysis;
- governed 7-day trends;
- governed week-over-week comparisons.

This dataset contains multiple documented semantic families.

Headline measures must retain their governed date/population semantics.

The shared `date_day` field is a reporting date interface and does not make all measures interchangeable across semantic populations.

---

### `bi_channel_daily`

Purpose:

- channel performance;
- channel conversion;
- channel contribution;
- channel-attributed commercial analysis.

Grain:

```text
session_date × channel_key
```

Commercial measures in this dataset are **session-attributed**.

They must not be interpreted as transaction-date commercial measures.

---

### `bi_commerce_daily`

Purpose:

- transaction-date commercial performance;
- revenue;
- transaction volume;
- refund value;
- shipping value;
- tax value;
- item quantities;
- average order value;
- items per transaction.

Grain:

```text
date_day
```

This dataset intentionally exposes the transaction-date commercial interface from `mart_ecommerce_daily`.

It should be used when the analytical question is based on when transactions occurred.

---

### `bi_user_behavior`

Purpose:

- observed pseudo-user activity;
- multi-session behavior;
- purchasing-user behavior;
- repeat activity;
- observation-window user summaries.

Grain:

```text
user_pseudo_id
```

`user_pseudo_id` is a GA4 pseudo-user identifier.

It must not be presented as an authenticated customer identifier.

Power BI terminology should use **Pseudo-User** or another explicitly equivalent term rather than **Customer**.

---

### `bi_segment_daily`

Purpose:

- device performance;
- country performance;
- device × country segmentation;
- session-based conversion analysis;
- session-attributed commercial analysis.

Grain:

```text
session_date × device_category × country
```

The fields:

```text
session_attributed_transaction_count
session_attributed_purchase_revenue
```

are intentionally named to preserve attribution meaning.

They must not be shortened in ways that imply transaction-date semantics.

---

## 4. Semantic Population Boundaries

The BI model contains three important commercial/date populations.

### Session-Date Population

Used for metrics such as:

- sessions;
- purchasing sessions;
- conversion rate.

These metrics describe sessions occurring on the governed session date.

---

### Transaction-Date Population

Used for metrics such as:

- transaction count;
- purchase revenue;
- average order value;
- refund value;
- shipping value;
- tax value;
- item quantities.

These metrics describe commercial activity according to transaction date.

`bi_commerce_daily` is the primary BI interface for this population.

---

### Session-Attributed Population

Used for commercial metrics attributed back to the originating session population.

Examples include:

- session-attributed transaction count;
- session-attributed purchase revenue;
- revenue per session;
- channel-attributed commercial measures;
- segment-attributed commercial measures.

These measures must not be substituted for transaction-date measures.

---

## 5. Initial Relationship Design

Phase 9 should implement relationships based on the documented serving grains rather than attempting to connect analytical facts directly to one another.

Expected dimensional relationships include:

```text
dim_date[date_day]
    1 ─── * bi_executive_daily[date_day]

dim_date[date_day]
    1 ─── * bi_channel_daily[session_date]

dim_date[date_day]
    1 ─── * bi_commerce_daily[date_day]

dim_date[date_day]
    1 ─── * bi_segment_daily[session_date]
```

Expected channel relationship:

```text
dim_channel[channel_key]
    1 ─── * bi_channel_daily[channel_key]
```

The final Power BI relationship configuration must be validated in Phase 9.

### Relationship Principles

The semantic model should:

- use dimensions to filter analytical tables;
- prefer single-direction dimensional filtering;
- avoid fact-to-fact relationships;
- avoid unnecessary many-to-many relationships;
- avoid ambiguous filter paths; and
- preserve the grain of every serving dataset.

`bi_user_behavior` does not require a forced relationship to the daily analytical datasets merely to create a visually connected model.

Any relationship introduced for it must have a genuine analytical requirement and valid key semantics.

---

## 6. Power BI Measure Ownership

### dbt Owns

dbt remains authoritative for:

- sessionization;
- purchase validation and deduplication;
- transaction construction;
- acquisition/channel mapping;
- session attribution;
- governed daily KPI logic;
- governed rolling metrics;
- governed week-over-week metrics;
- governed channel contribution logic;
- business-mart population definitions; and
- serving-layer semantic aliases.

Power BI must not independently rebuild this logic.

---

### Power BI Owns

Power BI may own:

- explicit semantic-model measures;
- filter-context-aware aggregation;
- governed ratio recalculation from approved additive components;
- formatting;
- display names;
- visibility;
- sort behavior;
- display folders;
- report-facing semantic organization; and
- presentation-level calculations that do not redefine governed business logic.

---

## 7. Measure Construction Rules

### Additive Measures

Approved additive columns may be aggregated through explicit DAX measures.

Examples:

```text
Sessions
Purchasing Sessions
Transactions
Purchase Revenue
Session-Attributed Transactions
Session-Attributed Purchase Revenue
Refund Value
Shipping Value
Tax Value
Item Quantity
```

The exact source table must match the intended analytical population.

---

### Ratio Measures

Daily ratio columns must not be averaged across longer periods.

For example, period conversion should follow the governed relationship:

```text
Purchasing Sessions / Sessions
```

using compatible additive components under the active filter context.

Period average order value should follow:

```text
Purchase Revenue / Transaction Count
```

using transaction-date components.

Revenue per session should use compatible session-cohort/session-attributed components.

The BI interface contract remains authoritative for allowed downstream ratio behavior.

---

## 8. Governed Trend Metrics

`bi_executive_daily` exposes governed trend fields including:

```text
revenue_7d
sessions_7d
purchasing_sessions_7d
conversion_rate_7d
revenue_previous_7d
conversion_rate_previous_7d
revenue_wow_absolute_change
revenue_wow_pct_change
conversion_wow_absolute_change
conversion_wow_pct_change
```

These values should be consumed as governed trend outputs.

Power BI should not independently create an alternative definition under the same business name.

If a future reporting requirement needs a different rolling window or comparison period, that requirement should receive an explicit semantic decision rather than silently replacing the governed metric.

---

## 9. Contribution Metrics

Channel contribution fields are governed non-additive metrics.

Examples include:

```text
session_contribution
purchasing_session_contribution
transaction_contribution
revenue_contribution
```

These fields must not be summed across dates as if they were additive facts.

Phase 9 must configure their summarization and measure behavior accordingly.

---

## 10. Field Visibility

The physical dbt models retain stable technical `snake_case` field names.

Power BI should provide business-readable display names.

General rules:

- relationship keys should normally be hidden from report consumers;
- technical/helper fields should be hidden unless needed for analysis;
- raw additive columns used only as measure sources should normally be hidden;
- explicit measures should be preferred for report construction;
- daily ratios should not use implicit aggregation;
- trend metrics should not use implicit aggregation;
- contribution fields should not use implicit aggregation;
- pseudo-user terminology must remain explicit.

Detailed field-level rules are defined in:

```text
docs/business_requirements/bi_interface_contract.md
```

---

## 11. Refresh and Storage Strategy

The approved initial Power BI connectivity strategy is:

```text
BigQuery serving views
        ↓
Power BI Import mode
        ↓
Standard full refresh
```

For the current portfolio implementation:

- manual/on-demand refresh is sufficient.

The production-equivalent operating pattern is:

```text
upstream source availability
        ↓
successful dbt transformation pipeline
        ↓
serving-layer validation
        ↓
scheduled Power BI semantic-model refresh
```

The current evidence does not justify:

- DirectQuery;
- Power BI incremental refresh;
- dbt incremental serving models;
- additional serving-layer partitioning;
- additional serving-layer clustering;
- physical serving tables;
- materialized serving views; or
- aggregate tables.

These decisions should be reconsidered only if measured scale, refresh duration, query cost, concurrency, or freshness requirements materially change.

---

## 12. Power Query Boundary

Power Query should remain lightweight.

Appropriate Power Query responsibilities include:

- connecting to approved serving datasets;
- selecting required columns;
- assigning data types where necessary;
- applying minor presentation-oriented metadata changes.

Power Query should not reconstruct:

- session logic;
- attribution logic;
- KPI formulas;
- transaction logic;
- business segmentation logic already governed upstream; or
- complex transformations that belong in dbt.

---

## 13. Unsupported Metrics and Concepts

The current governed data product does not support the following concepts unless a future upstream contract is introduced:

- net revenue;
- profit;
- margin;
- CAC;
- CPA;
- ROAS;
- customer lifetime value;
- authenticated customer metrics;
- churn;
- retention;
- alternative or multi-touch attribution.

Power BI must not derive these concepts merely because some component fields are available.

---

## 14. Validation Status at Handoff

Before this handoff, the Phase 8 serving layer completed a dependency-aware dbt quality gate:

```text
PASS=358
WARN=0
ERROR=0
SKIP=0
TOTAL=358
```

All five BI serving datasets were also explicitly reconciled to their governed upstream contracts.

Final reconciliation:

| Serving Model | Upstream Rows | Serving Rows | Missing | Unexpected |
|---|---:|---:|---:|---:|
| `bi_executive_daily` | 92 | 92 | 0 | 0 |
| `bi_channel_daily` | 668 | 668 | 0 | 0 |
| `bi_commerce_daily` | 92 | 92 | 0 | 0 |
| `bi_user_behavior` | 270,154 | 270,154 | 0 | 0 |
| `bi_segment_daily` | 17,052 | 17,052 | 0 | 0 |

The serving layer therefore enters Power BI semantic modeling from a validated baseline.

---

## 15. Phase 9 Starting Point

Phase 9 should begin from the approved serving interfaces rather than from upstream raw, staging, intermediate, core, or business-mart models.

The first semantic-model activities should establish:

1. BigQuery connectivity using Import mode;
2. import of the approved serving datasets and dimensions;
3. model relationship configuration;
4. date-model behavior;
5. business-readable naming and field visibility;
6. explicit DAX measure creation;
7. formatting and display folders;
8. semantic-model validation; and
9. reconciliation of Power BI measures back to governed dbt outputs.

Dashboard and report-page design remains downstream of the semantic-model work.

---

## 16. Handoff Decision

The Phase 8 BI serving layer is approved for downstream Power BI semantic-model implementation.

The handoff boundary is:

```text
Governed dbt serving layer
        ↓
Power BI semantic model
        ↓
Power BI reports and dashboards
```

Phase 8 owns the validated data interface.

Phase 9 owns semantic-model implementation without redefining governed upstream business logic.