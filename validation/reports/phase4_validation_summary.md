# Phase 4 Validation Summary

## Scope

Phase 4 validates the GA4 intermediate modeling layer used by the Digital
Commerce Performance Analytics project.

The validated models are:

- `int_ga4__session_events`
- `int_ga4__sessions`
- `int_ga4__transactions`

Validation covers session grain, transaction grain, referential integrity,
purchase metrics, user/session relationships, and reconciliation across models.

---

## Session Model

Model:

`int_ga4__sessions`

Expected grain:

One row per `session_key`.

### Core results

- Total sessions: **360,129**
- Distinct session keys: **360,129**
- Duplicate session keys: **0**
- Null session keys: **0**
- Null user identifiers: **0**
- Negative session durations: **0**
- Purchasing sessions: **4,033**

Session-duration analysis identified a small number of extreme sessions.
Three sessions exceeded 24 hours.

These rows were retained because they represent source measurement/session
behavior rather than transformation failures. They are documented as known
GA4 sessionization outliers.

---

## Transaction Model

Model:

`int_ga4__transactions`

Expected grain:

One row per valid, deduplicated `transaction_id`.

### Core results

- Transaction rows: **4,451**
- Distinct transaction IDs: **4,451**
- Duplicate transaction IDs: **0**
- Null transaction IDs: **0**
- Transactions without matching sessions: **0**
- Transaction/session user mismatches: **0**
- Transactions outside session boundaries: **0**
- Total purchase revenue: **307,640**
- Invalid negative purchase values: **0**
- Invalid item quantities: **0**

---

## Cross-Model Reconciliation

Session, transaction and event-level models were reconciled before downstream
mart development.

### Results

| Validation | Result |
|---|---:|
| Source valid purchase events | 4,451 |
| Transaction model rows | 4,451 |
| Purchasing sessions | 4,033 |
| Session-model transaction count | 4,451 |
| Transaction-model transaction count | 4,451 |
| Source purchase revenue | 307,640 |
| Transaction-model purchase revenue | 307,640 |
| Session-model purchase revenue | 307,640 |
| Source item quantity | 19,459 |
| Transaction-model item quantity | 19,459 |
| Per-session revenue mismatches | 0 |
| Per-session item-quantity mismatches | 0 |
| Transaction-model purchasing users | 3,702 |
| Session-model purchasing users | 3,702 |

---

## Validation Conclusion

The intermediate GA4 layer satisfies the required session and transaction
grains.

No referential-integrity, transaction-count, purchase-revenue, item-quantity,
or purchasing-user reconciliation failures were identified.

The intermediate models are therefore suitable for downstream analytical mart
development.

A small number of extreme session-duration records remain documented as source
measurement outliers rather than transformation errors.

## Final Acceptance Reconciliation

A final end-to-end reconciliation was completed after the dbt business-rule tests were added.

The intermediate models reconcile across their defined grains:

| Validation Check | Result |
|---|---|
| Event session keys = session rows | PASS |
| Session key uniqueness | PASS |
| Retained purchase events = transaction rows | PASS |
| Retained transaction IDs = transaction rows | PASS |
| Session transaction count = transaction rows | PASS |
| Transaction ID uniqueness | PASS |
| Purchasing sessions = transaction sessions | PASS |
| Session purchase revenue = transaction purchase revenue | PASS |

### Final Reconciled Metrics

| Metric | Value |
|---|---:|
| Event rows | 4,295,584 |
| Sessions | 360,129 |
| Purchasing sessions | 4,033 |
| Transactions | 4,451 |
| Purchase revenue | 307,640.0 |

The final dbt build and test suite completed with no warnings or errors.

**Phase 4 validation status: PASS**