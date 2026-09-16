# BI Serving Requirements

## Project

Digital Commerce Performance Analytics

## Phase

Phase 8 — BI Serving Layer

## Work Package

P8A — BI Consumption & Serving Requirements

---

# 1. Purpose

This document defines the approved consumption and serving requirements for the BI Serving Layer.

The BI Serving Layer sits between the governed analytical models produced in Phases 5–7 and the Power BI semantic model implemented in Phase 9.

Its purpose is to provide stable, business-readable, consumption-oriented datasets without moving governed business logic into Power BI or unnecessarily duplicating upstream analytical models.

This document defines the approved consumption and serving requirements that governed the Phase 8 implementation. The final number, names, and physical implementation of serving models were subsequently defined in P8B — Serving Architecture & Model Contracts.

---

# 2. Architectural Position

The governed analytical flow is:

```text
GA4 source
    ↓
Staging
    ↓
Intermediate
    ↓
Core Warehouse
    ↓
Business Marts
    ↓
Executive KPI Layer
    ↓
BI Serving Layer
    ↓
Power BI Semantic Model
    ↓
Power BI Report
```

The BI Serving Layer is a consumption boundary.

It must not reconstruct:

- sessionization
- purchase deduplication
- transaction identity
- channel classification
- attribution logic
- governed KPI definitions
- governed rolling-window logic
- governed Week-over-Week logic

These responsibilities remain owned by the upstream analytical layers.

---

# 3. BI Consumers

The primary downstream consumer is the Power BI semantic model.

The implemented report supports leadership and analytical consumers who need to understand:

- overall digital-commerce performance
- short-term executive trends
- acquisition-channel performance and contribution
- commerce performance
- observed pseudo-user behaviour
- device and geographic segment performance

The serving layer must therefore support both executive monitoring and controlled analytical drill-down without requiring Power BI to reconstruct warehouse business logic.

---

# 4. Required BI Subject Areas

## 4.1 Executive Performance

The serving layer must support:

- session count
- purchasing session count
- conversion rate
- transaction count
- purchase revenue
- average order value
- revenue per session
- seven-day rolling revenue
- seven-day rolling conversion
- Week-over-Week revenue change
- Week-over-Week conversion change

The serving interface must retain the additive components required for correct period-level KPI recalculation.

---

## 4.2 Acquisition and Channel Performance

The serving layer must support governed channel analysis including:

- channel
- sessions
- purchasing sessions
- channel conversion
- session contribution
- purchasing-session contribution
- session-attributed transactions
- session-attributed purchase revenue
- transaction contribution
- revenue contribution

Channel reporting must preserve the session-date and session-attributed semantics governed upstream.

---

## 4.3 Commerce Performance

The serving layer must support analysis of:

- transaction count
- purchase revenue
- refund value
- shipping value
- tax value
- purchased item quantity
- average order value
- items per transaction

Transaction-date commerce measures must remain distinguishable from session-attributed commercial measures.

Refund value must remain separate from purchase revenue. The serving layer must not introduce an undocumented net-revenue metric.

---

## 4.4 Observed User Behaviour

The serving layer must support controlled analysis of the observed GA4 pseudo-user population including:

- session activity
- active dates
- purchasing activity
- transaction activity
- purchase revenue
- purchased item quantity
- observed first and last activity dates
- multi-session behaviour
- later-date return behaviour
- repeat purchasing-session behaviour
- repeat purchasing-date behaviour

`user_pseudo_id` represents an observed analytical identifier and must not be exposed or described as authenticated customer identity.

The serving layer must not introduce unsupported customer lifetime value, retention, or authenticated-customer metrics.

---

## 4.5 Device and Geography Performance

The serving layer must support analysis by:

- session date
- device category
- country

Required segment measures include:

- sessions
- purchasing sessions
- conversion rate
- session-attributed transactions
- session-attributed purchase revenue
- revenue per session

Segment commercial measures retain session-attributed semantics.

---

# 5. Required Analytical Grains

The serving design must preserve or intentionally derive from the following governed analytical grains.

| Subject Area | Governed Grain |
|---|---|
| Executive KPI base | one row per governed calendar date |
| Executive trends | one row per governed calendar date |
| Channel drivers | one row per session date × governed channel |
| Ecommerce daily | one row per governed calendar date |
| Observed user behaviour | one row per observed `user_pseudo_id` |
| Segment performance | one row per session date × device category × country |
| Date dimension | one row per governed calendar date |
| Channel dimension | one row per governed channel |

Serving models must not combine incompatible grains in a way that creates row multiplication or ambiguous measure semantics.

---

# 6. Metric Semantic Families

The serving layer must preserve the semantic families established upstream.

## 6.1 Session-Date

Examples include:

- session count
- purchasing session count
- conversion rate
- session rolling measures
- channel session measures
- segment session measures

These describe sessions occurring or originating on the governed session date.

## 6.2 Transaction-Date

Examples include:

- transaction count
- purchase revenue
- refund value
- shipping value
- tax value
- purchased item quantity
- average order value
- items per transaction
- rolling revenue
- revenue Week-over-Week metrics

These describe commercial activity occurring on the governed transaction date.

## 6.3 Session-Cohort / Session-Attributed

Examples include:

- session-attributed transaction count
- session-attributed purchase revenue
- revenue per session
- channel commercial contribution
- segment commercial measures

These describe commercial outcomes attributed to the originating session population.

A shared calendar date must not be interpreted as evidence that these semantic families represent the same analytical population.

---

# 7. Aggregation Requirements

Additive measures may be aggregated across compatible dimensions and reporting periods.

Ratio metrics must be recalculated from their governed additive components when the reporting grain changes.

Examples include:

```text
period conversion rate
=
SUM(purchasing_session_count)
/
SUM(session_count)
```

```text
period average order value
=
SUM(purchase_revenue)
/
SUM(transaction_count)
```

```text
period revenue per session
=
SUM(session_attributed_purchase_revenue)
/
SUM(session_count)
```

Daily ratios must not be averaged to create period-level KPI values.

Daily contribution percentages must not be summed or averaged to create multi-day contribution metrics.

Multi-day contribution metrics must be recalculated from compatible additive numerator and denominator populations.

---

# 8. Date Requirements

The serving layer must provide a controlled relationship to the governed date dimension.

Power BI must be able to support:

- daily analysis
- weekly analysis
- monthly analysis
- quarter-level analysis where meaningful
- date-range filtering
- chronological trend reporting
- governed rolling and Week-over-Week executive metrics

The serving design must preserve the distinction between session-date and transaction-date semantics even where both are represented through a shared reporting-date field.

The BI Serving Layer must not create fabricated historical observations outside the governed source observation window.

---

# 9. Dimension and Filtering Requirements

The serving interface must support controlled filtering where applicable by:

- date
- governed acquisition channel
- device category
- country
- observed pseudo-user behavioural attributes

Governed channel metadata must remain consistent with `dim_channel`.

Calendar attributes must remain consistent with `dim_date`.

The serving layer must not introduce alternative channel classifications or independent calendar logic.

---

# 10. Field Exposure Requirements

Only fields required for downstream analytical consumption, filtering, relationships, validation, or governed recalculation should be exposed.

The serving layer should avoid exposing:

- redundant upstream implementation fields
- transformation-only helper columns
- unsupported identifiers
- fields that encourage invalid cross-semantic calculations
- duplicated business logic
- unnecessary technical metadata

Required keys and additive components may remain exposed even when they are not intended for direct report presentation, because they may be required by the Power BI semantic model or reconciliation controls.

Final visibility, display folders, formatting, and user-facing field organization are owned by the downstream Power BI semantic model.

---

# 11. Business Naming Requirements

Serving datasets must use stable and understandable field names.

Naming must:

- preserve semantic distinctions
- distinguish transaction-date from session-attributed commercial measures
- avoid ambiguous customer terminology for GA4 pseudo-users
- remain consistent across serving datasets
- avoid report-specific presentation wording where possible

Business-readable naming must not obscure technically important semantic differences.

Final Power BI display names may be more presentation-oriented, but they must map unambiguously to governed serving fields.

---

# 12. Refresh Requirements

The current analytical dataset covers a bounded historical observation window.

The serving layer must support reliable refresh from its governed upstream dbt models.

TPower BI consumption uses Import mode, consistent with the bounded historical dataset and the approved refresh and performance strategy.

The serving layer must not introduce incremental processing solely for architectural appearance.

Incremental materialization or refresh should be introduced only when data volume, refresh duration, or operational requirements justify the additional complexity.

---

# 13. Performance Requirements

Serving models must be designed for efficient downstream BI consumption.

The design should:

- expose only required columns
- avoid unnecessary row multiplication
- avoid unnecessary joins at report query time
- preserve stable grains
- minimize duplicated transformations
- avoid rebuilding logic already materialized upstream
- consider BigQuery scan behavior
- consider Power BI Import size
- support predictable refresh behavior

Partitioning, clustering, incremental materialization, and other physical optimizations must be evidence-based rather than introduced by default.

---

# 14. dbt and Power BI Responsibility Boundary

## dbt Owns

dbt remains responsible for:

- governed analytical grains
- sessionization
- transaction identity and deduplication
- channel classification
- attribution logic
- governed KPI definitions
- governed rolling calculations
- governed Week-over-Week calculations
- business-mart logic
- executive KPI logic
- serving-model shaping
- data-quality and reconciliation controls

## Power BI Owns

Power BI is responsible for:

- semantic-model relationships
- measure presentation
- compatible period-level aggregation
- governed ratio recalculation where required
- formatting
- display names
- display folders
- hiding technical fields
- report filtering
- visual interactions
- navigation
- tooltips
- report-level presentation logic

Power BI must not become an alternative business-logic layer.

---

# 15. Serving Dataset Boundary Requirements

The final serving architecture must be driven by analytical purpose rather than by a requirement to create one serving table for every upstream model.

A serving model may:

- expose an upstream governed model with controlled shaping
- combine compatible fields where grain and semantics permit
- retain separate datasets where populations or analytical purposes differ
- provide BI-oriented dimensional interfaces

A serving model must not combine datasets merely because they share a date or dimension.

In particular, the executive headline/trend branch and session-attributed channel-driver branch must remain semantically distinguishable.

The approved P8B architecture implements five purpose-specific BI serving models aligned with the required analytical subject areas.

---

# 16. Unsupported Scope

The BI Serving Layer must not introduce unsupported metrics or analytical concepts including:

- net revenue
- ROAS
- customer acquisition cost
- cost per acquisition
- profit
- gross margin
- authenticated customer counts
- customer lifetime value
- production-grade customer retention
- multi-touch attribution
- paid-media attribution

Any future requirement for these metrics must be treated as a new analytics-engineering design change and must not be implemented ad hoc in Power BI.

---

# 17. Validation Requirements

Serving outputs are required to be validated for:

- declared grain
- uniqueness
- required-field nullability
- dimension-key integrity
- date coverage
- row-count behavior
- additive-measure reconciliation
- KPI reconciliation
- semantic-family preservation
- absence of unintended row multiplication
- schema consistency
- downstream consumption readiness

Serving reconciliation must compare only semantically compatible populations.

---

# 18. P8A Decision

The BI Serving Layer provides a controlled consumption boundary between governed dbt analytical outputs and the Power BI semantic model.

The serving architecture is organized around the analytical requirements of executive, acquisition, commerce, observed-user, and segment reporting rather than mechanically reproducing every upstream model.

Governed metric definitions and attribution semantics remain owned upstream.

Power BI consumes governed serving outputs and does not reconstruct core analytical logic.

The final serving-model architecture, including model count, grains, keys, dependencies, and field contracts, was defined in P8B — Serving Architecture & Model Contracts and implemented through five governed BI serving models.
