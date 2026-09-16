# Power BI Report Page Blueprint

## 1. Purpose

This document defines the final information architecture and production-page blueprint for Phase 10 — Power BI Report.

It translates the approved reporting requirements and governed Phase 9 semantic model into the analytical structure implemented in the production Power BI report.

The blueprint defines:

- page purpose
- analytical sequence
- KPI placement
- visual roles
- source measures and dimensions
- filter context
- interaction intent
- semantic constraints
- navigation structure
- final implementation decisions

The blueprint does not redefine governed KPIs, analytical grains, attribution logic, or semantic-model relationships.

---

# 2. Report Information Architecture

The production report contains four primary analytical pages:

1. Executive Overview
2. Acquisition & Channel Performance
3. Commerce Performance
4. Customer Behaviour & Segmentation

The report follows the analytical path:

**Overall Performance → Acquisition Drivers → Commerce Drivers → User & Segment Investigation**

Each page answers a distinct business question and avoids unnecessary duplication of metrics or visuals.

Supporting tooltip or drill-through pages are not required unless they provide clear analytical value.

---

# 3. Global Page Structure

Production pages use a consistent visual hierarchy.

## Header

The header contains:

- page title
- concise analytical subtitle
- consistent report navigation
- relevant filter context where semantically valid

## KPI Layer

A compact KPI strip communicates the most important metrics for each page.

KPI cards are included only when they provide direct business value.

## Analytical Layer

The primary visual area explains:

- trends
- comparisons
- performance drivers
- commercial efficiency
- segment differences

## Investigation Layer

Additional detail is included only when it supports a meaningful investigation question.

The report does not add visual complexity only to demonstrate Power BI features.

---

# 4. Page 1 — Executive Overview

## Purpose

Provide leadership with a concise overview of overall digital-commerce performance, recent trends, and signals that may require further investigation.

## Subtitle

**Digital commerce performance, trends and key business signals**

## Primary Business Questions

The page answers:

- What is the overall level of commercial and traffic performance?
- How is purchase revenue changing?
- How is conversion changing?
- How does recent seven-day performance compare with the previous seven-day period?
- What should be investigated further?

## KPI Strip

Primary KPI cards:

1. Purchase Revenue
2. Total Sessions
3. Purchasing Sessions
4. Conversion Rate
5. Total Transactions
6. Average Order Value

### KPI Semantic Requirements

- Purchase Revenue uses governed transaction-date semantics.
- Total Transactions uses governed transaction-date semantics.
- Total Sessions uses session-date semantics.
- Purchasing Sessions uses session-date semantics.
- Conversion Rate uses compatible session-date components.
- Average Order Value uses compatible transaction-date revenue and transaction count.

The page must not imply that all executive KPIs represent the same underlying analytical population.

---

## Visual E1 — Revenue Trend

**Business question:** How is purchase revenue changing over time?

**Visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Daily Revenue

**Semantic constraint:** Transaction-date revenue.

The stored warehouse `revenue_7d` metric is a rolling seven-day sum. It is not plotted beside Daily Revenue because the two series represent different aggregation scales and would create a misleading visual comparison.

---

## Visual E2 — Conversion Trend

**Business question:** How is conversion performance changing?

**Visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measures:**

- Daily Conversion Rate
- 7D Conversion Rate

**Semantic constraint:** Session-date conversion.

The seven-day conversion measure remains appropriate because it is directly comparable with the daily conversion rate as a rate metric.

---

## Performance Comparison KPIs

Two compact comparison indicators provide recent-period context:

### Revenue: Last 7D vs Previous 7D

Uses the governed warehouse comparison metric.

### Conversion: Last 7D vs Previous 7D

Uses the governed warehouse comparison metric.

These are point-in-time comparison metrics and must not be summed across dates.

---

## Executive Filters

Primary filter:

- Reporting Period

The filter uses the governed reporting-date dimension.

Channel filtering is not presented as a global executive filter because executive and channel commercial measures belong to different governed semantic branches.

---

## Executive Interaction Rules

- Reporting Period filters compatible executive visuals.
- Trend interactions must preserve clear analytical meaning.
- No channel filter may artificially change executive headline metrics.
- Navigation provides direct access to the other analytical pages.

---

# 5. Page 2 — Acquisition & Channel Performance

## Purpose

Explain how acquisition channels contribute to traffic, purchasing activity, conversion, session-attributed revenue, and commercial efficiency.

## Subtitle

**Traffic, conversion and session-attributed commercial performance by channel**

## Primary Business Questions

The page answers:

- Which channels generate the most traffic?
- Which channels generate purchasing sessions?
- Which channels convert most effectively?
- Which channels contribute most to session-attributed purchase revenue?
- Which channels generate the strongest revenue per session?
- Which channels combine meaningful scale with commercial efficiency?
- Which channels require further investigation?

## KPI Strip

Primary KPIs:

1. Channel Sessions
2. Channel Purchasing Sessions
3. Channel Conversion Rate
4. Revenue per Session

`Channel Session Contribution` is not used as a headline KPI because at the unfiltered total context it evaluates to 100%, making it mathematically correct but weak as a decision-support KPI.

---

## Filters

Primary filter:

- Reporting Period

Channel comparison is performed directly through the governed channel visuals.

Channel semantics use `dim_channel`.

---

## Visual A1 — Sessions by Channel

**Business question:** Which channels generate the most traffic?

**Visual:** Horizontal bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Channel Sessions

**Sort:** Descending by Channel Sessions.

All governed channel groups are displayed where space permits so important low-volume channels are not hidden solely for visual convenience.

---

## Visual A2 — Conversion Rate by Channel

**Business question:** Which channels convert most effectively?

**Visual:** Horizontal bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Channel Conversion Rate

**Constraint:** Conversion must be interpreted together with channel traffic volume.

Low-volume channels with unusually high conversion must not automatically be interpreted as the strongest acquisition channels.

---

## Visual A3 — Revenue Share by Channel

**Business question:** Which channels contribute most to session-attributed purchase revenue?

**Visual:** Horizontal bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Governed channel revenue contribution / revenue share

**Semantic constraint:** Revenue is session-attributed commercial revenue, not transaction-date executive revenue.

Contribution percentages are non-additive across dates.

---

## Visual A4 — Revenue per Session by Channel

**Business question:** Which channels generate stronger commercial efficiency per session?

**Visual:** Horizontal bar chart

**Category:** `dim_channel[channel_group]`

**Measure:** Revenue per Session

**Semantic constraint:** Revenue and session populations must use compatible session-attributed semantics.

This visual provides the scale-versus-efficiency context without requiring a scatter plot.

---

## Acquisition Interaction Rules

- Reporting Period filters the governed channel branch.
- Channel selections may cross-highlight compatible acquisition visuals.
- Acquisition interactions must not be propagated artificially into unrelated semantic branches.
- Session-attributed commercial measures must remain clearly distinguished from transaction-date executive metrics.

---

# 6. Page 3 — Commerce Performance

## Purpose

Explain transaction-date ecommerce performance and distinguish changes in revenue, transaction volume, order value, and basket quantity.

## Subtitle

**Revenue, transactions, order value and basket performance over time**

## Primary Business Questions

The page answers:

- How much purchase revenue was generated?
- How many transactions occurred?
- What is the Average Order Value?
- How many items are purchased per transaction?
- How is revenue changing?
- How is transaction volume changing?
- How is Average Order Value changing?
- How is basket quantity changing?
- Are observed revenue movements more consistent with volume or value changes?

## KPI Strip

Primary commerce KPIs:

1. Purchase Revenue
2. Total Transactions
3. Average Order Value
4. Items per Transaction

Refund Value is not given headline visual space unless refund activity is material and decision-useful.

---

## Filters

Primary filter:

- Reporting Period

Commerce analysis preserves transaction-date semantics.

---

## Visual C1 — Revenue Trend

**Business question:** How is transaction-date purchase revenue changing?

**Visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Daily Revenue

---

## Visual C2 — Transaction Trend

**Business question:** How is transaction volume changing?

**Visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Total Transactions

---

## Visual C3 — Average Order Value Trend

**Business question:** How is average transaction value changing?

**Visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Average Order Value

---

## Visual C4 — Items per Transaction Trend

**Business question:** How is basket quantity changing?

**Visual:** Line chart

**X-axis:** `dim_date[date_day]`

**Measure:** Items per Transaction

The report preserves real observed spikes instead of clipping or smoothing them solely for visual appearance.

---

## Commerce Interpretation Rule

Revenue, transactions, Average Order Value, and Items per Transaction use separate trend visuals because they have different units and analytical meanings.

The report avoids forcing incompatible measures onto ambiguous dual-axis charts.

---

## Refund Context

Refund information may be included when material and decision-useful.

If refund activity is not material enough to change interpretation, it should not consume report space only to satisfy visual completeness.

---

# 7. Page 4 — Customer Behaviour & Segmentation

## Purpose

Provide controlled analysis of observed user behaviour and device/geography segment performance while preserving differences in analytical grain and date semantics.

## Subtitle

**User engagement, repeat purchasing behaviour and segment performance across the full observation period**

This page is intentionally interpreted across the full observation period.

A standard Reporting Period slicer is not used because the user-grain population is not governed by the standard daily reporting relationship.

---

# 7.1 Observed User Behaviour

## Primary Business Questions

The section answers:

- How many pseudo-users were observed?
- How many observed users purchased?
- How many users had multiple sessions?
- How many users purchased across multiple sessions?

## KPI Strip

User-behaviour KPIs:

1. Observed Users
2. Purchasing Users
3. Multi-Session Users
4. Repeat Purchasing Session Users

`Repeat Purchasing Date Users` is not included in the production KPI strip.

---

## Critical Filter Rule

`bi_user_behavior` is intentionally disconnected from `dim_date`.

Standard report date slicers must not be presented as controlling user-grain KPIs.

The page therefore communicates explicitly that its user-behaviour metrics represent the full observation period.

User-level counts must be calculated from the user-grain model and must not be reconstructed by summing user metrics from daily segment tables.

---

# 7.2 Device Performance

Device analysis uses the governed segment branch.

## Visual S1 — Sessions by Device

**Business question:** How is traffic distributed across device categories?

**Visual:** Bar chart

**Category:** Device Category

**Measure:** Segment Sessions

---

## Visual S2 — Conversion Rate by Device

**Business question:** How does conversion performance vary by device?

**Visual:** Bar chart

**Category:** Device Category

**Measure:** Segment Conversion Rate

---

## Visual S3 — Revenue by Device

**Business question:** Which devices generate the greatest session-attributed commercial value?

**Visual:** Bar chart

**Category:** Device Category

**Measure:** Session-attributed Purchase Revenue

---

## Visual S4 — Revenue per Session by Device

**Business question:** Which device categories show stronger commercial efficiency per session?

**Visual:** Bar chart

**Category:** Device Category

**Measure:** Revenue per Session

---

# 7.3 Country Performance

## Visual S5 — Revenue by Country

**Business question:** Which countries contribute the most session-attributed purchase revenue?

**Visual:** Ranked horizontal bar chart

**Category:** Country

**Measure:** Session-attributed Purchase Revenue

Natural scrolling is acceptable where country cardinality exceeds available visual space.

A Top-N filter must not be introduced solely to remove a scrollbar if it would conceal analytically relevant countries.

---

## Visual S6 — Conversion Rate by Country

**Business question:** How does conversion vary across countries?

**Visual:** Ranked horizontal bar chart

**Category:** Country

**Measure:** Segment Conversion Rate

Conversion must be interpreted with awareness of traffic scale.

---

# 8. Navigation Architecture

Primary navigation provides direct access to:

- Executive Overview
- Acquisition & Channel Performance
- Commerce Performance
- Customer Behaviour & Segmentation

Navigation remains consistent across production pages.

The current page should be visually identifiable.

Navigation must not depend solely on users discovering Power BI page tabs.

---

# 9. Slicer Architecture

Slicers are purposeful and page-specific.

## Reporting Period

The Reporting Period slicer is used on:

- Executive Overview
- Acquisition & Channel Performance
- Commerce Performance

It is not used on Customer Behaviour & Segmentation because the user-grain branch is intentionally disconnected from the governed daily reporting relationship.

## Channel

Channel context belongs to the governed acquisition analytical branch.

It must not be synchronized globally where doing so would imply unsupported filtering of unrelated analytical populations.

## Device and Country

Device and country are used as analytical comparison dimensions on the Customer Behaviour & Segmentation page.

They are not treated as global report filters unless a future semantic design explicitly supports that behaviour.

---

# 10. Tooltip Strategy

Tooltips may provide additional context without increasing visual density.

Useful tooltip content can include:

- exact KPI values
- date-specific trend values
- conversion context
- channel traffic and commercial context
- device or geography context

Dedicated tooltip pages are optional.

They should be created only when they materially improve interpretation.

They must not become hidden mini-reports.

---

# 11. Drill-Through Strategy

Drill-through is optional.

It should be implemented only when:

- a meaningful lower analytical grain exists
- the destination answers a distinct business question
- filter context can transfer without semantic ambiguity

No drill-through page should be created only to demonstrate Power BI functionality.

---

# 12. Visual Selection Standards

Preferred visual families:

- KPI cards for headline values
- line charts for time trends
- horizontal or vertical bar charts for categorical comparisons

Tables, matrices, scatter plots, maps, and other visual types are used only when they improve analytical interpretation.

Avoid by default:

- decorative pie or donut charts
- gauges
- 3D charts
- unnecessary combo charts
- dense tables without investigation value
- maps when ranked comparisons answer the question more clearly
- visuals that repeat information already communicated elsewhere

---

# 13. Visual System

The production report uses a restrained professional design system.

General principles:

- white background
- restrained blue palette
- minimal decorative styling
- no unnecessary borders
- no unnecessary shadows
- consistent spacing
- business-readable titles
- deliberate whitespace

## Typography

### Page Title

Segoe UI Semibold — 18 pt

### Page Subtitle

Segoe UI Regular — 11 pt

### KPI Callout

Segoe UI Semibold — 22 pt

### KPI Label

Segoe UI Regular — 10 pt

### Chart Title

Segoe UI Semibold — 12 pt

### Legend

9 pt

### Axis Values

9 pt

### Axis Titles

Segoe UI Semibold — 9 pt

---

# 14. Report Density Standard

Each page contains only the visuals required to answer its business questions.

The objective is not to maximize visual count.

A production page should generally contain:

- a concise KPI layer
- a limited number of primary analytical visuals
- only necessary supporting context
- deliberate whitespace

Additional visuals require a distinct analytical purpose.

---

# 15. Business Narrative

The report follows the general analytical progression:

**What happened → How is it changing → What is driving it → Where should the user investigate next**

Not every page must implement every narrative stage when the underlying grain does not support it.

For example, full-observation-period user-behaviour KPIs must not be given artificial time-trend behavior merely to make the page structurally identical to date-connected pages.

Titles, subtitles, KPI context, visual ordering, and supporting comparisons provide the page-level analytical narrative.

---

# 16. Cross-Page Semantic Rules

The report preserves the following distinctions.

## Executive

Headline metrics use their governed executive semantics.

## Acquisition

Commercial outcomes are session-attributed.

## Commerce

Commercial analysis is transaction-date based.

## User Behaviour

Analysis is user-grain and disconnected from the standard daily reporting relationship.

## Segmentation

Device and geography analysis uses governed session-date and session-attributed segment semantics.

The visual layer must not conceal these distinctions for apparent consistency.

---

# 17. Production Page Summary

## Page 1 — Executive Overview

KPI cards:

- Purchase Revenue
- Total Sessions
- Purchasing Sessions
- Conversion Rate
- Total Transactions
- Average Order Value

Visuals:

- Revenue Trend
- Conversion Trend
- Revenue: Last 7D vs Previous 7D
- Conversion: Last 7D vs Previous 7D

Filter:

- Reporting Period

---

## Page 2 — Acquisition & Channel Performance

KPI cards:

- Channel Sessions
- Channel Purchasing Sessions
- Channel Conversion Rate
- Revenue per Session

Visuals:

- Sessions by Channel
- Conversion Rate by Channel
- Revenue Share by Channel
- Revenue per Session by Channel

Filter:

- Reporting Period

---

## Page 3 — Commerce Performance

KPI cards:

- Purchase Revenue
- Total Transactions
- Average Order Value
- Items per Transaction

Visuals:

- Revenue Trend
- Transaction Trend
- Average Order Value Trend
- Items per Transaction Trend

Filter:

- Reporting Period

---

## Page 4 — Customer Behaviour & Segmentation

KPI cards:

- Observed Users
- Purchasing Users
- Multi-Session Users
- Repeat Purchasing Session Users

Device visuals:

- Sessions by Device
- Conversion Rate by Device
- Revenue by Device
- Revenue per Session by Device

Country visuals:

- Revenue by Country
- Conversion Rate by Country

Filter:

- no standard Reporting Period slicer

Analytical context:

- full observation period

---

# 18. Phase 10 Implementation Outcome

The final Power BI report contains four production analytical pages built on the governed Phase 9 semantic model.

The production implementation preserves:

- governed KPI definitions
- reporting-date semantics
- transaction-date semantics
- session-date semantics
- session-attributed commercial semantics
- user-grain isolation
- controlled filter propagation
- non-additive metric behavior
- deliberate interaction design

The final report favors analytical clarity over feature density.

Features such as additional drill-through pages, dedicated tooltip pages, maps, scatter plots, or decorative visuals were not added where they did not provide sufficient decision value.

---

# 19. Phase 10 Blueprint Acceptance

The production blueprint is satisfied when:

1. Each production page has a clear business purpose.
2. Page structure matches the governed semantic model.
3. KPI placement is deliberate.
4. Visual roles support explicit analytical questions.
5. Reporting Period filtering is used only where semantically valid.
6. User-grain and date-connected analytical populations remain separated.
7. Acquisition and executive commercial semantics remain separated.
8. Navigation is consistent.
9. Visual density remains controlled.
10. Unsupported metrics are not introduced.
11. The report passes Phase 10 report-level QA and rendering review.
12. The final report is ready for Phase 11 end-to-end validation.

---

# 20. Final Build Status

Production implementation sequence:

1. Executive Overview — Complete
2. Acquisition & Channel Performance — Complete
3. Commerce Performance — Complete
4. Customer Behaviour & Segmentation — Complete
5. Cross-report interaction review — Complete
6. Visual-system standardization — Complete
7. Business narrative review — Complete
8. Report-level QA — Complete
9. Performance and rendering review — Complete

The final Power BI artifact is retained at:

`power_bi/digital_commerce_performance_analytics.pbix`

Phase 10 report implementation and handoff are complete through P10L.

The report subsequently passed Phase 11 end-to-end validation and is retained as the final Power BI reporting artifact for final documentation and release.
