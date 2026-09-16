# Project Blueprint

## Project Name

Digital Commerce Performance Analytics

---

## Purpose

Digital Commerce Performance Analytics is an end-to-end analytics engineering and business intelligence solution built on the Google Analytics 4 public ecommerce dataset.

The project transforms raw GA4 event data into governed analytical entities, warehouse models, business marts, executive KPI datasets, Power BI serving interfaces, and a validated four-page business intelligence report.

The implementation emphasizes explicit analytical grains, reusable business logic, governed KPI semantics, source-to-report reconciliation, reproducibility, and clear separation between transformation and presentation responsibilities.

---

## Business Objective

Provide a trusted analytical foundation for understanding ecommerce acquisition, observed user behaviour, conversion, transactions, revenue, and commercial performance.

The solution is designed to enable business stakeholders to move from high-level performance monitoring into channel, commerce, user-behaviour, and segment-level investigation without redefining KPI logic inside the reporting layer.

---

## Target Consumers

The analytical outputs are relevant to:

- commercial and ecommerce stakeholders
- marketing and acquisition teams
- growth teams
- business and data analysts
- BI developers
- analytics engineers
- business decision-makers using executive performance reporting

---

## Business Questions

The implemented analytical solution supports questions including:

1. How are sessions, purchasing sessions, conversion, transactions, revenue, and average order value performing over time?
2. Which acquisition channels drive traffic, conversion, revenue contribution, and revenue per session?
3. How does commerce performance change across revenue, transactions, average order value, and items per transaction?
4. How do observed users, purchasing users, multi-session users, and repeat purchasing-session users behave?
5. How does performance vary across device and geographic segments?
6. Which changes in executive KPIs are visible through rolling and period-over-period trends?
7. Can business-facing metrics be reconciled consistently from source-aligned transformations through the BI serving and reporting layers?

---

## Technology Stack

| Responsibility | Technology |
|---|---|
| Cloud Data Warehouse | Google BigQuery |
| Transformation and Modeling | dbt Core |
| Query and Transformation Language | SQL |
| Development Runtime | Python 3.11 |
| Version Control | Git |
| Repository Hosting and Review | GitHub |
| Development Environment | VS Code |
| Business Intelligence | Power BI |

Python provides the local runtime required by dbt Core. The implemented analytical transformation logic is SQL/dbt-based; the project does not depend on a separate Python analytics or automation layer.

---

# Implemented Architecture

## End-to-End Analytical Flow

    Google Analytics 4 Public Ecommerce Dataset
                    ↓
            BigQuery Source Tables
                    ↓
             dbt Source Layer
                    ↓
                Staging
        stg_ga4__events
        stg_ga4__items
                    ↓
              Intermediate
        int_ga4__session_events
        int_ga4__sessions
        int_ga4__transactions
                    ↓
             Core Warehouse
        dim_date
        dim_channel
        fct_sessions
        fct_transactions
                    ↓
             Business Marts
        mart_channel_daily
        mart_ecommerce_daily
        mart_segment_daily
        mart_user_behavior
                    ↓
          Executive KPI Layer
        executive_kpi_daily
        executive_kpi_trends_daily
        executive_channel_drivers_daily
                    ↓
            BI Serving Layer
        bi_executive_daily
        bi_channel_daily
        bi_commerce_daily
        bi_segment_daily
        bi_user_behavior
                    ↓
         Power BI Semantic Model
                    ↓
          Four-Page Power BI Report

Detailed architecture documentation is maintained in `docs/architecture/target_architecture.md`.

---

# Analytical Layer Responsibilities

## Source Layer

The source layer references the public GA4 ecommerce daily event tables in BigQuery.

Responsibilities include:

- source declaration and metadata
- upstream traceability
- controlled access to the approved source window
- preservation of source ownership outside the transformation project

The repository does not store raw GA4 source data.

---

## Staging Layer

The staging layer provides source-aligned event- and item-grain representations.

Responsibilities include:

- bounded extraction from GA4 daily shards
- nested parameter extraction
- source-aligned field naming and typing
- event- and item-grain preservation
- minimal normalization required for downstream modeling

Implemented models:

- `stg_ga4__events`
- `stg_ga4__items`

---

## Intermediate Layer

The intermediate layer constructs reusable governed analytical entities and shared transformation logic.

Responsibilities include:

- deterministic session identity
- event sequencing
- session construction
- acquisition selection
- landing-page and session attributes
- transaction normalization
- purchase deduplication
- transaction construction
- reusable commercial and behavioural transformations

Implemented models:

- `int_ga4__session_events`
- `int_ga4__sessions`
- `int_ga4__transactions`

---

## Core Warehouse Layer

The Core Warehouse exposes stable analytical facts and dimensions with explicit grains and tested relationships.

Implemented dimensions:

- `dim_date`
- `dim_channel`

Implemented facts:

- `fct_sessions`
- `fct_transactions`

The warehouse preserves governed session and transaction identities while providing reusable relationships for downstream analytical models.

---

## Business Mart Layer

The business mart layer organizes governed metrics around analytical domains and downstream decision needs.

Implemented models:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`
- `mart_user_behavior`

The marts support:

- acquisition and channel performance
- ecommerce and commercial performance
- observed user behaviour
- device and geographic segmentation
- time-series analysis
- downstream executive and BI consumption

Metric semantics explicitly distinguish session-date, transaction-date, and session-cohort calculations where required.

---

## Executive KPI Layer

The executive layer provides controlled leadership-level KPI datasets on top of the governed business marts.

Implemented models:

- `executive_kpi_daily`
- `executive_kpi_trends_daily`
- `executive_channel_drivers_daily`

Responsibilities include:

- executive KPI calculation
- rolling performance trends
- period-over-period comparisons
- channel contribution metrics
- preservation of governed date semantics
- controlled downstream KPI exposure

---

## BI Serving Layer

The BI serving layer provides stable, business-readable interfaces for Power BI.

Implemented models:

- `bi_executive_daily`
- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_segment_daily`
- `bi_user_behavior`

The serving models are intentionally thin projections of governed upstream models. Business logic is not independently reimplemented in the serving layer.

---

# Analytical Grain Strategy

Grain is treated as an explicit model contract throughout the project.

Key analytical grains include:

| Entity or Model | Governed Grain |
|---|---|
| Staged events | GA4 event grain |
| Staged items | Event × item offset |
| Sessions | One row per governed session |
| Transactions | One row per valid governed transaction |
| Channel mart | Session date × channel |
| Ecommerce mart | Daily analytical output with explicit date semantics |
| Segment mart | Session date × device category × country |
| User behaviour mart | One row per observed pseudo-user |
| Executive KPI base | Daily executive KPI grain |
| Channel drivers | Date × channel |

Grain changes are documented and tested. Aggregations that could introduce fact-to-fact fanout or row multiplication are intentionally avoided.

---

# KPI Governance

Business KPIs are defined upstream of Power BI and reconciled across analytical layers.

Core governed metrics include:

- Sessions
- Purchasing Sessions
- Conversion Rate
- Transactions
- Purchase Revenue
- Average Order Value
- Items per Transaction
- Revenue per Session
- Observed Users
- Purchasing Users
- Multi-Session Users
- Repeat Purchasing Session Users

Representative formulas include:

    Conversion Rate =
    Purchasing Sessions / Sessions

    Average Order Value =
    Purchase Revenue / Transactions

    Revenue per Session =
    Session-Attributed Purchase Revenue / Sessions

Ratio metrics are recalculated from their additive components at the required reporting context rather than averaged across precomputed ratios.

Detailed KPI definitions and semantic contracts are maintained under:

    digital_commerce_performance_analytics/docs/business_requirements/

---

# Channel Attribution

Channel classification is governed upstream of the BI layer.

The implemented channel framework includes:

- Direct
- Organic Search
- Paid Search
- Referral
- Email
- Affiliate
- Other
- Unknown

The attribution logic distinguishes explicit acquisition information from missing acquisition data and uses first-event referrer context where required.

External referrer URLs are not automatically classified as Organic Search solely because the referring domain is a search engine.

Detailed channel and acquisition logic is maintained in the technical and business model documentation.

---

# Date and Revenue Semantics

The project explicitly separates analytical date concepts to prevent semantic mixing.

Depending on the analytical question, metrics may use:

- session date
- transaction date
- session-cohort attribution

Transaction-date revenue is used for commerce reporting.

Session-attributed revenue is used where commercial outcomes are intentionally associated with the originating session or channel.

Mixed-date ratios are not constructed by combining incompatible metric families.

---

# Development Principles

The implementation follows these principles:

- every analytical model has an explicit grain
- transformations remain modular and dependency-driven
- reusable business logic is implemented upstream of presentation
- source semantics are preserved until a governed transformation requires change
- final analytical models avoid uncontrolled `SELECT *`
- KPI definitions have explicit semantic ownership
- session and transaction identities are deterministic
- revenue and transaction metrics are reconciled across layers
- row multiplication and referential-integrity risks are tested
- model documentation evolves with implementation
- technical tests are complemented by business reconciliation
- Power BI consumes approved BI-serving interfaces
- presentation logic does not redefine governed warehouse semantics
- additional optimization is introduced only when supported by measured need

---

# Testing and Validation Strategy

Validation combines automated dbt controls with targeted reconciliation.

## Generic dbt Controls

Implemented generic tests include:

- `not_null`
- `unique`
- `relationships`
- `accepted_values`

## Business and Reconciliation Controls

Project-specific validation covers areas including:

- source-to-staging row reconciliation
- session grain and deterministic identity
- transaction uniqueness and deduplication
- session-to-transaction relationships
- purchase and revenue reconciliation
- channel classification
- date coverage
- business-mart reconciliation
- executive KPI reconciliation
- BI-serving-to-upstream reconciliation
- Power BI totals and semantic behaviour

The final Phase 11 quality gate validated:

- 21 dbt models
- 367 data tests
- 388 successful dbt resources
- 0 warnings
- 0 errors
- 0 skipped resources

Detailed validation evidence is maintained under `validation/`.

---

# Materialization Strategy

Materialization decisions were based on model responsibility and measured project scale rather than applying optimization patterns by default.

The implemented project uses a combination of dbt views and tables.

Key principles include:

- lightweight source-aligned staging models use views
- reusable analytical entities are materialized according to their downstream role and measured workload
- governed warehouse and analytical outputs use persistent tables where appropriate
- partitioning, clustering, and incremental strategies are not introduced without evidence that they improve the current workload
- BI serving models remain thin interfaces over governed upstream models

The project deliberately avoids claiming optimization mechanisms that were not required by the measured data volume and reporting workload.

---

# BigQuery Environment Strategy

The source is the public BigQuery dataset:

    bigquery-public-data.ga4_obfuscated_sample_ecommerce

The governed analytical window is:

    2020-11-01 through 2021-01-31

The source contains 92 daily shards across this period.

The validated development environment used:

    Google Cloud project: digital-commerce-analytics
    dbt development dataset: analytics_dev
    BigQuery location: US

The local dbt target uses OAuth authentication.

Machine-specific `profiles.yml` configuration and credentials are intentionally excluded from version control.

A reproducing user may execute the project using a different Google Cloud project and development dataset while preserving the required source location and dbt configuration.

Environment and execution instructions are documented in:

    docs/project_management/reproduction_guide.md

---

# Repository and Delivery Workflow

Development follows a feature-branch and Pull Request workflow.

Key controls include:

- `main` represents the latest reviewed and accepted project state
- direct development on `main` is avoided
- logical implementation or release changes are developed on dedicated branches
- commits are kept coherent and reviewable
- Pull Requests document purpose, changes, validation, risks, and limitations
- applicable quality checks are completed before merge
- generated artifacts, credentials, virtual environments, and local runtime files are excluded from version control

Detailed operating standards are documented in:

    docs/project_management/development_workflow.md

---

# Documentation Structure

The repository maintains documentation according to responsibility.

Key documentation areas include:

- root `README.md` — project overview and primary repository entry point
- `docs/project_blueprint.md` — project scope, architecture, and implementation principles
- `docs/architecture/` — architecture and extraction contracts
- `docs/decisions/` — architectural and technical decision records
- `docs/data_quality/` — durable source-quality assessment
- `docs/project_management/` — delivery history, checkpoints, workflow, and reproduction guidance
- `digital_commerce_performance_analytics/docs/business_requirements/` — KPI and BI business contracts
- `digital_commerce_performance_analytics/docs/technical_design/` — implementation and model-design documentation
- `validation/` — executable and documented validation evidence
- `power_bi/documentation/` — semantic-model and report documentation
- `power_bi/assets/` — approved report screenshots

Architecture visuals are maintained under:

    docs/architecture/assets/

---

# Power BI Solution

The final Power BI report contains four analytical pages:

1. Executive Overview
2. Acquisition & Channel Performance
3. Commerce Performance
4. Customer Behaviour & Segmentation

The analytical flow is:

    Overall Performance
            ↓
    Acquisition Drivers
            ↓
    Commerce Drivers
            ↓
    User and Segment Investigation

The canonical Power BI artifact is:

    power_bi/digital_commerce_performance_analytics.pbix

The Power BI semantic model consumes governed BI-serving datasets using Import mode.

The presentation layer provides business-facing measures, relationships, formatting, filtering, and report interaction while respecting the analytical semantics established upstream.

---

# Validated Analytical Baseline

For the governed source window, the final implementation reconciles to the following headline results:

| Metric | Validated Result |
|---|---:|
| Sessions | 360,129 |
| Purchasing Sessions | 4,033 |
| Conversion Rate | 1.12% |
| Transactions | 4,451 |
| Purchase Revenue | approximately $307.64K |
| Average Order Value | $69.12 |
| Observed Users | 270,154 |
| Purchasing Users | 3,702 |

These values are validation reference points for the approved source window and implemented analytical definitions, not general characteristics of ecommerce performance.

---

# Scope Boundaries and Limitations

The project intentionally does not claim analytical capabilities unsupported by the available source data.

Out of scope or source-constrained areas include:

- profitability and margin analysis
- customer acquisition cost
- return on advertising spend
- customer lifetime value
- formal churn modeling
- authenticated cross-device customer identity
- formal retention analysis requiring stronger customer identity
- unsupported multi-touch attribution
- unrelated external datasets
- machine learning without a defined business requirement
- real-time streaming
- workflow orchestration infrastructure
- production application development

User-level analysis uses GA4 pseudo-user identifiers and therefore represents observed browser/device-level user identity rather than authenticated customer identity.

The source is a static, obfuscated public ecommerce sample covering approximately three months. Findings should therefore be interpreted within that analytical context.

---

# Release Standard

The project is considered complete when:

- transformation and analytical layers are implemented
- model grains and business semantics are documented
- source-to-report reconciliation has passed
- the complete dbt quality gate passes
- Power BI semantic and report QA is complete
- repository documentation reflects the implemented state
- reproduction guidance is available
- final architecture and Power BI report assets are present
- generated and local artifacts are excluded
- final repository QA passes
- release changes are reviewed and merged through the established Pull Request workflow

Completion of the final documentation and release phase closes the current project scope. Any future analytical enhancement should be opened as a separately approved scope rather than treated as unfinished work from the current implementation.