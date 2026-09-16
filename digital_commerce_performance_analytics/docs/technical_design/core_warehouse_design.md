# Core Warehouse Design

## Project

Digital Commerce Performance Analytics

## Phase

Phase 5 — Core Warehouse

## Objective

Build a governed analytical warehouse layer on top of the validated GA4 intermediate models.

The warehouse layer provides stable, reusable entities for downstream KPI marts, commercial analytics, experimentation, and Power BI reporting.

The design prioritizes clear analytical grains, reusable business logic, reconciliation with the validated intermediate layer, and simplicity where additional dimensional structures do not provide meaningful analytical value.

---

## Upstream Models

The Phase 5 warehouse layer is built from the validated Phase 4 intermediate models:

- `int_ga4__session_events`
- `int_ga4__sessions`
- `int_ga4__transactions`

These models define the trusted analytical source layer for session and transaction behavior.

Sessionization, event sequencing, acquisition-event selection, and transaction deduplication are completed upstream and must not be rebuilt in the warehouse layer.

---

## Core Modeling Principles

1. Each warehouse model must have one explicit grain.
2. Fact tables must use stable business or governed analytical keys.
3. Measures must not be duplicated across incompatible grains.
4. Warehouse models must reconcile to their validated intermediate sources.
5. Downstream marts must not rebuild sessionization or transaction-deduplication logic.
6. Reusable business logic must live in governed dbt models rather than BI tools.
7. Dimensions must provide meaningful analytical value rather than exist only to satisfy a textbook star-schema structure.
8. Native BigQuery data types should be retained when they provide clear analytical semantics.
9. Warehouse models must remain understandable and defensible for downstream analysts and BI consumers.

---

# Approved Core Warehouse Entities

The approved Phase 5 core warehouse contains three primary models:

- `dim_date`
- `fct_sessions`
- `fct_transactions`

The design intentionally avoids dimensions that do not currently add sufficient analytical value.

Additional dimensions may be introduced later when downstream business requirements justify them.

---

## `dim_date`

### Grain

One row per calendar date.

### Primary Key

`date_day`

### Purpose

Provide a governed calendar dimension for consistent time-series analysis and downstream BI reporting.

### Implemented Attributes

- `date_day`
- `year`
- `quarter`
- `month`
- `month_number`
- `month_name`
- `week`
- `day_of_month`
- `day_of_week`
- `day_name`
- `is_weekend`

### Design Notes

The dimension uses a native BigQuery `DATE` value as its primary calendar key.

Integer date surrogate keys are not required for the current architecture because native dates provide clear semantics and straightforward joins across BigQuery, dbt, and Power BI.

The generated calendar range must cover all dates required by the governed analytical facts.

---

## `fct_sessions`

### Grain

One row per `session_key`.

### Primary Analytical Key

`session_key`

### Source

`int_ga4__sessions`

### Purpose

Provide the canonical session fact table for behavioral, acquisition, conversion, and commercial analysis.

### Implemented Measures

- `session_duration_seconds`
- `event_count`
- `transaction_count`
- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`
- `unique_items`
- `has_purchase`

### Implemented Descriptive Attributes and References

- `user_pseudo_id`
- `ga_session_id`
- `ga_session_number`
- `session_date`
- `session_start_timestamp`
- `session_end_timestamp`
- `platform`
- `landing_page`
- `landing_page_title`
- `exit_page`
- `exit_page_title`
- `source`
- `medium`
- `campaign`

### Design Notes

The warehouse does not recreate sessionization.

The governed `session_key` and session boundaries are inherited from the validated intermediate layer.

Acquisition, platform, landing-page, and exit-page attributes remain directly available on the session fact because separate dimensions do not currently provide sufficient analytical benefit to justify additional model complexity.

---

## `fct_transactions`

### Grain

One row per valid, deduplicated `transaction_id`.

### Primary Analytical Key

`transaction_id`

### Source

`int_ga4__transactions`

### Purpose

Provide the canonical transaction fact table for revenue, purchase, order-value, and transaction-level commercial analysis.

### Expected Measures

- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`
- `unique_items`

### Expected Descriptive Attributes and References

- `session_key`
- `user_pseudo_id`
- `transaction_date`
- `transaction_timestamp`
- `ga_session_id`
- `ga_session_number`
- `session_date`
- `session_start_timestamp`
- `session_end_timestamp`
- `platform`
- `landing_page`
- `landing_page_title`
- `source`
- `medium`
- `campaign`

### Design Notes

The warehouse does not perform transaction deduplication.

Only transactions accepted by the Phase 4 intermediate transaction model are represented.

`session_key` preserves the relationship between transaction and session grains.

Transaction acquisition attributes are inherited from the associated governed session context.

---

# Warehouse Relationships

## Date to Session

Relationship:

`dim_date.date_day`
→
`fct_sessions.session_date`

Cardinality:

one calendar date to zero or many sessions.

---

## Date to Transaction

Relationship:

`dim_date.date_day`
→
`fct_transactions.transaction_date`

Cardinality:

one calendar date to zero or many transactions.

---

## Session to Transaction

Relationship:

`fct_sessions.session_key`
→
`fct_transactions.session_key`

Cardinality:

one session to zero, one, or many transactions.

The relationship is retained through the governed `session_key` created in the intermediate layer.

---

# Dimensionality Decisions

## Acquisition Attributes

Acquisition attributes remain denormalized in `fct_sessions` and `fct_transactions`.

The warehouse retains:

- `source`
- `medium`
- `campaign`

A separate `dim_acquisition` model is not introduced in Phase 5.

These attributes are low-complexity, directly useful for downstream analysis, and do not currently justify an additional lookup entity.

If future requirements introduce governed channel groupings, campaign hierarchies, paid-media metadata, or other reusable acquisition classifications, a dedicated acquisition dimension can be reconsidered.

---

## Platform

`platform` remains directly on the fact tables.

A standalone `dim_platform` model is not introduced.

Platform cardinality is low, and the available source does not contain a richer governed platform hierarchy that would justify a separate dimension.

---

## User Modeling

A dedicated `dim_user` model is not introduced in Phase 5.

`user_pseudo_id` remains available as the analytical user identifier in the fact tables.

The available source does not contain sufficient stable customer-profile attributes to create a meaningful conformed customer dimension.

Creating a dimension that contains essentially only an identifier would add structural complexity without meaningful analytical value.

---

## Landing and Exit Pages

Landing-page and exit-page attributes remain directly on `fct_sessions`.

The session fact retains:

- `landing_page`
- `landing_page_title`
- `exit_page`
- `exit_page_title`

A separate page dimension is deferred.

The current analytical scope does not require governed page-level master data, reusable page classifications, or page hierarchies that would justify an additional dimension.

---

## Date Keys

Warehouse models use native BigQuery `DATE` values rather than integer date surrogate keys.

`dim_date.date_day` is the governed calendar key.

This approach keeps joins simple across BigQuery, dbt, and downstream Power BI while preserving explicit date semantics.

---

# Measure Ownership

Measures must remain associated with their correct analytical grain.

## Session-Grain Measures

The following measures are available at session grain in `fct_sessions`:

- session duration
- event count
- transaction count
- purchase revenue
- refund value
- shipping value
- tax value
- total item quantity
- unique items
- purchase flag

These measures support session-based behavioral and conversion analysis.

---

## Transaction-Grain Measures

The following measures are available at transaction grain in `fct_transactions`:

- purchase revenue
- refund value
- shipping value
- tax value
- total item quantity
- unique items

These measures support transaction and commercial analysis.

Downstream consumers must use the fact table that matches the required analytical grain to prevent double counting.

---

# Known Validated Baselines

Phase 4 validation established the following accepted baselines:

- 360,129 sessions
- 4,451 valid transactions
- 4,033 purchasing sessions
- 3,702 purchasing users
- 307,640 total purchase revenue
- 19,459 total item quantity

These values are acceptance baselines for Phase 5 reconciliation.

Warehouse transformations must preserve these validated business totals unless an intentional and documented warehouse rule changes the population.

---

# Phase 5 Quality Gates

Phase 5 completion required the following quality gates:

- `dim_date` must contain one row per calendar date.
- `dim_date.date_day` must be unique and non-null.
- `fct_sessions` must contain one row per `session_key`.
- `fct_sessions.session_key` must be unique and non-null.
- `fct_transactions` must contain one row per valid `transaction_id`.
- `fct_transactions.transaction_id` must be unique and non-null.
- required fact keys must be non-null.
- session-to-transaction relationships must remain valid.
- fact-to-date relationships must remain valid.
- session counts must reconcile to the intermediate layer.
- transaction counts must reconcile to the intermediate layer.
- purchasing-session counts must reconcile to the intermediate layer.
- purchase revenue must reconcile to the intermediate layer.
- item quantities must reconcile to the intermediate layer.
- business-rule dbt tests must pass.
- dependency-aware dbt builds must pass.
- manual warehouse reconciliation must be completed.
- warehouse documentation must be complete.
These quality gates were completed before Phase 5 was closed and the downstream business-mart layer was developed.

---

# Approved Phase 5 Scope

The implemented Phase 5 warehouse architecture is:

`dim_date`

`fct_sessions`

`fct_transactions`

The architecture deliberately remains lean.

The following dimensions were intentionally excluded from the Phase 5 implementation:

- `dim_acquisition`
- `dim_platform`
- `dim_user`
- `dim_page`

They may be introduced in a future phase only when analytical requirements justify the additional modeling complexity.

---

# Implementation Sequence and Outcome

Phase 5 was implemented in the following approved sequence:

1. Finalize core warehouse entity and grain design.
2. Build and validate `dim_date`.
3. Build and validate `fct_sessions`.
4. Build and validate `fct_transactions`.
5. Add schema and business-rule tests.
6. Reconcile warehouse outputs against Phase 4 baselines.
7. Complete Phase 5 documentation and quality gates.
8. Close Phase 5 before downstream KPI and reporting marts are developed.

Phase 5 was completed with the governed core warehouse models, required tests, reconciliation checks, and documentation in place before downstream KPI and business-mart development proceeded.