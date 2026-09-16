# BI Refresh and Performance Strategy

## Project

Digital Commerce Performance Analytics

## Phase

Phase 8 — BI Serving Layer

## Work Package

P8E — Refresh & Performance Strategy

---

# 1. Purpose

This document defines the refresh, materialization, and performance strategy for the governed BI Serving Layer consumed by Power BI.

The strategy is based on observed serving-layer size and BigQuery processing estimates rather than optimization assumptions.

The objectives are to:

- provide responsive Power BI reporting
- minimize unnecessary BigQuery processing
- avoid premature infrastructure complexity
- preserve governed dbt transformation ownership
- define when future optimization should be reconsidered
- establish a clear refresh dependency between dbt and Power BI

---

# 2. Current Serving Architecture

The Phase 8 serving layer consists of five Power BI-oriented dbt models:

- `bi_executive_daily`
- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_user_behavior`
- `bi_segment_daily`

All five models are currently materialized as BigQuery views.

The serving models intentionally perform lightweight interface shaping over governed upstream marts and executive models.

They do not reconstruct:

- GA4 sessionization
- transaction identity
- channel classification
- KPI definitions
- attribution logic
- executive trend logic

This keeps the serving layer thin and reduces duplication between analytical layers.

---

# 3. Observed Serving-Layer Size

The Phase 8 serving models were profiled directly in BigQuery.

| Serving Model | Row Count |
|---|---:|
| `bi_user_behavior` | 270,154 |
| `bi_segment_daily` | 17,052 |
| `bi_channel_daily` | 668 |
| `bi_executive_daily` | 92 |
| `bi_commerce_daily` | 92 |

The current reporting footprint is therefore small.

Only the pseudo-user behavioural dataset exceeds 20,000 rows, and even that model contains fewer than 300,000 rows.

---

# 4. BigQuery Processing Profile

BigQuery query-validator estimates were captured using full-column reads of each serving view.

| Serving Model | Estimated Processing |
|---|---:|
| `bi_executive_daily` | 13.8 KB |
| `bi_channel_daily` | 106.27 KB |
| `bi_commerce_daily` | 6.3 KB |
| `bi_user_behavior` | 29.34 MB |
| `bi_segment_daily` | 1.21 MB |

The highest estimated scan is approximately 29.34 MB for `bi_user_behavior`.

This confirms that the current serving layer does not require aggressive physical optimization.

---

# 5. Power BI Storage Mode Decision

## Decision

Use:

```text
Power BI Import mode
```

for the implemented Power BI semantic model.

## Rationale

Import mode is appropriate because:

- the serving datasets are small
- BigQuery extraction volume is low
- report visuals will query the in-memory semantic model rather than repeatedly querying BigQuery
- interactive report performance should therefore be strong
- the project does not require real-time or near-real-time querying
- DirectQuery would introduce unnecessary source-query latency and modeling constraints
- the serving layer has already centralized business logic upstream

Import mode also provides a cleaner separation between:

```text
BigQuery + dbt
        ↓
governed analytical data
        ↓
Power BI semantic model
        ↓
reports
```

---

# 6. DirectQuery Decision

## Decision

Do not use DirectQuery for the current implementation.

## Rationale

DirectQuery is not justified by the current requirements or data scale.

The project does not currently require:

- real-time source access
- sub-refresh-cycle freshness
- extremely large fact datasets that cannot be imported
- source-side security behaviour requiring live execution
- operational dashboards dependent on continuously changing transactions

Using DirectQuery at the current scale would add complexity without delivering a meaningful business or performance advantage.

---

# 7. Serving Materialization Decision

## Decision

Retain the Phase 8 serving models as:

```text
BigQuery views
```

rather than converting them to physical tables.

## Rationale

The serving models:

- are lightweight
- have low scan volumes
- contain limited transformation logic
- depend on governed upstream models
- do not currently create material refresh bottlenecks
- are consumed through Power BI Import rather than high-frequency DirectQuery

Creating physical serving tables would introduce additional:

- storage
- orchestration
- refresh dependencies
- stale-data risk
- model duplication

without a demonstrated performance need.

---

# 8. Physical Table Optimization

The serving layer does not currently require:

- table partitioning
- clustering
- incremental dbt materialization
- pre-aggregated physical serving tables
- materialized views

These techniques should not be introduced only because they are available.

Physical optimization should solve an observed problem.

The current profiling results do not demonstrate such a problem.

---

# 9. Partitioning Strategy

## Current Decision

No serving-layer partitioning is required.

The daily serving datasets contain only:

```text
92 reporting dates
```

and very small row counts.

The pseudo-user model contains approximately:

```text
270,154 rows
```

but it is not naturally consumed as a date-partitioned daily fact table.

Partitioning it merely for architectural appearance would not provide a meaningful benefit in the current environment.

Upstream model partitioning may still be appropriate where source scale and query patterns justify it.

That decision remains independent of the serving-layer interface.

---

# 10. Clustering Strategy

## Current Decision

No additional clustering is required for Phase 8 serving models.

Potential clustering fields such as:

- `channel_key`
- `device_category`
- `country`
- `user_pseudo_id`

do not provide sufficient benefit at the current data volumes to justify additional physical materialization.

Clustering should be reconsidered only if query workloads demonstrate repeated large scans or selective filtering against materially larger physical tables.

---

# 11. Incremental dbt Strategy

## Current Decision

Do not implement incremental serving models.

The current serving datasets are inexpensive to rebuild and query.

Incremental materialization would introduce additional logic for:

- merge keys
- late-arriving records
- historical updates
- backfills
- incremental predicates
- full-refresh recovery

without solving a demonstrated runtime problem.

The existing view strategy is simpler and more reliable for the current scope.

---

# 12. Power BI Incremental Refresh

## Current Decision

Power BI incremental refresh is not configured in the implemented semantic model.

A standard Import refresh is sufficient because:

- imported data volume is small
- BigQuery scan volume is low
- date history is limited
- full extraction is inexpensive
- refresh complexity would exceed the expected benefit

Incremental refresh should be introduced only when full refresh becomes materially expensive or fails to meet an agreed refresh window.

---

# 13. Current Refresh Pattern

The current governed dataset represents a governed historical analytical dataset rather than a continuously operating production source.

For the present project implementation, the appropriate refresh pattern is:

```text
source data available
        ↓
dbt transformation/build
        ↓
dbt validation succeeds
        ↓
serving views become current
        ↓
Power BI Import refresh
```

Power BI should not refresh before the upstream dbt build has completed successfully.

---

# 14. Production-Equivalent Refresh Pattern

If this architecture were connected to continuously arriving production data, the expected orchestration would be:

```text
source ingestion
        ↓
dbt staging/intermediate/core
        ↓
business marts
        ↓
executive layer
        ↓
BI serving layer
        ↓
dbt tests and reconciliation
        ↓
Power BI semantic-model refresh
```

The Power BI refresh should therefore be downstream of successful analytical data preparation.

The BI tool should not independently compensate for incomplete upstream data.

---

# 15. Refresh Frequency

No real-time freshness requirement has been defined for the current project.

For the pcurrent project implementation:

```text
manual / on-demand refresh
```

is sufficient.

For a comparable production digital-commerce environment, an appropriate default starting point would typically be a scheduled batch refresh after upstream data processing completes.

The exact production cadence would depend on:

- source arrival frequency
- business reporting SLA
- leadership reporting needs
- BigQuery cost
- data latency
- Power BI capacity and refresh limits

The serving architecture does not hard-code a refresh frequency.

---

# 16. Power Query Transformation Strategy

Power Query should remain lightweight.

Complex business transformation should not be rebuilt inside Power BI.

Power Query may perform limited ingestion-oriented operations such as:

- source connection
- selecting required serving datasets
- basic metadata handling
- type confirmation where necessary

Power Query should not independently recreate:

- KPI formulas
- session attribution
- channel logic
- customer or pseudo-user logic
- executive trend calculations
- business-rule transformations already governed in dbt

The preferred architecture remains:

```text
dbt = analytical transformation
Power BI = semantic modeling and reporting
```

---

# 17. Column Selection

Power BI should import only fields required by the approved semantic model.

Unused warehouse columns should not be imported merely because they exist.

The current serving models already reduce upstream schemas to BI-oriented interfaces.

The implemented Power BI semantic model preserves this discipline by avoiding unnecessary duplicated fields.

Examples include:

- hiding technical relationship keys after configuration
- avoiding redundant fact-side descriptive dimensions
- excluding unused analytical helper fields from report authoring
- using explicit measures rather than exposing every numeric column

---

# 18. Semantic Model Performance

Once imported, report performance will depend primarily on Power BI semantic-model design rather than BigQuery scan performance.

The implemented semantic model therefore follows these performance principles:

- clear star-schema relationships
- one-directional filtering where appropriate
- explicit measures
- controlled field visibility
- avoiding unnecessary calculated columns
- avoiding many-to-many relationships unless analytically required
- avoiding fact-to-fact relationships
- using authoritative dimensions for slicing
- minimizing duplicated high-cardinality text fields

The serving layer has been designed to support these goals.

---

# 19. High-Cardinality Pseudo-User Data

`bi_user_behavior` is the largest serving dataset at:

```text
270,154 rows
```

and contains the high-cardinality field:

```text
user_pseudo_id
```

The identifier is required for user-grain integrity but should normally be hidden from report consumers.

Power BI reports should generally analyze user populations through:

- measures
- behavioural flags
- observed dates
- purchasing behaviour
- repeat-behaviour indicators

rather than rendering large lists of pseudo-user identifiers.

This reduces both model-authoring noise and unnecessary visual-level cardinality.

---

# 20. Query Cost Strategy

Current BigQuery processing estimates demonstrate very small source scans.

The largest tested full serving-view query is approximately:

```text
29.34 MB
```

Therefore, Phase 8 does not introduce additional physical optimization specifically for query-cost reduction.

Cost should continue to be managed through:

- thin serving views
- governed upstream models
- avoiding unnecessary `select *` use in production analytics
- Power BI Import mode
- controlled refresh frequency
- importing only required datasets and fields

---

# 21. Optimization Reconsideration Triggers

The current decisions are not permanent architectural constraints.

Performance strategy should be reassessed if one or more of the following occurs:

1. Power BI full refresh no longer completes within the required refresh window.
2. BigQuery processing per refresh grows materially.
3. Serving datasets grow from hundreds of thousands into multi-million-row workloads.
4. Repeated source queries create meaningful BigQuery cost.
5. Business requirements introduce substantially longer history.
6. Near-real-time reporting becomes required.
7. Power BI model size becomes operationally problematic.
8. Refresh failures become common.
9. User-facing report performance degrades.
10. A new workload requires highly selective query patterns against large physical tables.

Only then should solutions such as the following be evaluated:

- Power BI incremental refresh
- dbt incremental models
- partitioned tables
- clustered tables
- physical aggregate tables
- materialized serving datasets
- hybrid or DirectQuery architectures

---

# 22. Optimization Decision Framework

Future optimization should follow:

```text
Measure
  ↓
Identify bottleneck
  ↓
Determine where the bottleneck occurs
  ↓
Select the smallest effective optimization
  ↓
Validate improvement
```

The project should not follow:

```text
Add optimization feature
  ↓
assume performance improved
```

Performance engineering must remain evidence-driven.

---

# 23. Current Architecture Decision Summary

| Area | Phase 8 Decision |
|---|---|
| Power BI storage mode | Import |
| Serving model materialization | BigQuery views |
| Power BI refresh | Full refresh |
| Power BI incremental refresh | Not required |
| dbt incremental serving models | Not required |
| Serving partitioning | Not required |
| Serving clustering | Not required |
| DirectQuery | Not required |
| Materialized serving tables | Not required |
| Aggregate tables | Not required |
| Power Query transformations | Minimal |
| Business logic ownership | dbt |
| Semantic-model ownership | Power BI |
| Refresh dependency | Power BI after successful dbt pipeline |

---

# 24. Implemented Power BI Architecture

The Phase 8 storage and refresh decisions were carried forward into the implemented Power BI solution:

    BigQuery serving views
            ↓
    Power BI Import
            ↓
    governed semantic model
            ↓
    four-page analytical report

The final implementation does not use Power BI incremental refresh or DirectQuery.

No additional serving-layer physical optimization was required before or during semantic-model implementation.

The completed Power BI solution validated that the lightweight serving architecture was sufficient for the current dataset and reporting workload.

Future optimization should continue to be driven by observed performance bottlenecks rather than architectural complexity introduced in advance.

---

# 25. P8E Decision

The current BI Serving Layer is sufficiently small and inexpensive to support a simple Import-based Power BI architecture.

Observed evidence includes:

- a maximum serving-table row count of approximately 270,154
- a maximum observed full-view processing estimate of approximately 29.34 MB
- four of five serving datasets containing fewer than 20,000 rows
- three datasets containing fewer than 1,000 rows

Based on this evidence, Phase 8 intentionally avoids:

- DirectQuery
- incremental refresh
- incremental serving models
- additional partitioning
- additional clustering
- physical serving tables
- premature aggregation infrastructure

The approved strategy is:

```text
Govern logic in dbt
        ↓
Expose lightweight BigQuery views
        ↓
Validate upstream data
        ↓
Refresh Power BI Import model
        ↓
Optimize only when measured evidence justifies it
```

This provides the simplest architecture that satisfies the current reporting workload while leaving clear upgrade paths if production scale or freshness requirements change.
