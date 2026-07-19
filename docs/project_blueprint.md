# Project Blueprint

## Project Name

Digital Commerce Performance Analytics

## Business Objective

Build a production-oriented analytics solution that transforms raw GA4 ecommerce event data into tested, documented, and business-ready datasets for acquisition, customer journey, conversion, and revenue analysis.

## Primary Users

- Commercial and marketing managers
- Growth and acquisition teams
- Ecommerce stakeholders
- Data analysts
- BI developers

## Core Business Questions

1. Which acquisition channels generate the highest-quality traffic?
2. Where do users drop out of the ecommerce funnel?
3. Which channels contribute most to conversions and revenue?
4. How do sessions, conversion rate, transactions, and revenue change over time?
5. Are business KPIs reliable and reconciled across the analytics and BI layers?

## Technology Stack

- Google BigQuery
- dbt Core
- SQL
- Python
- Git and GitHub
- VS Code
- Power BI

## High-Level Architecture

GA4 public ecommerce data  
→ BigQuery raw source  
→ dbt staging models  
→ dbt intermediate models  
→ dimensions and facts  
→ business marts  
→ BI serving layer  
→ Power BI semantic model and dashboards

## Analytics Layers

### Source Layer

Raw GA4 public ecommerce event tables stored in BigQuery.

### Staging Layer

Source-aligned models used to:

- extract nested GA4 parameters
- standardize field names
- cast data types
- create technical identifiers
- preserve source meaning
- apply limited cleaning

### Intermediate Layer

Reusable transformation models used to:

- construct sessions
- prepare funnel events
- deduplicate transactions
- normalize acquisition channels
- resolve reusable business logic

### Core Warehouse Layer

Conformed dimensions and fact models with clearly defined grains.

### Business Mart Layer

Business-facing models for:

- channel performance
- funnel performance
- commercial performance
- engagement performance
- daily trends

### BI Serving Layer

Power BI-ready models containing stable dimensions, measures, and reporting grains.

## Development Principles

- Every model must have a clearly documented grain.
- SQL logic must be modular and reusable.
- Source fields must not be renamed without business justification.
- Final models must not use SELECT *.
- KPI definitions must exist in one authoritative layer.
- Revenue must be reconciled against source data.
- Row multiplication must be explicitly tested.
- Models must be documented alongside the code.
- Tests must cover technical quality and business logic.
- Power BI must consume only approved BI serving models.

## Testing Strategy

### Generic dbt Tests

- not_null
- unique
- relationships
- accepted_values

### Singular Business Tests

- session grain uniqueness
- transaction revenue reconciliation
- no invalid funnel sequence totals
- no negative transaction counts
- conversion counts do not exceed session counts
- BI model totals reconcile with upstream marts

## Materialization Strategy

- Sources: external BigQuery tables
- Staging: views
- Intermediate: views or ephemeral models based on reuse and cost
- Dimensions: tables
- Facts: partitioned tables where appropriate
- Business marts: tables
- BI serving models: views or tables based on Power BI performance requirements

## BigQuery Dataset Strategy

Planned logical datasets:

- raw source dataset: external public GA4 dataset
- development dataset: dbt developer models
- analytics dataset: approved warehouse and mart models
- BI dataset: Power BI serving models

Exact dataset names will be finalized during environment configuration.

## Git Workflow

- main: stable and reviewed project state
- feature branches: one branch per development phase or logical change
- small, meaningful commits
- no direct development on main after project initialization
- pull request-style review before merging feature work

## Commit Convention

Examples:

- feat: add GA4 source definitions
- feat: build session fact model
- test: add revenue reconciliation test
- docs: document channel attribution logic
- refactor: simplify session construction logic
- fix: prevent duplicate transaction revenue
- chore: configure dbt project settings

## Documentation Deliverables

- README.md
- project blueprint
- architecture documentation
- project tracker
- KPI dictionary
- data dictionary
- data-quality documentation
- decision log
- dbt model and column documentation
- Power BI model documentation

## Dashboard Scope

1. Executive Overview
2. Acquisition and Channel Performance
3. Customer Journey and Conversion Funnel
4. Ecommerce Revenue Performance

## Out of Scope

- unrelated external datasets
- cross-domain row-level data integration
- complex workflow orchestration
- machine-learning models without a defined business requirement
- infrastructure that does not support the analytics use case
- real-time streaming or production application development