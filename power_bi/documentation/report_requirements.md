# Power BI Report Requirements

## 1. Purpose

This document defines the business, analytical, and reporting requirements for Phase 10 — Power BI Report.

The report will provide a decision-oriented analytical interface over the governed Power BI semantic model completed in Phase 9.

The report layer is responsible for presenting and contextualizing governed metrics. It must not redefine upstream KPI logic, alter established analytical grains, or introduce relationships or calculations that conflict with the semantic-model contracts.

The intended outcome is an executive-ready Power BI report that allows users to understand:

1. What happened?
2. How is performance changing?
3. Which acquisition channels are contributing to performance?
4. How is ecommerce performance developing?
5. How do observed users and business segments differ?
6. Where should further investigation be focused?

---

## 2. Primary Report Audience

### Primary Audience

The primary audience is business and commercial leadership responsible for monitoring digital-commerce performance and identifying areas requiring attention or further investigation.

The report should support users who need business insight without requiring knowledge of the underlying dbt models, BigQuery schemas, or Power BI semantic-model implementation.

### Secondary Audience

Secondary users include:

- commercial analysts
- marketing and acquisition stakeholders
- ecommerce stakeholders
- analytics and BI practitioners

These users may require more detailed investigation of acquisition, commerce, user-behaviour, and segment performance.

---

## 3. Decision Framework

The report must support the following decision areas.

### 3.1 Overall Business Performance

Users must be able to determine:

- whether sessions, purchasing activity, transactions, and purchase revenue are increasing or decreasing
- whether conversion performance is improving or deteriorating
- whether changes in revenue are accompanied by changes in transaction volume or order value
- whether recent performance differs materially from the preceding comparison period
- which areas require deeper investigation

### 3.2 Acquisition and Channel Performance

Users must be able to determine:

- which channels generate the largest share of sessions
- which channels generate purchasing sessions
- how conversion rates differ by channel
- which channels contribute most to session-attributed purchase revenue
- which channels generate stronger or weaker revenue per session
- whether high-traffic channels also generate proportionate commercial outcomes
- which channels appear comparatively strong or weak and require further investigation

Channel analysis must use the governed session-attributed commercial metrics supplied by the channel semantic branch.

### 3.3 Commerce Performance

Users must be able to determine:

- how transaction-date purchase revenue changes over time
- how transaction volume changes over time
- how Average Order Value changes
- how item quantity and Items per Transaction behave
- whether changes in revenue are primarily associated with transaction volume, order value, or both
- whether refund values are material within the available source data

Commerce reporting must preserve transaction-date semantics.

### 3.4 User Behaviour

Users must be able to understand the observed user population, including:

- total observed users
- purchasing users
- multi-session users
- repeat purchasing users where governed measures are available
- differences between one-time and repeated observed behaviour

User-behaviour reporting must remain consistent with the user-grain model and must not imply authenticated customer identity.

### 3.5 Segment Performance

Users must be able to investigate performance across governed segmentation dimensions, including:

- device category
- country

Segment analysis should support comparison of:

-- sessions
- conversion rate
- session-attributed purchase revenue
- revenue per session

The report should help identify segments with materially different traffic, conversion, or commercial performance.

---

## 4. Core Business Questions

The report should answer the following questions without requiring users to inspect raw tables.

### Executive

- What is the current level of sessions, purchasing sessions, transactions, and purchase revenue?
- What is the overall conversion rate?
- What is the Average Order Value?
- What is Revenue per Session?
- How are revenue and conversion trending?
- How does recent performance compare with the previous seven-day period?
- Which analytical area appears to explain or contextualize observed performance changes?

### Acquisition

- Which channels drive the most traffic?
- Which channels drive the most purchasing sessions?
- Which channels have the strongest and weakest conversion rates?
- How is traffic volume distributed across channels?
- Which channels contribute most to session-attributed purchase revenue?- Are high-volume channels
- Which channels generate the strongest revenue per session? producing proportionate commercial outcomes?

### Commerce

- How much purchase revenue was generated?
- How many transactions occurred?
- What is the Average Order Value?
- How many items are purchased per transaction?
- How are revenue, transaction volume, and AOV changing over time?
- Are observed revenue movements primarily volume-driven or order-value-driven?

### User Behaviour

- How many pseudo-users were observed?
- How many observed users purchased?
- How many users had multiple sessions?
- How many users purchased across multiple sessions?

### Segmentation

- Which devices account for the most sessions and purchasing activity?
- How does conversion vary by device?
- Which countries account for the largest traffic and commercial contribution?
- Which segments have high traffic but comparatively weak conversion?
- Which segments show comparatively strong commercial efficiency?

---

## 5. KPI Hierarchy

### Tier 1 — Executive KPIs

These metrics receive the highest visual priority:

- Total Sessions
- Purchasing Sessions
- Total Transactions
- Purchase Revenue
- Conversion Rate
- Average Order Value
- Revenue per Session

### Tier 2 — Trend and Diagnostic KPIs

These provide performance context:

- Revenue 7D
- Conversion Rate 7D
- Revenue WoW Change
- Revenue WoW Change %
- Conversion Rate WoW Change
- Conversion Rate WoW Change %

### Tier 3 — Domain Metrics

These support detailed analysis.

#### Acquisition

- Channel Sessions
- Channel Purchasing Sessions
- Channel Conversion Rate
- Revenue per Session
- governed session-attributed channel commercial metrics and contribution metrics available in the semantic model

#### Commerce

- Refund Value
- Items per Transaction
- transaction and purchase-revenue measures exposed through the commerce semantic branch

#### User Behaviour

- Observed Users
- Purchasing Users
- Multi-Session Users
- Repeat Purchasing Session Users

#### Segment

- Segment Sessions
- Segment Purchasing Sessions
- Segment Conversion Rate
- governed session-attributed segment commercial measures

---

## 6. Report Page Requirements

The production report will contain four primary analytical pages.

### Page 1 — Executive Overview

Purpose:

Provide leadership with a concise overview of overall digital-commerce performance and recent trends.

The page should prioritize:

- executive KPI cards
- revenue trend
- conversion trend
- governed rolling context where directly comparable, together with recent seven-day versus previous seven-day performance comparisons
- limited high-value performance-driver context
- clear paths into deeper analytical pages

The page must remain concise and should not become a collection of every available metric.

### Page 2 — Acquisition & Channel Performance

Purpose:

Explain how acquisition channels contribute to traffic, purchasing activity, and session-attributed commercial performance.

The page should support:

- channel comparison
- traffic volume by channel
- purchasing-session performance by channel
- channel conversion comparison
- session-attributed revenue share
- revenue per session by channel
- identification of high-volume/low-efficiency and lower-volume/high-efficiency channels

### Page 3 — Commerce Performance

Purpose:

Explain transaction-date ecommerce performance.

The page should support:

- purchase revenue
- transaction count
- Average Order Value
- item metrics
- refund context where material and decision-useful
- revenue trends
- transaction trends
- AOV trends
- comparison of volume and value drivers

### Page 4 — Customer Behaviour & Segmentation

Purpose:

Provide controlled analysis of observed user behaviour and segment performance without violating differences in analytical grain.

The page should contain clearly separated analytical sections for:

1. observed user behaviour
2. device and geography segmentation

User-grain measures must not be presented as if they respond to the standard reporting-date relationship.
The user-behaviour section is interpreted across the full observation period. A standard Reporting Period slicer must not be applied to user-grain KPIs because `bi_user_behavior` is intentionally disconnected from the governed reporting-date relationship.
---

## 7. Information Hierarchy

Each production page should follow a consistent analytical sequence:

### Level 1 — Status

What is happening now or within the selected analytical context?

Use:

- KPI cards
- concise comparison indicators
- clearly formatted headline values

### Level 2 — Trend

How is performance changing?

Use:

- time-series visuals
- rolling trends where governed
- comparison metrics where meaningful

### Level 3 — Drivers

Where is performance coming from?

Use:

- channel
- device
- geography
- commercial-driver comparisons

### Level 4 — Investigation

What deserves further investigation?

Use:

- detailed comparisons
- tooltips
- drill-through where it adds analytical value
- supporting tables or matrices only when they improve decision-making

---

## 8. Filtering Requirements

### Date Filtering

`dim_date` is the governed reporting calendar.

Date filtering may be used for date-connected analytical branches according to the semantic-model relationships established in Phase 9.

Report visuals must respect the semantic meaning of their underlying date population.

### Channel Filtering

`dim_channel` is the governed acquisition dimension.

Channel filtering applies to the governed channel analytical branch.

The report must not create artificial propagation from channel filters into executive headline metrics or unrelated fact populations.

### User Behaviour

`bi_user_behavior` is intentionally disconnected from the standard reporting-date relationship.

User-behaviour visuals must not imply that standard date slicers filter the user-grain population when they do not.

Any contextual treatment of user observation dates must be explicitly designed and must not create an undocumented relationship.

### Segment Filtering

Device and geography analysis must use the governed fields exposed by the segment semantic branch.

---

## 9. Interaction Requirements

Report interactions should be deliberate rather than relying on Power BI defaults.

The report should support, where analytically useful:

- date slicing
- channel slicing on acquisition analysis
- device and geography slicing on segmentation analysis
- cross-highlighting between compatible visuals
- report-page navigation
- contextual tooltips
- drill-through only where it provides meaningful additional investigation

Interactions that create ambiguous analytical meaning should be disabled.

Not every visual must filter every other visual.

---

## 10. Semantic Guardrails

The report must preserve the following Phase 9 semantic rules.

### KPI Ownership

Governed KPI definitions remain owned by the dbt and semantic-model layers.

The report layer must not independently redefine business KPIs.

### Ratio Aggregation

Ratios must not be averaged across daily rows.

Where recalculation is required, compatible governed additive numerators and denominators must be used.

### Date Semantics

The report must preserve the distinction between:

- session-date metrics
- transaction-date metrics
- session-cohort/session-attributed metrics

These populations must not be presented as interchangeable.

### Channel Commercial Metrics

Channel commercial analysis uses session-attributed commercial measures.

These metrics must not be represented as equivalent to transaction-date executive revenue.

### Non-Additive Metrics

Contribution percentages, rolling metrics, and week-over-week metrics must not be summed across dates.

### User Identity

`user_pseudo_id` represents an observed pseudo-user, not a verified authenticated customer.

Report wording must use terms such as:

- Observed Users
- Purchasing Users

and must avoid unsupported claims about unique real-world customers.

---

## 11. Scope Exclusions

The report must not introduce unsupported metrics.

The following are outside the governed analytical scope unless future source data and KPI contracts explicitly support them:

- net revenue
- ROAS
- CAC
- CPA
- profit
- margin
- CLV
- churn
- formal retention metrics
- multi-touch attribution
- authenticated customer counts

The report must not infer these measures from incomplete proxies.

---

## 12. Visual Design Principles

The production report should follow these principles:

- decision-oriented rather than decorative
- limited visual density
- consistent alignment and spacing
- clear information hierarchy
- consistent KPI formatting
- business-readable titles
- minimal unnecessary legends
- restrained use of colour
- consistent number formatting
- no decorative chart types without analytical value
- tables and matrices used only when detailed comparison is required
- no duplicated visuals that communicate the same information
- no unnecessary 3D visuals, gauges, or dashboard decoration

Visual choices must be driven by the analytical question rather than by the availability of Power BI visual types.

---

## 13. Business Narrative Requirements

Each page must communicate a coherent analytical story.

The intended narrative pattern is:

**What happened → How is it changing → What is driving it → Where should the user investigate next**
Not every page must implement every narrative step when the underlying analytical grain does not support it. Full-observation-period user-behaviour analysis, for example, must not imply a time trend that the governed user-grain model does not provide.

Titles, subtitles, tooltips, KPI context, and supporting visuals should reinforce this sequence.

The report should avoid presenting disconnected metrics without analytical context.

---

## 14. Report Usability Requirements

A business user should be able to:

- understand the purpose of each page immediately
- identify the primary KPIs without searching
- understand the active filter context
- move between analytical pages easily
- distinguish headline metrics from diagnostic metrics
- interpret percentages and monetary values consistently
- identify where deeper investigation is available
- understand when an analytical population differs from another page

The report should not require knowledge of warehouse table names or technical field names.

---

## 15. Performance Requirements

The report should avoid unnecessary rendering and query overhead.

Development should prioritize:

- a limited number of purposeful visuals per page
- explicit measures rather than implicit aggregations
- avoiding unnecessary high-cardinality visual detail
- disabling irrelevant visual interactions
- avoiding duplicated calculations or redundant visuals
- using the existing Import-mode semantic model efficiently

Performance optimization should be evidence-based rather than speculative.

---

## 16. Success Criteria

Phase 10 report development will be considered successful when:

1. Each production page has a clearly defined business purpose.
2. Executive KPIs reconcile with the governed semantic model.
3. Report visuals do not redefine upstream KPI logic.
4. Date, channel, user, and segment semantics remain explicit and correct.
5. Ratios, contribution metrics, rolling metrics, and WoW metrics aggregate correctly.
6. Filter and interaction behaviour is intentional and understandable.
7. The report provides a clear analytical progression from headline performance to drivers and investigation.
8. Visual design is consistent across all production pages.
9. The report remains readable without excessive visual density.
10. Unsupported metrics or business claims are not introduced.
11. Business users can navigate the report without understanding the underlying data architecture.
12. Final report behaviour passes Phase 10 report-level QA and is ready for subsequent Phase 11 end-to-end validation.
---

## 17. Phase 10 Build Boundary

P10A defines **what the report must accomplish**.

It does not determine the final position, size, or visual type of every report element.

Those decisions belong to:

- P10B — Report Information Architecture & Page Blueprint
- P10C–P10F — Production Page Implementation
- P10G — Cross-Report Interaction Design
- P10H — Visual System & Report UX Standardization
- P10I — Business Narrative & Insight Layer
- P10J — Report-Level QA & Usability Validation
- P10K — Performance & Rendering Review
- P10L — Report Handoff & Phase Closeout

No production visual should be treated as final until the relevant downstream validation work packages are complete.