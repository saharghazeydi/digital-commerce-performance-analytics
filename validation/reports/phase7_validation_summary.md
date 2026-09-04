# Phase 7 Validation Summary — Executive KPI Layer

## Validation Objective

Validate that the Phase 7 Executive KPI Layer provides governed, leadership-ready KPI outputs on top of the approved Phase 6 business marts without introducing grain drift, KPI redefinition, incompatible time semantics, attribution mixing, or downstream calculation ambiguity.

Phase 7 validation covers:

- executive KPI base calculations
- rolling and Week-over-Week trend calculations
- channel-driver calculations
- semantic compatibility across executive outputs
- upstream reconciliation to governed business marts
- model grain and relationship controls
- final dependency-aware dbt validation

---

## Validated Models

### `executive_kpi_daily`

**Grain:** one row per governed calendar date.

Provides the governed executive headline KPI base while preserving the distinct semantic families established upstream.

Validated headline metrics include:

- session count
- purchasing session count
- transaction count
- purchase revenue
- conversion rate
- average order value
- revenue per session

Supporting additive components include:

- session-attributed transaction count
- session-attributed purchase revenue

### `executive_kpi_trends_daily`

**Grain:** one row per governed calendar date.

Extends the executive KPI base with governed short-term trend calculations, including:

- 7-day rolling purchase revenue
- 7-day rolling session count
- 7-day rolling purchasing-session count
- 7-day rolling conversion rate
- previous 7-day rolling revenue
- previous 7-day rolling conversion rate
- Week-over-Week revenue absolute change
- Week-over-Week revenue percentage change
- Week-over-Week conversion absolute change
- Week-over-Week conversion percentage change

### `executive_channel_drivers_daily`

**Grain:** `session_date × channel_key`.

Provides governed channel-level performance drivers, including:

- session count
- purchasing session count
- session-attributed transaction count
- session-attributed purchase revenue
- channel conversion rate
- session contribution
- purchasing-session contribution
- transaction contribution
- revenue contribution

---

## Semantic Validation

Phase 7 preserves the KPI semantic contracts established in Phase 6.

### Session-Date Metrics

The following metrics retain session-date semantics:

- session count
- purchasing session count
- conversion rate

Conversion rate is calculated as:

```text
purchasing_session_count / session_count
```

Period-level conversion must be recalculated from compatible additive components rather than averaged from daily conversion rates.

### Transaction-Date Metrics

The following headline metrics retain transaction-date semantics:

- transaction count
- purchase revenue
- average order value

Average order value is calculated as:

```text
purchase_revenue / transaction_count
```

### Session-Cohort Metrics

Revenue per session retains session-cohort semantics:

```text
session_attributed_purchase_revenue / session_count
```

Session-attributed commercial activity remains associated with the originating governed session.

### Channel-Driver Semantics

Channel-driver transaction and revenue metrics retain the session-attributed semantics inherited from `mart_channel_daily`.

The channel-driver layer does not use transaction-date executive revenue or transaction counts as denominators for session-attributed channel contributions.

This prevents semantic mixing between:

- transaction-date commercial activity
- session-attributed commercial activity

---

## Base KPI Reconciliation

`executive_kpi_daily` was reconciled against `mart_ecommerce_daily`.

Validated totals:

| Metric | Validated Value |
|---|---:|
| Governed dates | 92 |
| Sessions | 360,129 |
| Purchasing sessions | 4,033 |
| Transaction-date transactions | 4,451 |
| Transaction-date purchase revenue | 307,640 |
| Session-attributed transactions | 4,451 |
| Session-attributed purchase revenue | 307,640 |

The executive base reconciles day by day to the governed ecommerce mart for compatible measures.

The following automated reconciliation control passed:

`assert_executive_kpi_daily_reconciles_ecommerce`

---

## Trend Validation

The trend layer was validated independently against the executive KPI base.

### 7-Day Revenue

Rolling revenue uses the current governed date plus the previous six governed calendar dates.

Conceptually:

```text
SUM(purchase_revenue)
over current date and previous 6 dates
```

### 7-Day Conversion

Rolling conversion is calculated from rolling additive components:

```text
SUM(purchasing_session_count)
/
SUM(session_count)
```

Daily conversion percentages are not averaged.

### Week-over-Week Revenue

Week-over-Week revenue compares the current rolling seven-day revenue with the rolling seven-day revenue ending seven calendar dates earlier.

Both absolute and percentage changes are exposed.

### Week-over-Week Conversion

Week-over-Week conversion uses the equivalent governed comparison between rolling conversion windows separated by seven calendar dates.

### Early-History Behavior

Early rolling windows use the governed history available at that point in the dataset.

Prior-period and percentage-change values remain null where the required prior observation or valid denominator is unavailable.

The following trend controls passed:

- `assert_executive_kpi_trends_daily_reconciles`
- `assert_executive_kpi_trends_daily_valid_history_semantics`

---

## Channel Driver Reconciliation

`executive_channel_drivers_daily` was reconciled against `mart_channel_daily`.

Validated results:

| Metric | Validated Value |
|---|---:|
| Driver rows | 668 |
| Distinct `session_date × channel_key` combinations | 668 |
| Sessions | 360,129 |
| Purchasing sessions | 4,033 |
| Session-attributed transactions | 4,451 |
| Session-attributed purchase revenue | 307,640 |

The validated grain contains no duplicate `session_date × channel_key` combinations.

Daily contribution metrics reconcile to the compatible governed channel population and sum to one on eligible dates with non-zero denominators.

The following controls passed:

- `assert_executive_channel_drivers_daily_contributions_sum_to_one`
- `assert_executive_channel_drivers_daily_unique_grain`
- `assert_executive_channel_drivers_daily_reconciles_channel_mart`

---

## End-to-End Executive Reconciliation

An independent end-to-end reconciliation control validates compatibility across the executive base, trend, and driver branches.

The control validates compatible measures including:

- session count
- purchasing session count
- session-attributed transaction count
- session-attributed purchase revenue

The trend branch additionally reconciles transaction-date transaction count and purchase revenue to the executive base.

The driver branch is intentionally not compared to transaction-date executive commercial measures because its transaction and revenue measures are session-attributed.

The following end-to-end control passed:

`assert_executive_layer_end_to_end_reconciles`

No incompatible semantic populations are intentionally compared by this control.

---

## Final Dependency-Aware dbt Quality Gate

Final Phase 7 validation was executed using:

```powershell
dbt build --select +path:models/marts/executive
```

Final execution result:

```text
11 table models
2 view models
242 data tests

PASS=255
WARN=0
ERROR=0
SKIP=0
TOTAL=255
```

The dependency-aware build completed successfully.

All 255 selected dbt nodes passed with:

- zero warnings
- zero errors
- zero skipped nodes

This quality gate validates the Executive KPI Layer together with the selected upstream dependency chain and associated tests.

---

## Governed Aggregation Rules

The following aggregation controls are accepted for downstream consumption:

1. Additive measures may be summed across compatible reporting periods.

2. Conversion rate must be recalculated from:

   ```text
   SUM(purchasing_session_count) / SUM(session_count)
   ```

3. Average order value must be recalculated from:

   ```text
   SUM(purchase_revenue) / SUM(transaction_count)
   ```

4. Revenue per session must be recalculated from:

   ```text
   SUM(session_attributed_purchase_revenue) / SUM(session_count)
   ```

5. Daily contribution percentages must not be summed or averaged to create multi-day contribution metrics.

6. Multi-day channel contributions must be recalculated from the corresponding compatible additive channel and total measures.

7. Transaction-date and session-attributed commercial measures must not be combined as though they represent the same date population.

8. Downstream BI may consume and reaggregate governed measures but must not reconstruct sessionization, transaction deduplication, attribution, channel classification, or governed KPI definitions.

---

## Known Limitations

- the analytical source is a static, obfuscated public GA4 ecommerce sample
- available history covers approximately three months
- authenticated `user_id` is unavailable
- pseudo-user analysis must not be interpreted as authenticated customer analysis
- net revenue is not governed by the current executive layer
- ROAS and customer acquisition cost are outside the governed scope
- profit and margin metrics are outside the governed scope
- customer lifetime value and authenticated retention metrics are outside the governed scope
- unsupported multi-touch attribution is outside the governed scope
- early rolling windows contain fewer than seven observed dates when complete prior history is unavailable
- transaction-date and session-attributed commercial measures remain distinct even where their full-period totals happen to reconcile
- automated CI validation has not yet been introduced

---

## Validation Decision

**Phase 7 — Executive KPI Layer passes technical validation.**

The executive base, trend, and channel-driver outputs preserve the governed grains and KPI semantic families established upstream.

Base KPI calculations reconcile to the governed ecommerce mart.

Trend calculations use compatible additive components and controlled calendar-window logic.

Channel contribution calculations preserve session-attributed commercial semantics and reconcile to the governed channel mart.

Independent end-to-end reconciliation confirms compatibility across the Executive KPI Layer without introducing inappropriate comparisons between transaction-date and session-attributed populations.

The final dependency-aware dbt build passed all **255 of 255 selected nodes**, with zero warnings, errors, or skipped nodes.

No identified grain, semantic-governance, attribution, trend-calculation, reconciliation, or data-quality issue blocks progression to Phase 8 — BI Serving Layer.