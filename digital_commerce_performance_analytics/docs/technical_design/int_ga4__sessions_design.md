# Technical Design Specification: `int_ga4__sessions`

## Document Status

* **Status:** Implemented and Validated
* **Model owner:** Analytics Engineering
* **Model layer:** Intermediate
* **Target model:** `int_ga4__sessions`
* **Primary upstream model:** `stg_ga4__events`
* **Created:** 2026-07-29
* **Last updated:** 2026-07-29

---

## 1. Objective

Document the implemented reusable session-grain intermediate model built from the GA4 event-grain staging layer.

The model consolidates event-level records into exactly one row per GA4 session while providing consistent session attributes, acquisition information, behavioral metrics, and ecommerce outcomes for downstream marts, semantic models, and BI reporting.

---

## 2. Business Context

The GA4 export stores customer behavior at event grain. Business reporting, however, commonly requires session-level metrics such as:

* total sessions;
* converting sessions;
* session conversion rate;
* session revenue;
* page views per session;
* landing-page performance;
* acquisition performance;
* customer engagement across sessions.

Centralizing all session logic in a single intermediate model ensures that downstream models, dashboards, and analyses use one consistent definition of a GA4 session instead of independently recreating aggregation logic.

---

## 3. Model Grain

One row represents one GA4 session for one anonymous user.

Approved natural key:

```text
user_pseudo_id + ga_session_id
```

Profiling confirmed that this composite key uniquely identifies every session in the approved source window.

---

## 4. Upstream Dependencies

### Primary Input

* `{{ ref('stg_ga4__events') }}`

### Excluded from the Session Model

* `stg_ga4__items`

The item-grain staging model is intentionally excluded because joining item-level records into the session aggregation would multiply event rows and distort session-level metrics.

Item-level logic is handled separately from the session-grain model to prevent item-level records from multiplying event or session populations.

---

## 5. Model Output Contract

### Session Identifiers

- `session_key`
- `user_pseudo_id`
- `ga_session_id`
- `ga_session_number`

### Session Timing

- `session_date`
- `session_start_timestamp`
- `session_end_timestamp`
- `session_duration_seconds`

### Session Context

- `platform`
- `device_category`
- `country`
- `landing_page`
- `landing_page_title`
- `landing_page_referrer`
- `exit_page`
- `exit_page_title`

### Acquisition Attributes

- `source`
- `medium`
- `campaign`
- `has_selected_acquisition`

### Behavioral Measures

- `event_count`

### Ecommerce Outcomes

- `transaction_count`
- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`
- `unique_items`
- `has_purchase`

---

## 6. Governed Business Rules

### 6.1 Session Key

Create a deterministic session key from:

```text
user_pseudo_id + ga_session_id
```

Implementation should use the project's standard surrogate-key macro rather than exposing concatenation logic to downstream models.

---

### 6.2 Session Date

Assign `session_date` from the earliest event belonging to the session.

---

### 6.3 Session Boundaries

* `session_start_timestamp` = earliest event timestamp within the session.
* `session_end_timestamp` = latest event timestamp within the session.
* `session_duration_seconds` = difference between session end and session start in seconds.

Single-event sessions have a duration of zero seconds.

---

### 6.4 Session Number

Use the non-null `ga_session_number` from the earliest event in the session.

Profiling confirmed no conflicting non-null values within a session.

---

### 6.5 Platform

Use the platform associated with the earliest event in the session.

Profiling confirmed no conflicting platform values within a session.

---

### 6.6 Landing-Page Attributes

Landing-page attributes are selected from the earliest event in the session.

The implementation preserves:

* page location;
* page title;
* page referrer.

The logic does **not** depend on the first `page_view` because profiling confirmed that page attributes already exist on the earliest event of every session.

---

### 6.7 Acquisition Attributes

Select acquisition attributes from the earliest event containing a complete acquisition record (`source`, `medium`, and `campaign`).

If no complete acquisition record exists:

* use the earliest event containing any acquisition information;
* preserve that acquisition record exactly as stored;
* never combine source, medium, and campaign from different events.

Sessions without acquisition information retain null values.

---

### 6.8 Event Measures

Behavioral metrics are calculated using conditional aggregation over `event_name`.

Each measure represents the count of matching raw events within the session.

---

### 6.9 Purchasing Session

`has_purchase` is `TRUE` when the session contains at least one retained valid transaction after purchase-event validation and deduplication.

A valid purchase requires a normalized transaction identifier that is not null, blank, `'(not set)'`, or `'not set'`.

The session-level flag therefore represents the presence of at least one governed valid transaction rather than the presence of an unvalidated raw purchase event.

---

### 6.10 Transactions

`transaction_count` equals the count of distinct valid transaction identifiers after purchase-event deduplication.

The placeholder value `(not set)` is never treated as a valid transaction identifier.

---

### 6.11 Purchase Deduplication

Duplicate purchase events belonging to the same:

* user;
* session;
* transaction;

are deduplicated by retaining the earliest purchase event.

Profiling confirmed that all duplicate purchase events within the same user and session contain identical values for:

* purchase revenue;
* tax value;
* purchased item quantity;
* purchased unique items.

Therefore retaining the earliest purchase event does not lose ecommerce information.

Cross-user or cross-session transaction ID collisions are treated as source data-quality exceptions and are **not** globally deduplicated.

---

### 6.12 Ecommerce Metrics

Session ecommerce metrics are calculated only from retained valid purchase events after transaction validation and deduplication.

The implemented model publishes:

- `transaction_count`
- `purchase_revenue`
- `refund_value`
- `shipping_value`
- `tax_value`
- `total_item_quantity`
- `unique_items`
- `has_purchase`

Commercial values are aggregated at session grain. Null commercial values from retained purchase records are normalized to zero during session aggregation.

Although source profiling identified no populated refund or shipping values in the approved observation window, these governed fields are retained in the implemented session contract to preserve a stable downstream commercial schema.

---

## 7. Known Edge Cases

The implementation and validation process must explicitly handle the following scenarios:

* sessions containing only one event;
* sessions spanning multiple calendar dates;
* repeated `ga_session_id` values across different users;
* null acquisition fields;
* acquisition values appearing after the first session event;
* sessions without acquisition information;
* sessions with no `page_view` event;
* duplicate purchase events within the same session;
* repeated transaction identifiers across different users or sessions;
* `(not set)` transaction identifiers;
* purchase events with null revenue;
* events sharing the same timestamp.

All implemented business rules are based on source profiling rather than assumptions.

---

## 8. Testing Strategy

### Generic Tests

The model is governed by generic tests including:

* `not_null` on `session_key`;
* `unique` on `session_key`;
* `not_null` on `user_pseudo_id`;
* `not_null` on `ga_session_id`;
* `not_null` on `session_date`;
* `not_null` on `session_start_timestamp`;
* `not_null` on `session_end_timestamp`;
*  accepted values for `has_purchase`.

### Singular Tests

The model is governed by reconciliation and business-rule validation tests including:

* session end is not earlier than session start;
* session duration is non-negative;
* session event count is positive;
* converting sessions contain at least one valid purchase event;
* non-converting sessions contain no valid purchase events;
* session event counts reconcile to the staging layer;
* session ecommerce metrics reconcile to the approved deduplicated purchase population;
* the output session population reconciles to distinct validated session keys from staging.

---

## 9. Performance Considerations

* Read from `stg_ga4__events` rather than rescanning the raw GA4 export.
* Aggregate event records only once.
* Avoid joining the item-grain staging model.
* Publish only reusable session-level logic.
* Select only columns required by the model contract.
* The model is materialized as a BigQuery table to avoid repeated session-level aggregation by downstream consumers.
* The table is partitioned by `session_date`; additional clustering is only justified where observed downstream query patterns provide a measurable benefit.

---

## 10. Acceptance Criteria

The implemented model is required to satisfy the following acceptance criteria:

1. The model returns exactly one row per validated session key.
2. Session grain is documented and enforced through tests.
3. Session timestamps reconcile to the staging layer.
4. Session event counts reconcile to the staging layer.
5. Transaction logic excludes invalid placeholder identifiers.
6. Purchase deduplication follows the approved business rules.
7. Session ecommerce metrics reconcile to the approved deduplicated purchase population.
8. Landing-page and acquisition selection are deterministic.
9. Edge-case handling matches documented profiling evidence.
10. The model builds successfully in the development environment.
11. All model tests pass without warnings or errors.
12. Documentation completely describes every published column.
13. Implementation is submitted through a focused pull request.

---

## 11. Final Implementation Decisions

### Materialization

`int_ga4__sessions` is materialized as a BigQuery table.

The session model aggregates approximately 4.30 million staged events into approximately 360 thousand session records. Materializing the result as a table prevents repeated session-level aggregation by downstream models and provides a stable reusable analytical entity.

The implemented model is clustered by:

- `user_pseudo_id`
- `source`
- `medium`

No table partitioning is configured in the current model implementation.

### Surrogate-Key Implementation

The project uses a reusable internal dbt macro to generate deterministic surrogate keys.

The macro is maintained within the project `macros` directory rather than introducing `dbt_utils` solely for surrogate-key generation.

This keeps the project self-contained while providing consistent key-generation logic for session, transaction, and downstream warehouse entities.

---

## 12. Implementation Decision Log

| Decision | Status | Evidence |
| --- | --- | --- |
| Session natural key | **Approved** | Use `user_pseudo_id + ga_session_id`. Profiling identified 360,129 distinct composite session keys. The standalone `ga_session_id` was not unique: 9,906 session IDs were shared across users, with a maximum of 17 users sharing one session ID. |
| Session-date rule | **Approved** | Set `session_date` from the earliest event in the session. Profiling identified 845 sessions spanning multiple calendar dates, so `event_date` must not be included in the session key. |
| Session-number rule | **Approved** | Use the non-null `ga_session_number` associated with the earliest event in the session. Profiling found no conflicting non-null session-number values. |
| Platform rule | **Approved** | Use the platform associated with the earliest event in the session. Profiling found no conflicting platform values. |
| Landing-page rule | **Approved** | Select page attributes from the earliest event in the session. Profiling showed that all 360,129 sessions had `page_location` available on their first event, while only 66,506 sessions began with a `page_view` event. The implementation must therefore not depend on the first `page_view`. |
| Acquisition rule | **Approved** | Select the earliest event containing a complete `source`, `medium`, and `campaign` record. If no complete record exists, retain the earliest event containing any acquisition values as one intact record without combining fields from different events. Sessions with no acquisition data retain null values. Profiling identified 261,715 sessions whose first acquisition record was complete, 3,079 sessions whose initial acquisition record was incomplete but had a later complete record, 782 sessions with acquisition data but no complete record, and 94,553 sessions without any acquisition data. |
| Valid purchase definition | **Approved** | A valid purchase requires `event_name = 'purchase'` and a `transaction_id` that is not null, blank, or equal to `(not set)`. Profiling identified 5,692 purchase events and 4,451 valid transaction IDs after excluding invalid identifiers. |
| Purchase deduplication rule | **Approved** | For repeated purchase events belonging to the same transaction, user, and session, retain the earliest purchase event. Profiling identified 311 duplicated transaction IDs within the same user and session. All duplicated purchase events contained identical values for `purchase_revenue`, `tax_value`, `total_item_quantity`, and `unique_items`. |
| Cross-user transaction exceptions | **Approved exception handling** | Fifteen transaction IDs were shared across users or sessions and contained conflicting revenue values. These are treated as source data-quality exceptions and are not globally deduplicated using `transaction_id` alone. |
| Purchase revenue rule | **Approved** | Use ecommerce values from the retained valid purchase event after within-session purchase deduplication. Duplicate purchase events are never summed. |
| Ecommerce aggregation rule | **Approved** | Session ecommerce metrics are calculated only from valid deduplicated purchase events. |
| Refund and shipping metrics | **Implemented** | Profiling identified zero refund events, zero populated `refund_value`, and zero populated `shipping_value` in the approved observation window. The implemented session model nevertheless retains `refund_value` and `shipping_value` as governed commercial fields to preserve a stable downstream schema. |
| Materialization | **Implemented** | Materialize `int_ga4__sessions` as a BigQuery table clustered by `user_pseudo_id`, `source`, and `medium`. The current implementation does not configure table partitioning. This avoids repeated aggregation of approximately 4.30 million staged events by downstream consumers while supporting common analytical access patterns. |
| Surrogate-key implementation | **Approved** | Use a reusable internal dbt macro maintained in the project `macros` directory. Do not introduce `dbt_utils` solely for surrogate-key generation. |