# Target Architecture

## Purpose

This document defines the intended technical architecture of the Digital Commerce Performance Analytics project before implementation begins.

## Data Flow

1. GA4 public ecommerce event data
2. BigQuery public source tables
3. dbt source definitions
4. staging models
5. intermediate transformation models
6. core analytical models
7. business marts
8. BI serving models
9. Power BI semantic model
10. business dashboards

## Platform Responsibilities

### BigQuery

BigQuery provides:

- access to the raw GA4 public ecommerce dataset
- scalable SQL execution
- storage for development and analytical models
- partitioning and clustering where justified
- source-to-output reconciliation

### dbt Core

dbt provides:

- modular SQL transformations
- dependency management through `source()` and `ref()`
- model materialization
- generic and singular tests
- model and column documentation
- lineage visibility
- repeatable local development workflows

### Git and GitHub

Git and GitHub provide:

- source control
- branch-based development
- reviewable pull requests
- auditable project history
- documentation and code collaboration standards

### Power BI

Power BI provides:

- semantic modeling
- DAX measures
- report-level filtering and interaction
- executive and analytical dashboards
- presentation of approved business metrics

## Planned dbt Model Layers

The directories below will be generated and configured after `dbt init`.

### Staging

Purpose:

- create source-aligned models
- extract nested GA4 parameters
- standardize naming and data types
- apply limited cleaning
- retain source meaning

Expected naming:

```text
stg_ga4__events

Intermediate

Purpose:

create reusable transformation logic
construct sessions
deduplicate transactions
normalize channels
prepare funnel and engagement logic

Expected naming:

int_ga4__sessions
int_ga4__transactions
int_ga4__funnel_events
Marts

Purpose:

deliver business-facing analytical models
organize dimensions, facts, and reporting marts
centralize KPI definitions

Potential subject areas:

marts/core
marts/marketing
marts/commercial
marts/bi

The exact mart structure will be finalized after GA4 source profiling.

Environment Strategy

Planned environments:

local development environment
BigQuery development dataset
approved analytics dataset
Power BI serving dataset or approved BI models

Production deployment is represented through controlled, approved analytical layers rather than an operational application environment.

Security Principles
credentials must never be committed
.env and local dbt profiles remain untracked
.env.example contains placeholders only
Google credentials are stored outside the repository
generated dbt artifacts are excluded from source control
Data Quality Principles

Quality controls will include:

source accessibility checks
grain uniqueness tests
not-null tests on critical identifiers
accepted-value tests
relationship tests
revenue reconciliation
session and transaction deduplication checks
funnel consistency checks
BI-to-mart reconciliation
BI Consumption Principle

Power BI will not query raw GA4 event tables directly.

Power BI will consume only approved BI serving models or stable analytical marts created through dbt.

Deferred Decisions

The following decisions require source profiling or environment setup:

exact BigQuery dataset names
table versus view materializations
incremental model requirements
partitioning and clustering fields
final mart subject-area structure
Power BI import model table selection