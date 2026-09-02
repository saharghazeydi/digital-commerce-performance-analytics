# P6F Validation Summary

## Project

Digital Commerce Performance Analytics

## Phase

Phase 6F — Device / Geography Performance Mart

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

```text
purchasing_session_count / session_count
```

`revenue_per_session` is governed as:

```text
purchase_revenue / session_count
```

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