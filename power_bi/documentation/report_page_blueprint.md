# Power BI Report Page Blueprint

## 1. Purpose

This document defines the information architecture and production-page blueprint for Phase 10 — Power BI Report.

It translates the approved report requirements into a controlled visual and analytical structure before production report development begins.

The blueprint determines:

- page purpose
- analytical sequence
- KPI placement
- visual roles
- source measures and dimensions
- filter context
- interaction intent
- semantic constraints
- navigation structure

The blueprint does not redefine governed KPIs or semantic-model relationships.

---

# 2. Report Information Architecture

The production report will contain four primary analytical pages:

1. Executive Overview
2. Acquisition & Channel Performance
3. Commerce Performance
4. Customer Behaviour & Segmentation

Supporting tooltip or drill-through pages may be introduced later only when they provide clear analytical value.

The report should follow a progressive analytical path:

**Overall Performance → Acquisition Drivers → Commerce Drivers → User & Segment Investigation**

Each page must answer a distinct set of business questions rather than repeating the same visuals with different dimensions.

---

# 3. Global Page Structure

Production pages should follow a consistent visual hierarchy.

## Header

The header should contain:

- page title
- concise analytical subtitle where useful
- report navigation
- relevant filter context

## KPI Layer

A compact KPI strip should communicate the most important metrics for the page.

KPI cards should not be added simply because a measure exists.

## Analytical Layer

The central page area should contain the visuals required to explain performance, trends, comparisons, or drivers.

## Investigation Layer

Detailed comparison visuals, matrices, tooltips, or drill-through functionality should appear only where they support deeper investigation.

---

# 4. Page 1 — Executive Overview

## Purpose

Provide leadership with a concise view of overall digital-commerce performance, recent movement, and the most important signals requiring further investigation.

## Primary Business Questions

The page must answer:

- What is the overall level of commercial and traffic performance?
- Is revenue improving or deteriorating?
- Is conversion improving or deteriorating?
- How does recent performance compare with the preceding period?
- Are changes associated with traffic, purchasing activity, transaction volume, or order value?
- Which analytical area should be investigated next?

## KPI Strip

Primary KPI cards:

1. Purchase Revenue
2. Total Sessions
3. Purchasing Sessions
4. Conversion Rate
5. Total Transactions
6. Average Order Value

`Revenue per Session` should be used as a supporting efficiency metric rather than automatically expanding the primary KPI strip.

### KPI Semantic Requirements

- Purchase Revenue uses governed executive transaction-date semantics.
- Total Transactions uses governed transaction-date semantics.
- Total Sessions and Purchasing Sessions use governed session-date semantics.
- Conversion Rate uses compatible session-date numerator and denominator.
- Average Order Value uses compatible transaction-date revenue and transaction count.

The page must not imply that all headline metrics represent the same underlying date population.

## Trend Area

### Visual E1 — Purchase Revenue Trend

**Business question:** How is purchase revenue changing over time?

**Recommended visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Purchase Revenue

**Supporting context:** Revenue 7D where the visual remains readable and analytically useful.

**Semantic constraint:** Transaction-date revenue.

---

### Visual E2 — Conversion Trend

**Business question:** How is conversion performance changing?

**Recommended visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Conversion Rate

**Supporting context:** Conversion Rate 7D where useful.

**Semantic constraint:** Session-date conversion.

---

## Performance Context

### Visual E3 — Recent Revenue Change

**Business question:** How does recent revenue performance compare with the previous governed comparison period?

**Recommended treatment:** Compact KPI/change indicator

**Measures:**

- Revenue WoW Change
- Revenue WoW Change %

**Constraint:** Treat as point-in-time comparison metrics. Do not aggregate across dates.

---

### Visual E4 — Recent Conversion Change

**Business question:** How does recent conversion performance compare with the previous governed comparison period?

**Recommended treatment:** Compact KPI/change indicator

**Measures:**

- Conversion Rate WoW Change
- Conversion Rate WoW Change %

**Constraint:** Treat as point-in-time comparison metrics. Do not aggregate across dates.

---

## Executive Driver Context

The Executive Overview may include a limited driver visual only if it helps direct the user toward deeper analysis.

It must not duplicate the full Acquisition or Commerce pages.

A compact comparison of traffic, transaction, revenue, or efficiency movement may be used to indicate where further investigation is warranted.

Detailed channel contribution analysis belongs on the Acquisition page.

## Executive Filters

Primary filter:

- governed reporting date

Channel filtering must not be presented as a global executive filter because the executive and channel commercial populations intentionally use different semantic branches.

## Executive Interaction Rules

- date context filters compatible executive visuals
- trend visuals should cross-highlight only when analytical meaning remains clear
- no channel slicer should artificially change executive headline metrics
- navigation should provide direct access to Acquisition and Commerce analysis

---

# 5. Page 2 — Acquisition & Channel Performance

## Purpose

Explain how acquisition channels contribute to traffic, purchasing activity, conversion, and session-attributed commercial outcomes.

## Primary Business Questions

The page must answer:

- Which channels drive traffic?
- Which channels drive purchasing sessions?
- Which channels convert efficiently?
- Which channels contribute disproportionately or under-proportionately to commercial outcomes?
- Which channels warrant further investigation?

## KPI Strip

Recommended channel-context KPIs:

1. Channel Sessions
2. Channel Purchasing Sessions
3. Channel Conversion Rate
4. session-attributed channel purchase revenue
5. session-attributed channel transaction count

Only governed measures already exposed by the semantic model may be used.

## Filters

Primary filters:

- reporting date
- channel group

Channel filtering must use `dim_channel`.

## Channel Comparison

### Visual A1 — Sessions by Channel

**Business question:** Which channels generate the most traffic?

**Recommended visual:** Horizontal bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Channel Sessions

**Sort:** descending by Channel Sessions unless governed channel ordering is analytically preferable for a specific presentation.

---

### Visual A2 — Conversion Rate by Channel

**Business question:** Which channels convert most effectively?

**Recommended visual:** Horizontal bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Channel Conversion Rate

**Constraint:** Do not interpret conversion rate without considering traffic volume.

---

### Visual A3 — Session Contribution by Channel

**Business question:** What share of traffic is generated by each channel?

**Recommended visual:** 100% contribution comparison or ranked bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Channel Session Contribution

**Constraint:** Contribution is non-additive across dates.

---

## Commercial Contribution

### Visual A4 — Session-Attributed Commercial Performance by Channel

**Business question:** Which channels are associated with the strongest commercial outcomes?

**Recommended visual:** Ranked bar chart

**Category:** `dim_channel[channel_group]`

**Measures:** governed session-attributed purchase revenue and/or transaction measure

**Semantic constraint:** These are session-attributed commercial metrics and must not be described as transaction-date executive revenue.

---

## Efficiency vs Scale

### Visual A5 — Channel Scale vs Conversion

**Business question:** Which channels combine meaningful traffic scale with strong conversion performance?

**Recommended visual:** Scatter plot, only if readability is acceptable with the limited channel population.

**X-axis:** Channel Sessions

**Y-axis:** Channel Conversion Rate

**Category/Details:** Channel Group

**Optional size:** governed session-attributed commercial measure if this improves interpretation without overstating precision.

The visual should help distinguish:

- high-volume / high-conversion channels
- high-volume / low-conversion channels
- low-volume / high-conversion channels
- low-volume / low-conversion channels

---

## Acquisition Interaction Rules

- date filters channel metrics through the governed date relationship
- channel slicer filters the acquisition branch
- channel selections may cross-highlight compatible acquisition visuals
- acquisition interactions must not be extended artificially into unrelated semantic branches

---

# 6. Page 3 — Commerce Performance

## Purpose

Explain transaction-date ecommerce performance and distinguish changes in transaction volume from changes in order value.

## Primary Business Questions

The page must answer:

- How much purchase revenue was generated?
- How many transactions occurred?
- What is the Average Order Value?
- How many items are purchased per transaction?
- How are revenue, transactions, and AOV changing?
- Are revenue changes more consistent with volume changes or order-value changes?
- Are refunds material in the available data?

## KPI Strip

Primary commerce KPIs:

1. Purchase Revenue
2. Total Transactions
3. Average Order Value
4. Items per Transaction
5. Refund Value

## Filters

Primary filter:

- governed reporting date

Commerce analysis must preserve transaction-date semantics.

---

## Commerce Trends

### Visual C1 — Purchase Revenue Over Time

**Business question:** How is transaction-date purchase revenue changing?

**Recommended visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Purchase Revenue

---

### Visual C2 — Transactions Over Time

**Business question:** How is transaction volume changing?

**Recommended visual:** Line or column chart

**X-axis:** `dim_date[date_day]`

**Measure:** Total Transactions

---

### Visual C3 — Average Order Value Over Time

**Business question:** Is average transaction value changing?

**Recommended visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Average Order Value

---

## Volume vs Value Diagnosis

### Visual C4 — Revenue, Transactions and AOV Context

**Business question:** Are revenue movements primarily associated with transaction volume or order value?

The final implementation should provide a clear comparison between:

- Purchase Revenue
- Total Transactions
- Average Order Value

The visual form should prioritize interpretability.

Avoid forcing metrics with materially different units onto an ambiguous dual-axis chart if separate aligned trend visuals provide clearer interpretation.

---

## Item Behaviour

### Visual C5 — Items per Transaction

**Business question:** Is basket quantity changing?

**Recommended visual:** KPI plus trend where variation is analytically meaningful.

**Measure:** Items per Transaction

---

## Refund Context

Refund Value should be displayed proportionately to its analytical importance.

If the governed data contains no material refund activity, it should not consume a large visual area merely to fill the page.

---

# 7. Page 4 — Customer Behaviour & Segmentation

## Purpose

Provide analysis of observed pseudo-user behaviour and daily device/geography segment performance while preserving the different grains and filter semantics of the underlying models.

This page must visually distinguish the two analytical populations.

---

# 7.1 Observed User Behaviour Section

## Primary Business Questions

- How many pseudo-users were observed?
- How many observed users purchased?
- How many users had multiple sessions?
- How many users purchased across multiple sessions?
- How many users purchased across multiple observed dates?

## KPI Strip

User-behaviour KPIs:

1. Observed Users
2. Purchasing Users
3. Multi-Session Users
4. Repeat Purchasing Session Users
5. Repeat Purchasing Date Users

## Critical Filter Rule

The user-behaviour model is intentionally disconnected from `dim_date`.

Standard report date slicers must not be presented as controlling these user-grain KPIs.

The visual design must make this distinction understandable rather than hiding it.

## Recommended User Behaviour Visual

### Visual U1 — Observed User Behaviour Composition

**Business question:** How does the observed user population break down into increasingly engaged behaviours?

**Recommended treatment:** Compact comparison using KPI cards or bars.

The visual must not imply that behavioural categories are necessarily mutually exclusive.

---

# 7.2 Segment Performance Section

## Primary Business Questions

- Which devices generate the most sessions?
- How does conversion vary by device?
- Which countries generate the most traffic?
- Which segments show stronger or weaker commercial efficiency?
- Which high-volume segments underperform on conversion?

## Segment Filters

Where useful:

- reporting date
- device category
- country

These filters apply to the governed segment branch.

---

### Visual S1 — Sessions by Device

**Business question:** How is traffic distributed across device categories?

**Recommended visual:** Bar chart

**Category:** device category

**Measure:** Segment Sessions

---

### Visual S2 — Conversion Rate by Device

**Business question:** How does conversion performance vary by device?

**Recommended visual:** Bar chart

**Category:** device category

**Measure:** Segment Conversion Rate

---

### Visual S3 — Sessions by Country

**Business question:** Which countries contribute the most traffic?

**Recommended visual:** Ranked horizontal bar chart

**Category:** country

**Measure:** Segment Sessions

A map should not be used merely because geography is available. A ranked comparison is preferred unless geographic position itself contributes analytical value.

---

### Visual S4 — Segment Commercial Efficiency

**Business question:** Which device/geography segments combine traffic scale with stronger commercial efficiency?

**Recommended visual:** ranked comparison or scatter plot depending on cardinality and readability.

Potential governed measures:

- Segment Sessions
- Segment Conversion Rate
- session-attributed purchase revenue
- revenue per session

High-cardinality combinations should not be displayed if they reduce readability.

---

# 8. Navigation Architecture

Primary navigation should provide direct access to:

- Executive Overview
- Acquisition & Channel Performance
- Commerce Performance
- Customer Behaviour & Segmentation

Navigation should remain in a consistent location across production pages.

The current page should be visually identifiable.

Navigation should not rely on users discovering Power BI page tabs.

---

# 9. Slicer Architecture

Slicers should be purposeful and page-specific.

## Date

Date filtering is relevant to:

- Executive Overview
- Acquisition & Channel Performance
- Commerce Performance
- Segment analysis

Date filtering must not imply standard date filtering of disconnected user-behaviour KPIs.

## Channel

Channel filtering belongs primarily to Acquisition & Channel Performance.

It should not be synchronized globally where doing so would imply unsupported filtering of other analytical branches.

## Device and Country

Device and country filters belong to segment analysis.

They should not be presented as global report filters unless a later semantic design explicitly supports that behaviour.

---

# 10. Tooltip Strategy

Tooltips may be used to provide additional context without increasing page density.

Potential uses include:

- exact KPI values
- supporting conversion context
- channel traffic and commercial context
- date-specific trend context
- segment performance context

Tooltip pages should be created only when they provide information that materially improves interpretation.

They must not become hidden mini-reports containing excessive metrics.

---

# 11. Drill-Through Strategy

Drill-through is optional rather than mandatory.

It should be implemented only when:

- a meaningful lower analytical grain exists
- the destination answers a distinct investigation question
- filter context can be transferred without semantic ambiguity

No drill-through page should be created solely to demonstrate a Power BI feature.

---

# 12. Visual Selection Standards

Preferred visual families:

- KPI cards for headline values
- line charts for time trends
- bar charts for categorical comparison
- matrices for detailed comparison where necessary
- scatter plots for scale-versus-efficiency questions when cardinality is appropriate

Avoid by default:

- pie charts with many categories
- donut charts used only for decoration
- gauges
- 3D charts
- excessive combo charts
- dense tables without an investigation purpose
- maps when ranked comparisons answer the question more clearly

---

# 13. Report Density Standard

Each page should contain only the visuals required to answer its business questions.

The target is not to maximize the number of visuals.

A professional page should generally provide:

- a concise KPI layer
- two to four primary analytical visuals
- limited supporting context
- deliberate whitespace

Additional visuals require a distinct analytical purpose.

---

# 14. Cross-Page Semantic Rules

The report must preserve the following distinctions:

### Executive

Headline commercial metrics use their governed executive semantics.

### Acquisition

Commercial outcomes are session-attributed.

### Commerce

Commercial analysis is transaction-date based.

### User Behaviour

Analysis is user-grain and disconnected from the standard daily reporting relationship.

### Segmentation

Analysis uses session-date and session-attributed segment semantics.

The visual layer must not conceal these differences for the sake of apparent consistency.

---

# 15. Build Sequence

Production implementation will follow this order:

1. Executive Overview
2. Acquisition & Channel Performance
3. Commerce Performance
4. Customer Behaviour & Segmentation

Each page should be:

**built → visually reviewed → semantically checked → retained as the production baseline**

before proceeding to the next page.

Cross-report interactions and visual-system standardization will then be completed across the full report.

---

# 16. P10B Acceptance Criteria

P10B is complete when:

1. Every production page has a defined purpose.
2. Every page answers explicit business questions.
3. KPI placement is defined before production development.
4. Primary visual roles are defined.
5. Filter scope is defined.
6. User-behaviour and date-connected populations remain explicitly separated.
7. Acquisition and executive commercial semantics remain explicitly separated.
8. Navigation architecture is defined.
9. Tooltip and drill-through usage is governed rather than feature-driven.
10. Visual-density standards are established.
11. No unsupported KPI or analytical population is introduced.
12. The blueprint provides sufficient direction to begin production report development without redesigning the analytical architecture during page construction.