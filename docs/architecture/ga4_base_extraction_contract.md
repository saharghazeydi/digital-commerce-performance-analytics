# GA4 Base Extraction Contract

## Purpose

This document defines the approved field-level extraction contract for the GA4 staging layer.

It translates the validated source structure and the approved staging architecture into explicit extraction rules before dbt transformation models are implemented.

The contract is source-aligned and does not introduce downstream business logic, governed order construction, session aggregation, KPI calculations, or final transaction deduplication.

---

## Source

The governed dbt source is:

`source('ga4', 'events')`

The physical source resolves to the wildcard relation:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

All staging models must restrict wildcard scans using `_TABLE_SUFFIX` and the approved bounded source window.

Approved source window:

- Start: `2020-11-01`
- End: `2021-01-31`
- Daily shards: 92

---

## Event Staging Model

### Model

`stg_ga4__events`

### Grain

One row per raw GA4 event.

The staging model must preserve raw event multiplicity. Repeated purchase events must not be deduplicated at this layer.

---

## Core Event Fields

| Staging Field | Raw Source | Raw Type | Extraction Rule |
|---|---|---:|---|
| `event_date` | `event_date` | STRING | Parse source `YYYYMMDD` representation to DATE |
| `event_timestamp` | `event_timestamp` | INT64 | Convert GA4 microsecond timestamp to TIMESTAMP |
| `event_name` | `event_name` | STRING | Direct extraction |
| `user_pseudo_id` | `user_pseudo_id` | STRING | Direct extraction |
| `platform` | `platform` | STRING | Direct extraction |

---

## Session Parameters

The following scalar parameters are extracted deterministically from `event_params`.

| Staging Field | GA4 Parameter | Value Slot | Target Type |
|---|---|---|---|
| `ga_session_id` | `ga_session_id` | `value.int_value` | INT64 |
| `ga_session_number` | `ga_session_number` | `value.int_value` | INT64 |

`ga_session_id` must not be treated as a globally unique session identifier.

The approved downstream analytical session identity remains the composite of:

- `user_pseudo_id`
- `ga_session_id`

Session aggregation and governed session construction do not belong in staging.

---

## Page Context Parameters

The following scalar page-context parameters may be promoted from `event_params` into the event staging model.

| Staging Field | GA4 Parameter | Value Slot | Target Type |
|---|---|---|---|
| `page_location` | `page_location` | `value.string_value` | STRING |
| `page_title` | `page_title` | `value.string_value` | STRING |
| `page_referrer` | `page_referrer` | `value.string_value` | STRING |

These parameters are not expected to be populated for every event and must not receive unconditional `not_null` tests.

---

## Event-Level Acquisition Parameters

The following observed scalar parameters may be extracted where required for downstream acquisition analysis.

| Staging Field | GA4 Parameter | Value Slot | Target Type |
|---|---|---|---|
| `source` | `source` | `value.string_value` | STRING |
| `medium` | `medium` | `value.string_value` | STRING |
| `campaign` | `campaign` | `value.string_value` | STRING |

These fields represent event-parameter values and must not be treated as interchangeable with the top-level `traffic_source` record.

Null values are valid where the parameter is not present on an event.

---

## Ecommerce Fields

The following ecommerce fields are available directly from the nested `ecommerce` record and do not require `event_params` extraction.

| Staging Field | Raw Source | Raw Type |
|---|---|---:|
| `transaction_id` | `ecommerce.transaction_id` | STRING |
| `purchase_revenue` | `ecommerce.purchase_revenue` | FLOAT64 |
| `refund_value` | `ecommerce.refund_value` | FLOAT64 |
| `shipping_value` | `ecommerce.shipping_value` | FLOAT64 |
| `tax_value` | `ecommerce.tax_value` | FLOAT64 |
| `total_item_quantity` | `ecommerce.total_item_quantity` | INT64 |
| `unique_items` | `ecommerce.unique_items` | INT64 |

Commercial fields must remain source-aligned at staging grain.

Raw purchase-event revenue must not be interpreted as governed order revenue before downstream transaction deduplication.

---

## Transaction Identity

`transaction_id` is sourced from:

`ecommerce.transaction_id`

The approved downstream transaction identity for valid transaction identifiers is the composite of:

- `user_pseudo_id`
- `transaction_id`

The staging layer must preserve repeated transaction-bearing events.

It must not perform final transaction deduplication.

Null or invalid transaction identifiers must remain distinguishable from valid transaction identities.

---

## Nested Field Extraction Rule

Frequently required scalar values from `event_params` may be promoted into `stg_ga4__events` through deterministic conditional extraction.

The extraction must:

- preserve one row per raw event;
- avoid exploding the event grain;
- return at most one scalar value per parameter per event;
- use the correct GA4 value slot for the observed parameter type.

The `event_params` array must not be unnested into the final event result in a way that multiplies event rows.

---

## Items

The `items` repeated structure must not be unnested inside `stg_ga4__events`.

Item extraction belongs to:

`stg_ga4__items`

with a target grain of:

one row per item occurrence within a raw GA4 event.

The item staging model must preserve sufficient event and transaction context for downstream reconciliation.

---

## Explicitly Out of Scope

The base extraction layer must not:

- construct the final session entity;
- aggregate events to session grain;
- define governed orders;
- deduplicate purchase events;
- calculate final order revenue;
- calculate conversion rate or other business KPIs;
- implement attribution logic;
- implement dashboard-specific transformations;
- unnest multiple repeated arrays into the same grain.

---

## Profiling Evidence

Field-level profiling confirmed:

- `ga_session_id` is stored in `event_params.value.int_value`;
- `ga_session_number` is stored in `event_params.value.int_value`;
- page context parameters are stored as strings;
- observed `source`, `medium`, and `campaign` event parameters are stored as strings;
- `transaction_id` is available through `ecommerce.transaction_id`;
- ecommerce commercial attributes are available directly from the nested ecommerce record;
- top-level event identifiers and timestamps are available at raw event grain.

Profiling was performed using bounded GA4 daily shards before transformation implementation.

---

## Acceptance Criteria

This extraction contract is accepted when:

- required raw fields have verified source paths and types;
- scalar `event_params` extraction rules are explicit;
- event grain remains one row per raw event;
- item extraction remains isolated to its own model;
- transaction deduplication remains downstream;
- session identity responsibilities remain downstream;
- wildcard source-window controls remain mandatory;
- no business KPI logic is introduced into staging.

Once accepted, implementation may proceed to the dbt staging models.

## Validation Results

The `stg_ga4__events` model was validated against the bounded GA4 source extraction window after its initial implementation.

### Row Count Reconciliation

The staging model preserves the raw event grain without introducing row multiplication or row loss.

| Validation Metric | Result |
|---|---:|
| Raw source event count | 4,295,584 |
| Staging model event count | 4,295,584 |
| Row-count difference | 0 |

This confirms that one raw GA4 event maps to one row in `stg_ga4__events`.

### Date Coverage

| Validation Metric | Result |
|---|---|
| Minimum event date | 2020-11-01 |
| Maximum event date | 2021-01-31 |
| Distinct event dates | 92 |

The staging model therefore covers the complete approved extraction window.

### Required Identifier Completeness

The following required fields were populated for all 4,295,584 staged events:

- `user_pseudo_id`
- `ga_session_id`
- `ga_session_number`
- `page_location`

`page_title` was populated for 4,274,636 events. Missing values are retained because the field is not expected to exist for every GA4 event type.

### Ecommerce Field Profiling

| Field | Non-null Row Count |
|---|---:|
| `transaction_id` | Event-dependent |
| `purchase_revenue` | 5,242 |
| `refund_value` | 0 |
| `shipping_value` | 0 |
| `tax_value` | 5,242 |
| `total_item_quantity` | 93,999 |
| `unique_items` | 512,346 |

Null ecommerce values are retained because these fields are only expected to be populated for relevant event types.

### Transaction Identifier Finding

The raw GA4 export frequently uses the literal placeholder `(not set)` for `ecommerce.transaction_id` on non-purchase events.

Examples observed during profiling include:

- `view_item`
- `view_promotion`
- `add_to_cart`
- `begin_checkout`
- `add_shipping_info`
- `add_payment_info`

For `view_item`, 381,349 rows contained the literal value `(not set)` as the transaction identifier.

Purchase-event profiling produced the following results:

| Purchase Metric | Result |
|---|---:|
| Purchase events | 5,692 |
| Purchase events with a non-null transaction ID | 5,669 |
| Purchase events with revenue | 5,242 |
| Purchase events with positive revenue | 5,242 |
| Minimum populated purchase revenue | 1 |
| Maximum populated purchase revenue | 1,530 |

### Staging Treatment Decision

`stg_ga4__events` preserves source-provided values, including the literal placeholder `(not set)`.

The staging layer does not convert `(not set)` to `NULL`, because its responsibility is typed extraction and source fidelity rather than business-level standardization.

Downstream intermediate or mart models must explicitly exclude or normalize `(not set)` before using `transaction_id` for:

- transaction identification;
- transaction deduplication;
- order-level aggregation;
- purchase reconciliation;
- transaction-count KPIs.

A populated `transaction_id` alone must therefore not be interpreted as evidence that an event represents a valid transaction.
