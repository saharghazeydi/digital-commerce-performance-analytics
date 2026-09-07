# Power BI Semantic Model Handoff

## Document Purpose

This document records the final Power BI semantic model implemented for the Digital Commerce Performance Analytics project.

It defines the semantic-model structure, relationship design, governed measure layer, filtering behavior, usability conventions, validation outcomes, and known semantic boundaries that report development must preserve.

This document represents the handoff from:

**Phase 9 — Power BI Semantic Model**

to downstream Power BI report development.

The upstream BI-serving contract remains documented separately in:

`power_bi/documentation/bi_serving_handoff.md`

---

## 1. Semantic Model Scope

The semantic model consumes the governed BigQuery BI-serving datasets produced upstream by dbt.

Loaded datasets:

- `bi_executive_daily`
- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_user_behavior`
- `bi_segment_daily`
- `dim_date`
- `dim_channel`

Power BI also contains a dedicated:

- `Measures`

table for explicit DAX measures.

The model uses **Import mode**.

Business metric definitions remain governed upstream by the dbt KPI contracts and serving layer. Power BI does not redefine core business semantics.

---

## 2. Model Architecture

The model follows a star-schema-oriented semantic design.

Primary dimensions:

- `dim_date`
- `dim_channel`

Fact / serving tables:

- `bi_executive_daily`
- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_segment_daily`

User-level serving table:

- `bi_user_behavior`

Measure container:

- `Measures`

There are:

- no fact-to-fact relationships
- no unnecessary bidirectional relationships
- no duplicated Power BI dimension wrappers
- no single denormalized reporting table

Filtering is designed to flow from dimensions to serving tables.

---

## 3. Relationship Design

### Date relationships

`dim_date` is the governed calendar dimension.

Active single-direction relationships are used between `dim_date` and date-grain serving tables.

#### Executive

`dim_date[date_day]`
→
`bi_executive_daily[date_day]`

Cardinality:

**1 : \***

Filter direction:

**Single**

---

#### Commerce

`dim_date[date_day]`
→
`bi_commerce_daily[date_day]`

Cardinality:

**1 : \***

Filter direction:

**Single**

---

#### Channel

`dim_date[date_day]`
→
`bi_channel_daily[session_date]`

Cardinality:

**1 : \***

Filter direction:

**Single**

---

#### Segment

`dim_date[date_day]`
→
`bi_segment_daily[session_date]`

Cardinality:

**1 : \***

Filter direction:

**Single**

---

### Channel relationship

`dim_channel[channel_key]`
→
`bi_channel_daily[channel_key]`

Cardinality:

**1 : \***

Filter direction:

**Single**

`dim_channel` is the governed channel dimension for channel-based analysis.

---

## 4. Intentionally Disconnected Tables

### `bi_user_behavior`

`bi_user_behavior` is intentionally not connected to `dim_date` through a standard fact relationship.

Its grain is user-level rather than daily.

Its date fields describe user attributes such as:

- first observed session date
- last observed session date
- first observed purchase date
- last observed purchase date

These fields must not be treated as a conventional daily fact date.

Connecting this table directly to the primary date dimension would introduce ambiguous interpretation of date filtering.

---

### `Measures`

The `Measures` table is intentionally disconnected.

It exists only as a semantic organization layer for explicit DAX measures.

---

## 5. Governed Date Dimension

`dim_date` is the authoritative reporting calendar.

Key column:

`date_day`

Available reporting attributes include:

- day name
- day of month
- day of week
- weekend indicator
- month name
- month number
- quarter
- quarter name
- week of year
- year
- year-month

Configuration includes:

- `month_name` sorted by `month_number`
- `day_name` sorted by `day_of_week`

The date dimension should be used for report-level date filtering wherever the underlying serving table participates in the governed date relationship.

---

## 6. DAX Measure Layer

Business-facing calculations are exposed through explicit measures stored in the dedicated `Measures` table.

Measures are organized using display folders.

### 01 Executive KPIs

Includes governed headline metrics such as:

- Total Sessions
- Purchasing Sessions
- Total Transactions
- Purchase Revenue
- Conversion Rate
- Average Order Value
- Revenue per Session

---

### 02 Commerce

Includes commerce-focused measures such as:

- Refund Value
- Items per Transaction

and related governed commerce metrics where required.

---

### 03 Channel

Includes channel-level measures such as:

- Channel Sessions
- Channel Purchasing Sessions
- Channel Conversion Rate
- Channel Session Contribution

and other channel-attributed measures exposed by the BI-serving layer.

---

### 04 User Behavior

Includes user-level measures such as:

- Observed Users
- Purchasing Users
- Multi-Session Users
- Repeat Purchasing Date Users
- Repeat Purchasing Session Users

These metrics represent GA4 pseudo-users, not authenticated customer accounts.

---

### 05 Segment

Contains governed measures used for segment-level analysis, including session and conversion metrics derived from `bi_segment_daily`.

---

### 06 Trends

Includes point-in-time trend measures such as:

- Revenue 7D
- Conversion Rate 7D
- Revenue WoW Change
- Revenue WoW Change %
- Conversion Rate WoW Change
- Conversion Rate WoW Change %

Trend metrics are non-additive and must not be summed across dates.

---

## 7. Metric Aggregation Rules

The semantic model preserves the KPI contracts established upstream.

### Conversion Rate

Conversion Rate is calculated from compatible additive components:

**Purchasing Sessions / Sessions**

It must not be calculated as an average of daily, monthly, channel, or segment conversion percentages.

---

### Average Order Value

Average Order Value follows transaction-date semantics:

**Purchase Revenue / Transactions**

It must not be averaged from pre-calculated daily AOV values when aggregating over larger periods.

---

### Revenue per Session

Revenue per Session uses session-cohort / session-attributed commercial semantics.

It must remain separate from transaction-date purchase revenue analysis.

---

### Contribution metrics

Contribution metrics are non-additive across dates.

They must be evaluated within the appropriate filter context rather than summed across daily contribution percentages.

---

### Trend metrics

Rolling and week-over-week measures represent a metric at a specific reporting date.

They must not be summed across multiple dates.

Report visuals should interpret these measures as point-in-time or time-series values.

---

## 8. Semantic Date Boundaries

Three different commercial date concepts are intentionally preserved.

### Session-date metrics

Used for metrics such as:

- Sessions
- Purchasing Sessions
- Conversion Rate

---

### Transaction-date metrics

Used for metrics such as:

- Transactions
- Purchase Revenue
- Average Order Value

---

### Session-cohort / session-attributed metrics

Used where commercial outcomes are attributed back to the originating session context, including channel and segment driver analysis.

These three semantic concepts must not be blended merely for report convenience.

---

## 9. Channel vs Executive Filtering

The Executive and Channel reporting branches intentionally represent different analytical perspectives.

### Executive branch

Headline metrics represent the governed overall business population.

### Channel branch

Channel metrics use session-attributed commercial logic.

Therefore, filtering `dim_channel` is expected to affect channel measures but not automatically change independent executive headline metrics.

This behavior is intentional and prevents mixing channel attribution semantics with transaction-date executive KPIs.

No fact-to-fact relationship should be added to force these branches to filter each other.

---

## 10. Model Usability

The semantic model was organized for report-author usability.

Key practices include:

- explicit business measures
- dedicated measure table
- display folders by analytical domain
- technical keys hidden where appropriate
- upstream-calculated business logic reused instead of recreated
- governed dimensions used for slicing
- reporting fields kept distinct from technical model fields

Examples of hidden technical fields include surrogate or relationship keys such as:

- `channel_key`
- supporting sort-order columns

Fields should only be exposed when they have a legitimate report-author use case.

---

## 11. Validation Summary

The semantic model was validated before handoff.

### Baseline reconciliation

Validated totals include:

- Sessions: **360,129**
- Purchasing Sessions: **4,033**
- Transactions: **4,451**
- Purchase Revenue: **307,640**
- Conversion Rate: approximately **1.12%**
- Purchasing Users: **3,702**
- Repeat Purchasing Session Users: **284**

These values reconcile with the governed upstream serving layer.

---

### Date aggregation validation

Monthly session totals validated:

- 2020-11: **108,401**
- 2020-12: **133,351**
- 2021-01: **118,377**

Grand total:

**360,129**

The total Conversion Rate evaluated to approximately:

**1.12%**

This confirmed that the measure recalculates from the appropriate numerator and denominator in total context instead of averaging monthly percentages.

---

### Channel validation

Channel-level totals reconciled to the overall session population:

- Channel Sessions: **360,129**
- Channel Purchasing Sessions: **4,033**
- Channel Conversion Rate: approximately **1.12%**
- Channel Session Contribution total: **100%**

Channel slicer testing also confirmed correct filter propagation from:

`dim_channel`
→
`bi_channel_daily`

---

### Date filter propagation

Date filtering through `dim_date` correctly affected connected date-grain serving tables.

Example validation for 2020-12 included:

- Sessions: approximately **133K**
- Transactions: **2,304**
- Purchase Revenue: approximately **158.17K**
- Purchasing Sessions: **2,030**
- Conversion Rate: approximately **1.52%**
- Average Order Value: approximately **68.65**
- Items per Transaction: approximately **4.35**

Trend measures also responded to the date context.

---

### Relationship validation

The final semantic model was visually inspected and confirmed to use:

- active dimension-to-fact relationships
- one-to-many cardinality
- single-direction filtering
- no fact-to-fact relationships
- intentionally disconnected user-behavior and measure-container tables

---

## 12. Unsupported Metrics and Interpretations

The current data model does not support the following as governed business KPIs:

- Net Revenue
- ROAS
- CAC
- CPA
- Profit
- Margin
- Customer Lifetime Value
- Churn
- formal retention metrics
- multi-touch attribution

These metrics must not be inferred or introduced in Power BI without additional source data and an updated KPI contract.

---

## 13. Report Development Guardrails

Downstream report development must preserve the semantic model contract.

Report authors should:

- use explicit measures instead of implicit column aggregation
- use `dim_date` for governed date filtering
- use `dim_channel` for channel slicing
- avoid creating fact-to-fact relationships
- avoid enabling bidirectional filtering without a documented requirement
- avoid averaging governed ratio metrics
- avoid summing contribution metrics across dates
- avoid summing rolling or WoW metrics across dates
- preserve transaction-date versus session-date distinctions
- preserve session-attributed channel and segment semantics
- avoid redefining KPI logic locally in report visuals

Any required semantic change should be implemented in the appropriate upstream layer rather than patched into individual report visuals.

---

## 14. Handoff Status

The Power BI semantic model is ready for downstream report development.

Completed work includes:

- BigQuery BI-serving data connection
- Import-mode loading
- semantic relationship design
- governed date configuration
- explicit DAX measure layer
- field organization and usability cleanup
- filter-propagation validation
- total and subtotal validation
- semantic boundary validation
- final model inspection

**Phase 9 — Power BI Semantic Model: READY FOR CLOSEOUT**

Next downstream activity:

**Power BI report and dashboard development**