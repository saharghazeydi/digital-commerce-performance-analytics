# Core Warehouse Model Contracts

## Project

Digital Commerce Performance Analytics

## Phase

Phase 5 — Core Warehouse

## Work Package

P5B — Core Fact and Dimension Model Design

## Purpose

Document the approved implementation contracts that governed the Phase 5 core warehouse models.

These contracts specify model grain, upstream dependency, keys, columns, measures, materialization, and required quality rules, and remain the reference for validating the implemented warehouse structure.

---

# 1. `dim_date`

## Model Type

Dimension

## Grain

One row per calendar date.

## Primary Key

`date_day`

## Upstream Dependency

The required calendar range is derived from the governed analytical date range represented by:

- `int_ga4__sessions.session_date`
- `int_ga4__transactions.transaction_date`

## Materialization

Table

## Required Columns

| Column | Type | Role |
|---|---|---|
| `date_day` | DATE | Primary calendar key |
| `year` | INT64 | Calendar year |
| `quarter` | INT64 | Calendar quarter number |
| `quarter_name` | STRING | Calendar quarter label |
| `month_number` | INT64 | Calendar month number |
| `month_name` | STRING | Calendar month name |
| `year_month` | STRING | Year-month reporting label |
| `week_of_year` | INT64 | Calendar week number |
| `day_of_month` | INT64 | Day number within month |
| `day_of_week` | INT64 | Day number within week |
| `day_name` | STRING | Calendar day name |
| `is_weekend` | BOOL | Weekend indicator |

## Required Tests

- `date_day` is unique
- `date_day` is not null
- `year` is not null
- `quarter` is not null
- `month_number` is not null
- `day_of_month` is not null
- `day_of_week` is not null
- `is_weekend` is not null

## Acceptance Rule

The generated calendar must cover every session and transaction date represented in the governed intermediate layer.

---

# 2. `fct_sessions`

## Model Type

Fact

## Grain

One row per governed `session_key`.

## Primary Analytical Key

`session_key`

## Upstream Dependency

`int_ga4__sessions`

## Materialization

Table

## Required Columns

### Identifiers

- `session_key`
- `user_pseudo_id`
- `ga_session_id`
- `ga_session_number`

### Time

- `session_date`
- `session_start_timestamp`
- `session_end_timestamp`
- `session_duration_seconds`

### Behavioral Measures

- `event_count`

### Acquisition and Navigation Attributes

- `platform`
- `landing_page`
- `landing_page_title`
- `exit_page`
- `exit_page_title`
- `source`
- `medium`
- `campaign`

### Commercial Measures

- `transaction_count`
- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`
- `unique_items`
- `has_purchase`

## Required Tests

- `session_key` is unique
- `session_key` is not null
- `user_pseudo_id` is not null
- `ga_session_id` is not null
- `session_date` is not null
- `session_start_timestamp` is not null
- `session_end_timestamp` is not null
- `session_duration_seconds >= 0`
- `event_count > 0`
- `transaction_count >= 0`
- `has_purchase` is not null
- purchase flag is consistent with transaction count
- `session_date` has a valid relationship to `dim_date.date_day`

## Reconciliation Requirements

The model must preserve the validated Phase 4 session population and commercial totals.

Validated reconciliation baseline:

- sessions: 360,129
- purchasing sessions: 4,033
- purchase revenue: 307,640
- total item quantity: 19,459

No additional sessionization logic is permitted in this model.

---

# 3. `fct_transactions`

## Model Type

Fact

## Grain

One row per valid, deduplicated `transaction_id`.

## Primary Analytical Key

`transaction_id`

## Upstream Dependency

`int_ga4__transactions`

## Materialization

Table

## Required Columns

### Identifiers

- `transaction_id`
- `session_key`
- `user_pseudo_id`
- `ga_session_id`
- `ga_session_number`

### Time

- `transaction_date`
- `transaction_timestamp`
- `session_date`
- `session_start_timestamp`
- `session_end_timestamp`

### Acquisition and Navigation Attributes

- `platform`
- `landing_page`
- `landing_page_title`
- `source`
- `medium`
- `campaign`

### Commercial Measures

- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`
- `unique_items`

## Required Tests

- `transaction_id` is unique
- `transaction_id` is not null
- `session_key` is not null
- `user_pseudo_id` is not null
- `transaction_date` is not null
- `transaction_timestamp` is not null
- `purchase_revenue` is not null
- `transaction_date` has a valid relationship to `dim_date.date_day`
- `session_key` has a valid relationship to `fct_sessions.session_key`
- transaction timestamp remains within the governed session boundaries

## Reconciliation Requirements

Validated Phase 4 reconciliation baseline:

- transactions: 4,451
- purchasing users: 3,702
- purchase revenue: 307,640
- total item quantity: 19,459

No transaction deduplication logic is permitted in this model.

---

# Cross-Model Rules

## Grain Separation

Session measures and transaction measures must remain associated with their intended analytical grain.

Downstream queries must not join `fct_sessions` to `fct_transactions` and then aggregate duplicated session-level commercial measures.

---

## Date Conformance

Both fact tables use native BigQuery `DATE` fields that conform to `dim_date.date_day`.

- `fct_sessions.session_date` → `dim_date.date_day`
- `fct_transactions.transaction_date` → `dim_date.date_day`

---

## Session Conformance

`fct_transactions.session_key` must resolve to exactly one governed session in `fct_sessions`.

---

## Business Logic Ownership

Phase 5 must not recreate:

- session-key generation
- sessionization
- event sequencing
- acquisition-event selection
- transaction-ID normalization
- purchase deduplication

These rules are owned by the Phase 4 intermediate layer.

---

# Approved Implementation Order and Outcome

1. `dim_date`
2. `fct_sessions`
3. `fct_transactions`
4. warehouse schema tests
5. warehouse business-rule tests
6. cross-model reconciliation

Phase 5 was implemented and validated against these contracts. The approved model grains, upstream ownership rules, quality requirements, and cross-model reconciliation controls were preserved in the completed core warehouse layer.
