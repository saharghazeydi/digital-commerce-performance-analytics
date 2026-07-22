# Project Blueprint

## Project Name

Digital Commerce Performance Analytics

---

## Business Objective

Build a production-oriented analytics engineering solution that transforms raw GA4 ecommerce event data into tested, documented, governed, and business-ready analytical models for acquisition, customer behaviour, conversion, and revenue analysis.

---

## Target Audience

Primary consumers of this project include:

- Commercial managers
- Marketing managers
- Growth and acquisition teams
- Ecommerce stakeholders
- Data analysts
- BI developers

---

## Business Objectives

The analytical platform should enable stakeholders to answer the following business questions:

1. Which acquisition channels generate the highest-quality traffic?
2. Where do users leave the ecommerce journey before converting?
3. Which channels contribute most to transactions and revenue?
4. How do sessions, conversion rate, transactions, and revenue evolve over time?
5. Can executive KPIs be trusted across every analytical layer?

---

## Technology Stack

| Layer | Technology |
|---|---|
| Cloud Data Warehouse | Google BigQuery |
| Transformation Framework | dbt Core |
| Query Language | SQL |
| Supporting Scripts | Python |
| Version Control | Git |
| Repository Hosting | GitHub |
| Development Environment | VS Code |
| Business Intelligence | Power BI |

---

## High-Level Architecture

```text
GA4 Public Ecommerce Dataset
            │
            ▼
BigQuery Source Layer
            │
            ▼
dbt Source Definitions
            │
            ▼
dbt Staging Layer
            │
            ▼
dbt Intermediate Layer
            │
            ▼
Core Warehouse
(Dimensions & Facts)
            │
            ▼
Business Marts
            │
            ▼
BI Serving Layer
            │
            ▼
Power BI Semantic Model
            │
            ▼
Executive Dashboards
```

---

# Analytics Architecture

## Source Layer

Raw GA4 public ecommerce tables stored in BigQuery.

Responsibilities:

- preserve source data
- define source metadata
- provide traceability to upstream tables

---

## Staging Layer

Source-aligned transformation models responsible for:

- extracting nested GA4 parameters
- standardizing naming conventions
- casting data types
- generating technical identifiers
- preserving source semantics
- applying minimal cleaning only

---

## Intermediate Layer

Reusable transformation models responsible for:

- session construction
- funnel-event preparation
- transaction deduplication
- acquisition normalization
- reusable business transformations

---

## Core Warehouse Layer

Business-independent analytical warehouse consisting of:

- conformed dimensions
- governed fact tables
- documented grains
- reusable analytical entities

---

## Business Mart Layer

Business-facing analytical models supporting:

- acquisition performance
- funnel performance
- commercial performance
- customer behaviour
- engagement analysis
- time-series reporting

---

## BI Serving Layer

Presentation-ready models optimized for Power BI.

Responsibilities:

- business-readable naming
- stable reporting grains
- optimized query performance
- governed KPI exposure

---

# Development Principles

The project follows the following engineering principles.

- Every model must have a documented grain.
- SQL transformations must remain modular.
- Business logic must be reusable.
- Source columns must not be renamed without business justification.
- Final analytical models must never use `SELECT *`.
- KPI definitions must exist in one authoritative layer.
- Revenue must reconcile with source data.
- Grain changes must be explicitly documented.
- Row multiplication must be tested.
- Models must be documented together with the code.
- Testing must include technical integrity and business validation.
- Power BI may consume only approved BI serving models.

---

# Testing Strategy

## Generic dbt Tests

- not_null
- unique
- relationships
- accepted_values

## Business Validation Tests

- session grain uniqueness
- transaction revenue reconciliation
- funnel sequence validation
- transaction count validation
- conversion counts do not exceed session counts
- BI totals reconcile with upstream marts

---

# Materialization Strategy

| Layer | Materialization |
|---|---|
| Sources | External BigQuery tables |
| Staging | Views |
| Intermediate | Views or Ephemeral |
| Dimensions | Tables |
| Facts | Partitioned Tables where appropriate |
| Business Marts | Tables |
| BI Serving | Views or Tables depending on reporting performance |

---

# BigQuery Dataset Strategy

Planned logical datasets include:

| Dataset Purpose | Description |
|---|---|
| Source | External GA4 public dataset |
| Development | dbt developer workspace |
| Analytics | Approved warehouse and business marts |
| BI | Power BI serving models |

Exact dataset names will be finalized during environment configuration.

---

# Git Workflow

Development follows an enterprise feature-branch workflow.

- `main` always represents the latest reviewed project state.
- Every logical change uses a dedicated feature branch.
- Commits remain small and focused.
- Direct development on `main` is prohibited.
- Every feature is reviewed through a Pull Request before merge.

---

# Commit Convention

Examples:

```text
feat: add GA4 source definitions
feat: build session fact model
test: add revenue reconciliation test
docs: document channel attribution
refactor: simplify session construction
fix: prevent duplicate transaction revenue
chore: configure dbt project
```

---

# Documentation Deliverables

The completed repository will include:

- README
- Project Blueprint
- Project Tracker
- Phase Checkpoints
- Architecture Documentation
- KPI Dictionary
- Data Dictionary
- Data Quality Documentation
- Architecture Decision Records
- dbt Model Documentation
- Power BI Model Documentation

---

# Dashboard Scope

The Power BI solution will contain:

1. Executive Overview
2. Acquisition & Channel Performance
3. Customer Journey & Conversion Funnel
4. Revenue & Commercial Performance

---

# Out of Scope

The following items are intentionally excluded.

- unrelated external datasets
- cross-domain row-level integration
- workflow orchestration platforms
- machine learning without a defined business requirement
- infrastructure unrelated to analytical delivery
- real-time streaming pipelines
- production application development
