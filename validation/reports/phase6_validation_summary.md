# Phase 6 Validation Summary — Business Marts

## Project

Digital Commerce Performance Analytics

## Phase

Phase 6 — Business Marts

## Purpose

This document consolidates the validation, reconciliation, and performance-optimization evidence produced during the final Phase 6 work packages:

- P6F — Device / Geography Performance Mart
- P6G — Business Mart Validation
- P6H — Performance Optimization

The document preserves the original validation scope, governed KPI semantics, reconciliation evidence, physical-design decisions, and acceptance criteria established during those work packages.

---

# P6F — Device / Geography Performance Mart

## Scope

P6F introduced a governed daily segmentation mart for analyzing ecommerce performance by device category and country.

Implemented business mart:

- `mart_segment_daily`

The mart is built from the governed session fact and preserves session-level attribution for both behavioral and commercial measures.

## Mart Grain

`mart_segment_daily` contains one row per:

`session_date + device_category + country`

The governed `session_date` is inherited from `fct_sessions`.

Raw GA4 `event_date` is not used to define the mart date grain because profiling identified sessions spanning multiple raw event dates.

## Approved Segmentation Dimensions

The approved P6F dimensions are:

- `device_category`
- `country`

Device category and country were validated as stable within governed sessions before implementation.

Higher-cardinality or less suitable raw GA4 attributes were intentionally excluded from the mart:

- operating system
- browser
- region
- city

Acquisition dimensions such as source, medium, and campaign were also excluded because acquisition performance is already governed by the P6C channel mart.

## Dimension Normalization

Missing or analytically invalid device-category and country values are normalized to `Unknown` within the business mart.

Normalization is intentionally applied at the business-mart layer rather than altering raw or core warehouse semantics.

Final validation confirmed:

- Unknown device sessions: 0
- Unknown country sessions: 2,882

The 2,882 sessions with invalid or missing country information remain in the analytical population under the governed `Unknown` category.

## Governed Measures

The mart contains the following additive measures:

- `session_count`
- `purchasing_session_count`
- `transaction_count`
- `purchase_revenue`

The following governed ratios are calculated from those measures:

- `conversion_rate`
- `revenue_per_session`

Commercial measures in this mart use session attribution.

`transaction_count` and `purchase_revenue` therefore represent commercial outcomes attributed to the originating governed sessions rather than transaction-date activity.

This keeps behavioral and commercial measures aligned to the same segmentation and date population.

## Grain Validation

Final mart validation confirmed:

- mart rows: 17,052
- distinct `session_date + device_category + country` combinations: 17,052

Therefore, the composite mart grain is unique.

The pre-implementation governed grain profiling also identified 17,052 observed combinations. Business-mart normalization did not reduce the final grain count.

## Core Reconciliation

`mart_segment_daily` was reconciled directly against `fct_sessions`.

Final totals:

- sessions: 360,129
- purchasing sessions: 4,033
- transactions: 4,451
- purchase revenue: 307,640.0

All four measures reconcile to the governed session fact.

The reconciliation test confirms that segmentation and normalization do not remove or duplicate the governed session population or its session-attributed commercial measures.

## Metric Validation

Automated metric validation confirmed:

- session counts are positive
- purchasing-session counts are non-negative
- purchasing-session counts do not exceed session counts
- transaction counts are non-negative
- conversion rates remain between 0 and 1
- conversion rates reproduce the governed formula
- revenue per session reproduces the governed formula
- required ratio outputs are not unexpectedly null

`conversion_rate` is governed as:

    purchasing_session_count / session_count

`revenue_per_session` is governed as:

    purchase_revenue / session_count

These ratios must be recalculated from additive components when consumed at higher aggregation levels rather than summed or averaged from mart rows.

## Semantic Validation

Automated semantic validation confirmed that the final mart contains no raw invalid segmentation values represented as:

- null
- blank strings
- `(not set)`

Such country values are represented by the governed `Unknown` category.

Device-category values are restricted to the approved set:

- desktop
- mobile
- tablet
- Unknown

No sessions currently require the `Unknown` device category.

## Automated dbt Validation

The final P6F dependency-aware build completed successfully.

Final build execution:

- 1 table model
- 13 data tests
- 14 total selected nodes
- 14 passed
- 0 warnings
- 0 errors
- 0 skipped

Validated rules include:

- composite mart-grain uniqueness
- session-date referential integrity
- device-category accepted values
- required dimension non-nullness
- required additive-measure non-nullness
- session and commercial reconciliation
- conversion-rate validity
- revenue-per-session validity
- segmentation normalization semantics

## Attribution and Modeling Controls

P6F intentionally aggregates from `fct_sessions` only.

No direct join between session and transaction facts is introduced in the mart.

This design avoids fact-to-fact row multiplication and keeps device and geography segmentation aligned with the governed session population.

Average order value is intentionally excluded from this mart because the governed project definition of AOV uses transaction-date semantics. Introducing a session-attributed AOV under the same KPI name would create conflicting metric semantics.

## Known Analytical Limitations

`user_pseudo_id` and GA4 session attributes represent observed analytics behavior rather than authenticated customer identity.

Country represents the geography observed for the governed session and should not be interpreted as permanent customer residence.

The dataset currently contains only the device categories observed within the project window.

The mart does not provide city-, region-, browser-, or operating-system-level analysis.

Commercial measures are session-attributed and should not be interpreted as transaction-date reporting measures.

## P6F Acceptance

The Device / Geography Performance Mart preserves the governed Core Warehouse session population and session-attributed commercial totals while introducing a stable business-facing segmentation layer by device category and country.

The final mart contains 17,052 unique segment-date rows and reconciles to:

- 360,129 sessions
- 4,033 purchasing sessions
- 4,451 transactions
- 307,640.0 purchase revenue

All P6F schema tests, grain tests, reconciliation tests, metric-validity tests, and semantic tests pass.

No identified grain, attribution, normalization, reconciliation, or business-rule issue blocks downstream business-mart validation.

P6F is technically ready for closeout.

---

# P6G — Business Mart Validation

## Validation Scope

P6G validates the business mart layer as an integrated analytical serving layer rather than validating each mart only in isolation.

The validated business marts are:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`
- `mart_user_behavior`

The validation focuses on:

- full business-layer build health
- cross-mart KPI reconciliation
- observed date coverage consistency
- daily KPI consistency across session-date marts
- preservation of governed KPI attribution semantics

## Business Mart Inventory

The business layer contains four governed marts:

| Mart | Primary Grain | Primary Consumer |
|---|---|---|
| `mart_channel_daily` | session date × channel | acquisition and channel performance |
| `mart_ecommerce_daily` | calendar date | executive ecommerce performance |
| `mart_segment_daily` | session date × device category × country | device and market segmentation |
| `mart_user_behavior` | user | observed user behavior |

The marts intentionally serve different analytical grains while sharing governed business metrics where semantically appropriate.

## Full Business-Layer Build

Command executed:

    dbt build --select path:models/marts/business

Final result:

- table models: 4
- data tests: 96
- total build nodes: 100
- PASS: 100
- WARN: 0
- ERROR: 0
- SKIP: 0

**Status: PASS**

This confirms that all four business marts can be rebuilt together and that all model-level and business-layer tests pass in the same execution.

## Cross-Mart Governed KPI Reconciliation

The following session-attributed measures were reconciled across all four business marts:

| Metric | Governed Total |
|---|---:|
| Sessions | 360,129 |
| Purchasing Sessions | 4,033 |
| Transactions | 4,451 |
| Purchase Revenue | 307,640.0 |

All four marts produced exactly the same governed totals when aggregated to the comparable session-attributed level.

For `mart_ecommerce_daily`, the comparison intentionally uses:

- `session_attributed_transaction_count`
- `session_attributed_purchase_revenue`

rather than transaction-date activity measures.

This preserves the KPI attribution contract and avoids comparing metrics defined on different date semantics.

Automated regression test:

    assert_business_marts_cross_mart_reconciliation

**Status: PASS**

## Observed Date Coverage Validation

Date coverage was compared across the three marts whose analytical grain includes session date:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`

For `mart_ecommerce_daily`, only dates with `session_count > 0` were included because the model uses a date spine and can therefore contain calendar dates without observed sessions.

Validation result:

| Check | Result |
|---|---:|
| Observed dates | 92 |
| First observed date | 2020-11-01 |
| Last observed date | 2021-01-31 |
| Missing from channel mart | 0 |
| Missing from ecommerce mart | 0 |
| Missing from segment mart | 0 |

Automated regression test:

    assert_business_marts_consistent_date_coverage

**Status: PASS**

## Daily KPI Reconciliation

Grand-total reconciliation alone cannot detect cases where an overstatement on one date is offset by an understatement on another date.

Therefore, session-attributed KPIs were also reconciled at daily grain across:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`

Metrics compared:

- session count
- purchasing session count
- transaction count
- purchase revenue

Validation result:

| Check | Result |
|---|---:|
| Compared dates | 92 |
| Mismatched dates | 0 |
| Maximum channel session difference | 0 |
| Maximum segment session difference | 0 |
| Maximum channel transaction difference | 0 |
| Maximum segment transaction difference | 0 |
| Maximum channel revenue difference | 0.0 |
| Maximum segment revenue difference | 0.0 |

Automated regression test:

    assert_business_marts_daily_reconciliation

**Status: PASS**

This confirms that governed session-attributed KPIs reconcile not only at full-period totals but also on every observed session date.

## Attribution and Semantic Controls

Cross-mart validation preserves the KPI contracts established during mart design.

Specifically:

- session metrics are governed by session attribution
- session-attributed commercial measures remain tied to the originating session
- transaction-date measures are not substituted into session-date comparisons
- `mart_ecommerce_daily` session-attributed fields are used when reconciling against session-based marts
- user-level aggregation in `mart_user_behavior` reconciles back to the same governed session and commercial totals
- segmentation does not introduce row multiplication or metric inflation

This prevents apparently matching metric names from being compared when their underlying attribution semantics differ.

## Regression Coverage Added in P6G

Three business-layer regression tests were added:

1. `assert_business_marts_cross_mart_reconciliation`
2. `assert_business_marts_consistent_date_coverage`
3. `assert_business_marts_daily_reconciliation`

Together they detect three distinct classes of failure:

- full-period KPI drift between marts
- missing or inconsistent observed session dates
- date-level KPI drift that could remain hidden in matching grand totals

These tests complement, rather than duplicate, the grain, metric, semantic, and reconciliation tests already implemented for each individual mart.

## P6G Acceptance

P6G is accepted when:

- all business marts build successfully together
- all existing mart-level tests pass
- governed KPI totals reconcile across marts
- observed date coverage is consistent across session-date marts
- daily session-attributed KPIs reconcile without mismatches
- no attribution-contract violations are introduced
- automated regression tests protect the validated cross-mart behavior

All acceptance criteria were satisfied.

### P6G Final Status

**P6G — Mart Validation: PASS**

---

# P6H — Performance Optimization

## Objective

P6H evaluates whether the current dbt business-serving layer requires physical or materialization-level optimization for BigQuery.

The purpose of this phase is not to introduce optimization features by default. Instead, optimization decisions are based on:

- table size
- model grain
- upstream scan volume
- expected analytical access patterns
- Power BI consumption
- implementation complexity
- current data scale

## Business Mart Storage Profile

The four business marts were profiled using BigQuery table metadata.

| Model | Row Count | Logical Size |
|---|---:|---:|
| `mart_user_behavior` | 270,154 | 29.34 MB |
| `mart_segment_daily` | 17,052 | 1.21 MB |
| `mart_channel_daily` | 668 | 0.11 MB |
| `mart_ecommerce_daily` | 92 | 0.02 MB |

The marts are small analytical serving tables, including the user-grain mart.

## Upstream Core Storage Profile

The primary upstream warehouse models used by the business marts were also profiled.

| Model | Row Count | Logical Size |
|---|---:|---:|
| `fct_sessions` | 360,129 | 136.99 MB |
| `fct_transactions` | 4,451 | 1.20 MB |
| `dim_date` | 92 | 0.01 MB |
| `dim_channel` | 8 | negligible |

`fct_sessions` is the largest frequently scanned upstream table, but remains approximately 137 MB at the current project scale.

The `dim_channel` row count was verified directly:

    row_count = 8
    distinct_channel_keys = 8

## Materialization Assessment

All four business marts are currently materialized as BigQuery tables.

### Decision

**Retain table materialization for all business marts.**

Models:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`
- `mart_user_behavior`

Table materialization remains appropriate because:

- Power BI consumes stable analytical outputs rather than repeatedly executing transformation SQL
- mart outputs are small
- rebuild cost is low at the current scale
- persisted tables provide predictable BI performance
- no additional materialization strategy currently provides a meaningful benefit

## Partitioning Assessment

### `mart_channel_daily`

Grain:

    session_date × channel

Size:

    668 rows
    0.11 MB

Decision:

**Do not partition.**

The table is too small for partition pruning to provide a meaningful performance or cost benefit.

### `mart_ecommerce_daily`

Grain:

    calendar date

Size:

    92 rows
    0.02 MB

Decision:

**Do not partition.**

The entire model is already extremely small and date-grained. Partitioning would add unnecessary physical design complexity.

### `mart_segment_daily`

Grain:

    session_date × device_category × country

Size:

    17,052 rows
    1.21 MB

Decision:

**Do not partition.**

Although the model includes a natural date column, its total storage footprint remains sufficiently small that partition pruning would provide negligible practical benefit.

### `mart_user_behavior`

Grain:

    user_pseudo_id

Size:

    270,154 rows
    29.34 MB

Decision:

**Do not partition.**

The model does not have a natural row-level date partition key. First/last observed dates describe user behavior but do not represent an appropriate physical partitioning grain for the table.

## Clustering Assessment

Clustering was evaluated particularly for `mart_user_behavior`, the largest business mart.

Potential clustering candidates could include behavioral flags or user identifiers.

### Decision

**Do not introduce clustering at the current scale.**

Reasons:

- the table is only approximately 29 MB
- low-cardinality behavioral flags are weak clustering candidates
- clustering by a high-cardinality user identifier is not currently supported by a demonstrated BI query pattern
- no measured workload currently shows scan cost or latency that would justify clustering
- premature clustering would add design complexity without evidence of material benefit

Clustering should be reconsidered if the mart grows substantially or production query patterns demonstrate repeated selective filtering on suitable columns.

## Incremental Materialization Assessment

### Decision

**Do not convert current marts to incremental models.**

The current analytical dataset covers a bounded historical period and the upstream pipeline is not operating as a production-scale continuously growing ingestion workload.

At the current size:

- full table rebuilds are inexpensive
- transformation logic remains simpler and easier to validate
- no complex incremental merge logic is required
- no late-arriving-data strategy needs to be introduced
- semantic consistency is easier to maintain

Incremental materialization should be introduced only when data growth and rebuild cost justify the additional state-management complexity.

## Upstream Optimization Assessment

The business marts repeatedly aggregate `fct_sessions`, so upstream scan size was reviewed before concluding that mart-level optimization was unnecessary.

The largest relevant table is:

    fct_sessions
    360,129 rows
    136.99 MB

At approximately 137 MB, the current scan volume remains small for BigQuery.

`fct_transactions` contains only 4,451 rows and approximately 1.20 MB.

Therefore, no upstream physical redesign is currently required solely to support the business marts.

## Optimization Decision Matrix

| Model | Materialization | Partition | Cluster | Incremental |
|---|---|---|---|---|
| `mart_channel_daily` | Table | No | No | No |
| `mart_ecommerce_daily` | Table | No | No | No |
| `mart_segment_daily` | Table | No | No | No |
| `mart_user_behavior` | Table | No | No | No |

No physical optimization change is currently justified.

## Future Optimization Triggers

The current decision is scale-dependent rather than permanent.

Performance optimization should be reassessed if one or more of the following occurs:

- `fct_sessions` grows substantially beyond the current data volume
- mart rebuild runtime becomes operationally significant
- BigQuery scan cost becomes material
- Power BI query latency becomes measurable
- session or transaction data is loaded continuously
- incremental ingestion becomes part of the architecture
- recurring query patterns create clear partition-pruning opportunities
- recurring selective filters create defensible clustering candidates

At that point, candidate strategies may include:

- partitioning session-based facts and marts by governed date
- clustering by frequently filtered dimensions
- incremental dbt materializations
- selective pre-aggregation
- revised BI import or refresh strategies

These changes should be driven by measured workload evidence.

## Engineering Rationale

The optimization decision for P6H intentionally favors evidence-based physical design over feature-driven optimization.

Adding partitioning, clustering, or incremental logic solely because those features are available would increase:

- implementation complexity
- maintenance overhead
- testing requirements
- semantic risk
- debugging surface

without producing a meaningful benefit at the current dataset scale.

Choosing not to optimize prematurely is therefore an explicit engineering decision rather than an omitted optimization step.

## P6H Acceptance

P6H is accepted when:

- business mart sizes have been measured
- major upstream scan volumes have been measured
- materialization strategy has been reviewed
- partitioning has been evaluated
- clustering has been evaluated
- incremental materialization has been evaluated
- optimization decisions are documented with technical rationale
- future optimization triggers are defined

All acceptance criteria were satisfied.

### P6H Final Status

**P6H — Performance Optimization: PASS**

---

# Phase 6 Final Acceptance

Phase 6 established and validated the governed business-mart layer used by the downstream Executive KPI and BI Serving layers.

The final Phase 6 business-mart inventory is:

| Mart | Grain | Analytical Role |
|---|---|---|
| `mart_channel_daily` | session date × channel | acquisition and channel performance |
| `mart_ecommerce_daily` | calendar date | ecommerce and executive KPI foundation |
| `mart_segment_daily` | session date × device category × country | device and geography segmentation |
| `mart_user_behavior` | user | observed pseudo-user behavior |

The integrated business-mart validation confirmed:

- 360,129 governed sessions
- 4,033 purchasing sessions
- 4,451 transactions
- 307,640.0 session-attributed purchase revenue
- 92 observed session dates
- zero daily KPI reconciliation mismatches across comparable session-date marts
- successful preservation of governed attribution semantics
- successful business-layer dbt validation

The P6F segmentation mart contains 17,052 unique `session_date + device_category + country` rows and reconciles completely to the governed session population.

The P6G integrated validation confirmed that all four business marts preserve compatible governed KPI totals and that cross-mart daily and full-period reconciliation controls pass.

The P6H performance assessment confirmed that the current BigQuery business-mart layer does not require partitioning, clustering, incremental materialization, or other physical redesign at the current project scale.

Optimization decisions remain scale-dependent and should be reconsidered only when measured data volume, rebuild cost, query latency, scan cost, or ingestion patterns justify additional physical-design complexity.

**Phase 6 — Business Marts: PASS**