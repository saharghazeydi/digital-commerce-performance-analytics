# GA4 Source Feasibility Assessment

## Purpose

This document records the Phase 2 feasibility and profiling assessment of the
GA4 ecommerce source selected for the Digital Commerce Performance Analytics
project.

The assessment validates whether the source can support the intended analytical
entities, KPI calculations, dbt transformation design, and downstream Power BI
reporting requirements.

---

## Source Scope

### Source Dataset

`bigquery-public-data.ga4_obfuscated_sample_ecommerce`

### Source Platform

Google BigQuery public dataset.

### Source Pattern

The source consists of daily GA4 event tables following the naming convention:

`events_YYYYMMDD`

The tables are physical BigQuery base tables rather than views.

### Physical Storage Structure

The GA4 sample uses date-sharded daily tables rather than a single
date-partitioned event table.

Partition metadata inspection returned `NULL` partition identifiers for the
daily event tables.

Therefore, development queries must use `_TABLE_SUFFIX` filtering to restrict
the number of daily shards scanned.

---

## Source Access and Development Environment

Source access was validated from BigQuery and through the configured local dbt
development environment.

The project can query the public GA4 dataset successfully using the authenticated
Google Cloud development configuration.

The source is suitable for read-only analytical development.

---

## Source Grain

The physical source grain is GA4 event level.

A single row represents an event and may contain nested and repeated structures,
including:

- event parameters
- ecommerce attributes
- item arrays
- traffic-source attributes
- device attributes
- geographic attributes

Analytical entities such as sessions and transactions therefore require explicit
transformation logic rather than direct use of physical source rows.

---

## User Feasibility

`user_pseudo_id` provides the primary available anonymous user identifier.

It is suitable for behavioural user-level analysis within the limitations of the
sample dataset.

It must not be interpreted as a durable authenticated customer identifier.

---

## Session Feasibility

Session identity is not represented by `ga_session_id` alone.

Profiling established that session-level analytical logic should use a composite
identifier based on:

`user_pseudo_id + ga_session_id`

This composite grain is the approved candidate for downstream session modeling.

Additional validation will be implemented in dbt when the session entity is
constructed.

---

## Transaction Feasibility

Purchase events contain ecommerce transaction identifiers, but raw purchase
events are not guaranteed to represent unique business transactions.

Profiling identified repeated purchase events and duplicate transaction
identifiers.

A transaction-level analytical entity therefore requires explicit
deduplication.

Further profiling showed that a composite key based on:

`user_pseudo_id + transaction_id`

provides a safer analytical transaction identity than `transaction_id` alone
for this source.

Duplicate events sharing the composite transaction key showed consistent
commercial payloads in the profiling checks.

The transaction deduplication rule will be implemented and tested in the dbt
transformation layer rather than silently removing duplicate source rows.

---

## Invalid Transaction Identifiers

Purchase events include invalid or unavailable transaction identifiers,
including:

- `NULL`
- `(not set)`

These records cannot participate in the primary transaction-key strategy.

Profiling confirmed that fallback event-level identification is technically
possible without observed key collisions in the assessed source.

However, fallback records must remain explicitly distinguishable from validated
transaction records in downstream modeling.

---

## Revenue Feasibility

GA4 ecommerce purchase revenue is available through ecommerce purchase
attributes.

Raw purchase-event revenue must not be aggregated directly without transaction
deduplication because repeated purchase events would overstate commercial
performance.

Profiling demonstrated a material difference between raw valid purchase-event
revenue and revenue after transaction-level deduplication.

Revenue calculations in downstream models must therefore operate on the
governed transaction entity rather than directly on raw purchase events.

---

## Product Feasibility

GA4 purchase events include repeated item arrays.

The item structure supports downstream product-level analysis after controlled
unnesting.

Product metrics must preserve transaction context when item arrays are expanded
to avoid unintended row multiplication and revenue duplication.

---

## Acquisition Feasibility

The source contains traffic-source and event/session acquisition attributes that
can support acquisition and channel analysis.

Attribution semantics must be defined explicitly during transformation because
GA4 contains multiple traffic-source concepts at different analytical scopes.

No final attribution model is approved at the source-profiling stage.

---

## KPI Feasibility

The source is considered capable of supporting the project's intended core
commercial and behavioural KPIs, including:

- users
- sessions
- transactions
- revenue
- conversion rate
- average order value
- product performance
- acquisition performance
- device and geographic segmentation

These KPIs must be calculated from governed analytical entities rather than
directly from raw event rows.

Formal KPI contracts will be established in the business-mart phase.

---

## Data Quality Findings

Source profiling identified several conditions that require downstream controls:

1. repeated purchase events exist;
2. transaction identifiers are not universally available;
3. `(not set)` transaction identifiers occur;
4. transaction IDs alone are insufficient as the preferred analytical key;
5. session identifiers require user context;
6. nested and repeated fields can multiply rows when unnested;
7. raw purchase-event aggregation can overstate transaction and revenue metrics.

These conditions are treated as expected source-modeling constraints rather than
reasons to reject the dataset.

---

## Cost and Performance Considerations

The source is organized as daily sharded tables rather than a partitioned event
table.

Development queries must therefore restrict source scans using `_TABLE_SUFFIX`
and should use bounded date windows whenever full-history processing is not
required.

Profiling demonstrated that broad metadata or wildcard operations can scan
material data volumes. Query execution estimates must be reviewed during
development before running broad scans.

The project should avoid unrestricted wildcard scans during iterative
development.

Physical storage metadata through the `TABLE_STORAGE` information-schema view
was not available for this public dataset in the current query context.
This limitation does not prevent analytical development.

---

## Modeling Implications

The profiling results establish the following downstream design requirements:

- dbt source definitions must represent the daily GA4 event-table pattern;
- staging models must extract required nested event attributes consistently;
- session models must use an approved composite session identity;
- transaction models must explicitly deduplicate purchase events;
- invalid transaction identifiers must be handled separately;
- product models must control row multiplication during item unnesting;
- revenue metrics must originate from governed transaction-level models;
- development queries must apply bounded source-date filtering.

---

## Known Limitations

The source is an obfuscated public GA4 ecommerce sample and should not be treated
as a production ecommerce implementation.

Known limitations include:

- anonymous rather than authenticated customer identity;
- obfuscated sample data;
- incomplete transaction identifiers for some purchase events;
- duplicate purchase-event behavior requiring analytical deduplication;
- GA4 attribution semantics requiring explicit modeling decisions;
- daily sharded physical storage;
- unavailable `TABLE_STORAGE` metadata in the current public-dataset query
  context.

These limitations will be carried forward into model documentation and final
portfolio documentation where relevant.

---

## Phase 2 Feasibility Decision

**Decision: ACCEPTED**

The GA4 ecommerce source is sufficiently complete and structurally suitable to
support the planned analytics-engineering implementation.

The identified data-quality issues are manageable through explicit dbt
transformation logic, testing, reconciliation, and documentation.

No identified source limitation blocks progression to the dbt source and staging
phase.

---

## Next Phase

Phase 3 — dbt Source and Staging Layer.

The next implementation work will establish governed dbt source definitions
before staging transformation logic is introduced.
