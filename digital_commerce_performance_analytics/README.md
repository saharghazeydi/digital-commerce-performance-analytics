# Digital Commerce Performance Analytics — dbt Project

This directory contains the dbt transformation and validation layer for the Digital Commerce Performance Analytics project.

The dbt project transforms raw Google Analytics 4 ecommerce event data into governed analytical models for session, transaction, channel, commerce, customer-behaviour, executive KPI, and Power BI reporting use cases.

## Project Scope

The dbt layer is responsible for:

- extracting and standardizing GA4 event and item data;
- reconstructing session-level analytical entities;
- defining deterministic session and transaction identities;
- applying governed acquisition-channel classification;
- building reusable core warehouse models;
- producing business and executive analytical marts;
- exposing thin, reporting-ready serving models for Power BI;
- enforcing data contracts, grain expectations, accepted values, uniqueness, referential integrity, and reconciliation controls.

Business logic is intentionally implemented upstream of Power BI so that KPI definitions and analytical rules remain centralized and auditable.

## Source Data

The project uses the public GA4 ecommerce sample dataset:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce`

The approved analytical window is:

`2020-11-01` through `2021-01-31`

The source contains obfuscated ecommerce event data and does not provide an authenticated business-level customer identifier. User-level analysis therefore relies on the available GA4 pseudo-user identifier and is described accordingly.

Raw source data is queried from BigQuery and is not stored in this repository.

## Model Architecture

The transformation flow is:

    GA4 source
        ↓
    staging
        ↓
    intermediate
        ↓
    core warehouse
        ↓
    business / executive marts
        ↓
    BI serving layer
        ↓
    Power BI semantic model and report

### Staging

Location:

`models/staging/ga4/`

The staging layer performs bounded source extraction, typed field extraction, event normalization, and preservation of source-level analytical fields.

Primary models include:

- `stg_ga4__events`
- `stg_ga4__items`

### Intermediate

Location:

`models/intermediate/ga4/`

The intermediate layer reconstructs reusable analytical entities and applies transformation logic that should not be duplicated across downstream marts.

Primary models include:

- `int_ga4__events_base`
- `int_ga4__sessions`
- `int_ga4__transactions`

Session reconstruction includes deterministic session identity, acquisition inputs, landing-page referrer context, device category, country, and session-level behavioural and commercial attributes.

### Core Warehouse

Location:

`models/marts/core/`

The core warehouse establishes governed analytical facts and dimensions used by downstream business models.

Primary models include:

- `fct_sessions`
- `fct_transactions`
- `dim_channel`
- `dim_date`

The core layer owns stable analytical grains and reusable dimensions rather than report-specific presentation logic.

### Business Marts

Location:

`models/marts/business/`

Business marts provide governed analytical datasets for channel, commerce, observed user behaviour, and segmentation analysis.

Primary models include:

- `mart_channel_daily`
- `mart_ecommerce_daily`
- `mart_segment_daily`
- `mart_user_behavior`

Each model has an explicit grain. Measures must only be aggregated in ways supported by that grain.

In particular, `mart_segment_daily` is modeled at:

`date × device_category × country`

It does not contain additive user metrics.

### Executive Mart

Location:

`models/marts/executive/`

The executive layer provides governed KPI outputs for executive performance reporting.

Primary model:

- `mart_executive_daily`

This layer centralizes the daily KPI framework used for executive reporting and downstream BI consumption.

### BI Serving Layer

Location:

`models/marts/serving/`

The serving layer exposes thin projections of governed upstream models for Power BI.

Serving models include:

- `bi_channel_daily`
- `bi_commerce_daily`
- `bi_executive_daily`
- `bi_segment_daily`
- `bi_user_behavior`

Business definitions are not independently reimplemented in the serving layer. This keeps the BI interface aligned with the governed warehouse logic.

## Governed Analytical Rules

### Session Identity

Sessions use a deterministic identity derived from the available GA4 pseudo-user identifier and session identifier.

This prevents session counts from depending on event-level row counts and provides a stable grain for session analysis.

### Transaction Identity

Transaction-level analysis uses the available ecommerce transaction identifier with explicit deduplication logic before transaction metrics are exposed downstream.

### Channel Attribution

Channel classification follows the governed acquisition hierarchy implemented in the project.

Key distinctions include:

- explicit direct traffic is classified as `Direct`;
- organic acquisition is classified as `Organic Search`;
- CPC traffic is classified as `Paid Search`;
- referral traffic is classified as `Referral`;
- email traffic is classified as `Email`;
- affiliate traffic is classified as `Affiliate`;
- populated but otherwise unmapped media are classified as `Other`;
- deleted acquisition values are classified as `Unknown`;
- sessions without usable acquisition data use first-event referrer context to distinguish direct/internal navigation from unresolved external acquisition.

An external Google redirect URL is not sufficient on its own to classify a session as organic traffic.

### Date Semantics

Session, transaction, and reporting dates are kept semantically explicit.

Downstream models do not silently substitute one business date definition for another.

## Data Quality and Validation

Testing is part of the analytical architecture rather than a separate cleanup step.

The project includes:

- schema and contract tests;
- not-null checks;
- uniqueness checks;
- accepted-value checks;
- relationship tests;
- grain validation;
- source-to-staging reconciliation;
- intermediate-to-core reconciliation;
- serving-layer reconciliation;
- business-rule assertions.

The final release quality gate completed successfully with:

    13 table models
    8 view models
    367 data tests
    388 total selected resources

    PASS=388
    WARN=0
    ERROR=0
    SKIP=0
    TOTAL=388

Historical validation evidence from earlier delivery phases is retained separately and may therefore show the test counts that were valid at those checkpoints.

## Running the dbt Project

### Prerequisites

The validated environment uses:

- Python 3.11
- dbt Core 1.12.0
- dbt-bigquery 1.12.0
- Google BigQuery
- authenticated access to the development GCP project

Install the repository dependencies from the repository root:

    pip install -r requirements.txt

The repository pins:

    dbt-bigquery==1.12.0

### dbt Profile

The dbt project expects a local dbt profile named:

`digital_commerce_performance_analytics`

The validated development configuration uses:

- GCP project: `digital-commerce-analytics`
- development dataset: `analytics_dev`
- BigQuery location: `US`

Authentication credentials and local dbt profiles are environment-specific and are not committed to the repository.

### Validate the Connection

From this directory:

    dbt debug

### Parse the Project

    dbt parse

### Build and Test

Run the complete transformation and quality gate with:

    dbt build

A successful build creates the modeled analytical layers and executes the associated dbt tests.

## Project Configuration

The main dbt configuration is defined in:

`dbt_project.yml`

The project contains only paths used by the implemented analytical workflow. Generated dbt artifacts and local dependencies, including `target/`, `logs/`, and `dbt_packages/`, are excluded from version control.

## Supporting Documentation

Detailed requirements, model contracts, and technical designs are maintained within this dbt project:

`docs/business_requirements/`

`docs/technical_design/`

Repository-level architecture, project management, reproduction, validation, and Power BI documentation are maintained outside this dbt directory.

For full environment setup and end-to-end execution instructions, see:

`../docs/project_management/reproduction_guide.md`

For the implemented analytical architecture, see:

`../docs/architecture/target_architecture.md`

For validation evidence, see:

`../validation/README.md`

For the overall project narrative and repository map, see:

`../README.md`

## Implementation Status

The dbt transformation layer is complete for the current project scope.

The implemented pipeline covers source extraction, staging, session and transaction reconstruction, governed warehouse models, business and executive marts, BI serving models, and project-level validation. The final release build passes all 388 selected dbt resources with zero warnings, errors, or skipped nodes.