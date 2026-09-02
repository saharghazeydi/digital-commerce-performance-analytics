# P6G Business Mart Validation Summary

## Project
Digital Commerce Performance Analytics

## Phase
Phase 6 — Business Marts
P6G — Mart Validation

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

---

## 1. Business Mart Inventory

The business layer contains four governed marts:

| Mart | Primary Grain | Primary Consumer |
|---|---|---|
| `mart_channel_daily` | session date × channel | acquisition and channel performance |
| `mart_ecommerce_daily` | calendar date | executive ecommerce performance |
| `mart_segment_daily` | session date × device category × country | device and market segmentation |
| `mart_user_behavior` | user | observed user behavior |

The marts intentionally serve different analytical grains while sharing governed business metrics where semantically appropriate.

---

## 2. Full Business-Layer Build

Command executed:

```bash
dbt build --select path:models/marts/business
```

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

---

## 3. Cross-Mart Governed KPI Reconciliation

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

```text
assert_business_marts_cross_mart_reconciliation
```

**Status: PASS**

---

## 4. Observed Date Coverage Validation

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

```text
assert_business_marts_consistent_date_coverage
```

**Status: PASS**

---

## 5. Daily KPI Reconciliation

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

```text
assert_business_marts_daily_reconciliation
```

**Status: PASS**

This confirms that governed session-attributed KPIs reconcile not only at full-period totals but also on every observed session date.

---

## 6. Attribution and Semantic Controls

Cross-mart validation preserves the KPI contracts established during mart design.

Specifically:

- session metrics are governed by session attribution
- session-attributed commercial measures remain tied to the originating session
- transaction-date measures are not substituted into session-date comparisons
- `mart_ecommerce_daily` session-attributed fields are used when reconciling against session-based marts
- user-level aggregation in `mart_user_behavior` reconciles back to the same governed session and commercial totals
- segmentation does not introduce row multiplication or metric inflation

This prevents apparently matching metric names from being compared when their underlying attribution semantics differ.

---

## 7. Regression Coverage Added in P6G

Three business-layer regression tests were added:

1. `assert_business_marts_cross_mart_reconciliation`
2. `assert_business_marts_consistent_date_coverage`
3. `assert_business_marts_daily_reconciliation`

Together they detect three distinct classes of failure:

- full-period KPI drift between marts
- missing or inconsistent observed session dates
- date-level KPI drift that could remain hidden in matching grand totals

These tests complement, rather than duplicate, the grain, metric, semantic, and reconciliation tests already implemented for each individual mart.

---

## 8. P6G Acceptance

P6G is accepted when:

- all business marts build successfully together
- all existing mart-level tests pass
- governed KPI totals reconcile across marts
- observed date coverage is consistent across session-date marts
- daily session-attributed KPIs reconcile without mismatches
- no attribution-contract violations are introduced
- automated regression tests protect the validated cross-mart behavior

All acceptance criteria were satisfied.

## Final Status

**P6G — Mart Validation: PASS**