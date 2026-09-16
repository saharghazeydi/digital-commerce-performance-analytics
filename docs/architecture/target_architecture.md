# Target Architecture

## Purpose

This document defines the implemented analytical architecture of the Digital Commerce Performance Analytics project.

The architecture transforms raw GA4 ecommerce event data into governed analytical entities, reusable warehouse models, business-facing marts, executive KPI datasets, and Power BI reporting interfaces.

The design prioritizes analytical correctness, explicit model grains, governed KPI semantics, reconciliation between layers, and separation between transformation logic and presentation logic.

---

## End-to-End Architecture

    Google Analytics 4 Public Ecommerce Dataset
                        ↓
              BigQuery Source Tables
                        ↓
                 dbt Source Layer
                        ↓
                    Staging
             ┌─────────────────────┐
             │ stg_ga4__events     │
             │ stg_ga4__items      │
             └─────────────────────┘
                        ↓
                  Intermediate
        ┌───────────────────────────────┐
        │ int_ga4__session_events      │
        │ int_ga4__sessions            │
        │ int_ga4__transactions        │
        └───────────────────────────────┘
                        ↓
                 Core Warehouse
        ┌───────────────────────────────┐
        │ dim_date                      │
        │ dim_channel                   │
        │ fct_sessions                  │
        │ fct_transactions              │
        └───────────────────────────────┘
                        ↓
                  Business Marts
        ┌───────────────────────────────┐
        │ mart_channel_daily            │
        │ mart_ecommerce_daily          │
        │ mart_segment_daily            │
        │ mart_user_behavior            │
        └───────────────────────────────┘
                        ↓
                Executive KPI Layer
        ┌───────────────────────────────────┐
        │ executive_kpi_daily              │
        │ executive_kpi_trends_daily       │
        │ executive_channel_drivers_daily  │
        └───────────────────────────────────┘
                        ↓
                  BI Serving Layer
        ┌───────────────────────────────┐
        │ bi_executive_daily            │
        │ bi_channel_daily              │
        │ bi_commerce_daily             │
        │ bi_segment_daily              │
        │ bi_user_behavior              │
        └───────────────────────────────┘
                        ↓
              Power BI Semantic Model
                        ↓
              Four-Page Power BI Report

Each layer has a distinct responsibility and exposes governed outputs to the next analytical layer.

---

## Platform Responsibilities

### BigQuery

BigQuery provides the cloud analytical warehouse and execution environment for the project.

Responsibilities include:

- access to the public GA4 ecommerce source dataset;
- storage of dbt-generated analytical models;
- scalable SQL execution;
- model materialization;
- clustering where justified by model access patterns;
- source-to-model reconciliation; and
- governed analytical datasets consumed by downstream reporting.

The approved analytical source window is:

    2020-11-01 to 2021-01-31

Power BI does not query the raw GA4 event tables directly.

---

### dbt Core

dbt Core provides the transformation, dependency, testing, and analytical-governance framework.

Responsibilities include:

- modular SQL transformations;
- dependency management through `source()` and `ref()`;
- explicit model materializations;
- reusable transformation logic;
- generic and singular data tests;
- model and column documentation;
- business-rule enforcement;
- reconciliation between analytical layers; and
- dependency-aware project builds.

Business logic is implemented upstream in dbt wherever practical so that Power BI consumes governed reporting interfaces rather than reproducing transformation logic inside the report.

---

### Git and GitHub

Git and GitHub provide the repository development and review workflow.

Responsibilities include:

- source control;
- branch-based development;
- focused commits;
- reviewable Pull Requests;
- durable technical and business documentation;
- architecture decision records;
- validation evidence; and
- auditable project history.

Generated artifacts, local environments, credentials, and temporary analytical outputs are excluded from source control.

---

### Power BI

Power BI provides the semantic and presentation layer for business consumption.

Responsibilities include:

- semantic modeling;
- governed DAX measures;
- model relationships;
- report filtering and interaction;
- executive KPI presentation;
- analytical drill-down across commercial drivers; and
- presentation of approved business metrics.

The final report follows the analytical path:

    Overall Performance
        ↓
    Acquisition Drivers
        ↓
    Commerce Drivers
        ↓
    User & Segment Investigation

The report contains four pages:

1. Executive Overview
2. Acquisition & Channel Performance
3. Commerce Performance
4. Customer Behaviour & Segmentation

---

## Analytical Layers

### 1. Source Layer

The project uses the public Google Analytics 4 obfuscated ecommerce sample available in BigQuery.

The source is nested, event-based GA4 data and is treated as an external analytical source rather than copied into the repository.

Source definitions establish the controlled boundary between the public dataset and the dbt project.

---

### 2. Staging Layer

The staging layer creates source-aligned analytical representations while preserving source meaning.

Primary models:

- `stg_ga4__events`
- `stg_ga4__items`

Responsibilities include:

- bounded extraction from the approved source window;
- extraction of required nested GA4 parameters;
- typed scalar fields;
- standardized naming;
- event-level preservation;
- item-array expansion; and
- source-to-staging reconciliation.

Business KPI logic is intentionally excluded from this layer.

---

### 3. Intermediate Layer

The intermediate layer constructs reusable governed analytical entities from the staged event population.

Primary models:

- `int_ga4__session_events`
- `int_ga4__sessions`
- `int_ga4__transactions`

Responsibilities include:

- deterministic session identity;
- event sequencing within sessions;
- first-event and last-event logic;
- acquisition-signal selection;
- session-level behavioral aggregation;
- governed purchase identification;
- transaction identity;
- purchase-event deduplication; and
- session-to-transaction relationships.

This layer establishes the analytical foundations used by the warehouse and downstream marts.

---

### 4. Core Warehouse

The Core Warehouse exposes stable reusable dimensions and facts.

Primary models:

- `dim_date`
- `dim_channel`
- `fct_sessions`
- `fct_transactions`

Responsibilities include:

- governed date coverage;
- controlled business-facing channel classification;
- reusable session facts;
- reusable transaction facts;
- explicit fact grains;
- referential integrity; and
- reconciliation to the validated intermediate populations.

Channel classification is governed upstream rather than recreated independently in downstream reports.

---

### 5. Business Marts

Business marts expose reporting-oriented datasets at stable analytical grains.

Primary models:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`
- `mart_user_behavior`

Responsibilities include:

- channel-performance analysis;
- ecommerce-performance analysis;
- device and geographic segmentation;
- user-behavior analysis;
- governed business metrics; and
- stable downstream reporting interfaces.

The marts intentionally preserve different analytical populations and grains rather than forcing unrelated metrics into a single wide reporting table.

---

### 6. Executive KPI Layer

The executive layer provides governed KPI bases, trends, and performance-driver datasets.

Primary models:

- `executive_kpi_daily`
- `executive_kpi_trends_daily`
- `executive_channel_drivers_daily`

Responsibilities include:

- executive headline KPI preparation;
- additive KPI components;
- governed ratio semantics;
- rolling performance calculations;
- week-over-week comparison logic;
- channel contribution metrics; and
- reconciliation to business marts.

Ratio metrics are recalculated from additive components when aggregated across reporting periods rather than averaging daily ratios.

---

### 7. BI Serving Layer

The BI serving layer exposes stable reporting interfaces to Power BI.

Primary models:

- `bi_executive_daily`
- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_segment_daily`
- `bi_user_behavior`

These models are intentionally thin projections over governed upstream datasets.

The serving layer does not introduce new business logic. Its purpose is to provide stable, understandable, reporting-ready interfaces while protecting Power BI from unnecessary implementation complexity.

---

## Analytical Grain Strategy

The architecture deliberately maintains multiple grains because the project contains fundamentally different analytical entities.

Important grains include:

- event;
- event item;
- session;
- transaction;
- user;
- date × channel;
- date × device × country; and
- daily executive reporting.

Metrics are consumed only from models whose grain supports the intended analytical question.

This prevents invalid aggregation and accidental mixing of incompatible populations.

---

## Date and Revenue Semantics

The project explicitly separates different temporal interpretations of commercial activity.

### Session-Date Semantics

Used when performance is attributed to the date on which a governed session occurred.

This supports session-based acquisition and conversion analysis.

### Transaction-Date Semantics

Used when commercial activity is reported according to the date of the governed transaction.

This supports transaction volume, purchase revenue, and average order value reporting.

### Session-Cohort Semantics

Used when transaction outcomes are attributed back to the originating session population.

This supports metrics such as session-attributed revenue and revenue per session.

These semantics remain distinguishable throughout the analytical pipeline to prevent invalid KPI combinations.

---

## Channel Attribution Architecture

Raw GA4 acquisition attributes are not exposed directly as final business-facing channels.

Acquisition signals are evaluated during intermediate modeling and mapped into a controlled channel dimension in the Core Warehouse.

The governed channel groups are:

- Direct
- Organic Search
- Paid Search
- Referral
- Email
- Affiliate
- Other
- Unknown

The architecture distinguishes explicit direct traffic from missing or ambiguous acquisition information and preserves an `Unknown` category where attribution cannot be supported reliably.

Channel rules are defined upstream so that downstream marts and Power BI use one consistent classification.

---

## Data Quality and Reconciliation Architecture

Validation is treated as part of the analytical architecture rather than as a final reporting check.

Controls exist across the pipeline for:

- source date boundaries;
- model grain;
- uniqueness;
- critical null handling;
- accepted values;
- referential integrity;
- session construction;
- purchase consistency;
- transaction deduplication;
- monetary values;
- channel classification;
- business-mart reconciliation;
- executive KPI reconciliation; and
- BI-serving reconciliation.

Manual SQL validation supplements automated dbt testing where deeper distribution analysis or analytical investigation is required.

The final project-level dbt quality gate completed with:

- 13 table models;
- 8 view models;
- 367 data tests;
- 388 total selected nodes;
- 388 passed;
- 0 warnings;
- 0 errors; and
- 0 skipped nodes.

Power BI regression QA was subsequently completed against the governed serving outputs.

---

## Environment Strategy

The implemented workflow separates local development artifacts from governed cloud analytical outputs.

Local development includes:

- VS Code;
- a Python virtual environment used to run dbt Core;
- local dbt configuration; and
- Git-based source control.

BigQuery provides the cloud analytical execution and storage environment.

Environment-specific credentials and local configuration are not committed to the repository.

The repository provides `.env.example` as a non-secret configuration template.

This analytics project does not represent a continuously deployed production application and does not claim an automated production CI/CD environment.

---

## Security and Repository Principles

The repository follows these controls:

- credentials are never committed;
- `.env` files remain untracked;
- local dbt profiles remain untracked;
- Google Cloud credentials are stored outside the repository;
- `.venv/` remains local;
- `dbt_packages/`, `target/`, and `logs/` are generated locally and excluded from source control;
- raw datasets and local exports are excluded from source control; and
- Power BI temporary files are excluded from source control.

The public GA4 source data is queried from BigQuery rather than stored in the repository.

---

## BI Consumption Principle

Power BI consumes only governed analytical outputs.

The reporting flow is:

    Governed dbt Models
            ↓
      BI Serving Layer
            ↓
    Power BI Semantic Model
            ↓
       DAX Measures
            ↓
     Report Visualizations

Transformation and business-rule logic remains upstream wherever practical.

DAX is used for semantic calculations and report behavior rather than to reconstruct raw GA4 transformations.

---

## Implemented Architecture Status

The analytical architecture is fully implemented through the BI reporting layer.

Implemented components include:

- GA4 source definitions;
- staging models;
- intermediate session and transaction models;
- Core Warehouse dimensions and facts;
- business marts;
- executive KPI models;
- BI serving models;
- automated dbt quality controls;
- manual validation and reconciliation evidence;
- Power BI semantic modeling; and
- a four-page Power BI analytical report.

End-to-end validation through Phase 11 is complete.

Phase 12 packages the implemented architecture, validation evidence, dashboard assets, reproducibility guidance, and project narrative for project documentation and release
