# ADR-001 — Use dbt Core with BigQuery

## Status

Accepted

## Context

The project requires a maintainable transformation workflow for GA4 ecommerce event data. SQL models must be modular, tested, documented, version-controlled, and suitable for downstream Power BI reporting.

Managing all transformations as manually executed BigQuery scripts would make dependency order, testing, lineage, and documentation harder to maintain as the project grows.

## Decision

Use:

- BigQuery as the analytical warehouse
- dbt Core as the SQL transformation, testing, and documentation framework
- the dbt BigQuery adapter for warehouse connectivity
- local development through Python, VS Code, and Git
- Power BI as the downstream BI and semantic modeling tool

## Rationale

This approach:

- keeps BigQuery as the source of analytical computation
- allows SQL-based models to remain modular and reviewable
- provides dependency management through `source()` and `ref()`
- supports repeatable tests and documentation
- produces clear data lineage
- aligns with modern analytics engineering workflows
- supports a realistic analyst-to-BI development lifecycle

## Alternatives Considered

### Manually Managed BigQuery SQL

Rejected because dependency management, testing, documentation, and repeatability would require custom processes.

### dbt Cloud

Not selected for the initial implementation because dbt Core provides direct experience with local environments, command-line workflows, dependency management, and Git-based development.

This decision may be revisited if hosted scheduling, managed environments, or team collaboration features become necessary.

### Custom Python Transformation Pipeline

Rejected because the core transformation workload is SQL-centric and does not require a custom Python orchestration framework.

## Consequences

### Positive

- modular SQL development
- reproducible builds
- integrated testing
- improved documentation and lineage
- better separation between raw, analytical, and BI layers

### Trade-offs

- additional local environment configuration
- Python dependency management is required
- dbt conventions must be learned and maintained
- deployment and scheduling are not automatically provided by dbt Core

## Follow-up Decisions

Future ADRs may document:

- repository and dbt model structure
- BigQuery dataset and environment strategy
- model materialization strategy
- Power BI serving strategy