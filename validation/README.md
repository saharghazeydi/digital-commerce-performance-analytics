# Data Validation

This directory contains manual SQL quality-assurance checks, reconciliation queries, and historical validation summaries used to verify the governed analytical pipeline throughout the project.

Validation is implemented through two complementary mechanisms:

- automated dbt tests for repeatable structural, business-rule, grain, relationship, and reconciliation controls;
- manual SQL validation for deeper analytical reconciliation, distribution analysis, and diagnostic investigation.

The validation artifacts in this directory supplement the automated dbt test suite rather than duplicate it.

---

## Directory Structure

    validation/
    ├── phase_4/
    │   ├── 01_session_validation.sql
    │   ├── 02_transaction_validation.sql
    │   └── 03_reconciliation.sql
    │
    ├── phase_5/
    │   ├── 01_core_warehouse_validation.sql
    │   └── 02_core_reconciliation.sql
    │
    ├── reports/
    │   ├── phase4_validation_summary.md
    │   ├── phase5_validation_summary.md
    │   ├── phase6_validation_summary.md
    │   ├── phase7_validation_summary.md
    │   ├── phase8_validation_summary.md
    │   └── phase11_validation_summary.md
    │
    └── README.md

---

## Phase 4 — Intermediate Model Validation

Phase 4 validates the governed GA4 intermediate modeling layer:

- `int_ga4__session_events`
- `int_ga4__sessions`
- `int_ga4__transactions`

### `01_session_validation.sql`

Validates the session-level model, including:

- session grain;
- duplicate and null identifiers;
- session timing consistency;
- session-duration distributions;
- event-count distributions;
- purchasing-session consistency; and
- diagnostic session outliers.

### `02_transaction_validation.sql`

Validates the transaction-level model, including:

- transaction grain;
- duplicate and null identifiers;
- session referential integrity;
- transaction timing;
- monetary values;
- item quantities;
- revenue distributions;
- multi-transaction sessions; and
- transaction-level diagnostics.

### `03_reconciliation.sql`

Reconciles the event, session, and transaction populations, including:

- purchase-event counts;
- transaction counts;
- purchasing sessions;
- revenue;
- item quantities;
- purchasing users;
- per-session transaction metrics; and
- referential integrity.

The corresponding validation evidence is documented in:

`reports/phase4_validation_summary.md`

---

## Phase 5 — Core Warehouse Validation

Phase 5 validates the governed Core Warehouse layer:

- `dim_date`
- `dim_channel`
- `fct_sessions`
- `fct_transactions`

### `01_core_warehouse_validation.sql`

Provides manual quality-assurance checks across the Core Warehouse models, including model grains, keys, relationships, business-rule consistency, and analytical distributions.

### `02_core_reconciliation.sql`

Reconciles the governed Core Warehouse facts against the validated intermediate populations to confirm that session, transaction, and commercial measures are preserved through the warehouse layer.

The corresponding validation evidence is documented in:

`reports/phase5_validation_summary.md`

---

## Validation Reports

The `reports/` directory contains historical validation evidence produced at major analytical delivery gates.

### Phase 4 — Intermediate Models

`phase4_validation_summary.md`

Records validation of the governed session and transaction models and their reconciliation to the event-level population.

### Phase 5 — Core Warehouse

`phase5_validation_summary.md`

Records Core Warehouse grain, integrity, business-rule, and upstream reconciliation results.

### Phase 6 — Business Marts

`phase6_validation_summary.md`

Consolidates the Phase 6 validation evidence covering:

- device and geography performance;
- business-mart reconciliation;
- semantic controls;
- dependency-aware dbt validation; and
- performance and storage optimization decisions.

### Phase 7 — Executive KPI Layer

`phase7_validation_summary.md`

Records validation of:

- executive headline KPIs;
- rolling and week-over-week trends;
- channel-driver calculations;
- KPI semantic boundaries;
- governed aggregation rules; and
- upstream reconciliation.

### Phase 8 — BI Serving Layer

`phase8_validation_summary.md`

Records validation of the five governed BI serving datasets, including:

- serving-model grains;
- serving-to-upstream reconciliation;
- relationship and schema controls;
- semantic separation of analytical populations; and
- readiness for Power BI consumption.

### Phase 11 — Final Validation

`phase11_validation_summary.md`

Records the final end-to-end validation across:

- GA4 source and staging;
- intermediate models;
- Core Warehouse;
- business marts;
- executive KPI models;
- BI serving datasets;
- the complete dbt quality gate;
- repository integrity; and
- Power BI regression QA.

The final project-level dbt quality gate completed with:

- 13 table models;
- 8 view models;
- 363 data tests;
- 384 total selected nodes;
- 384 passed;
- 0 warnings;
- 0 errors; and
- 0 skipped nodes.

---

## Validation Strategy

The project intentionally separates automated testing from analytical validation.

### Automated dbt Tests

The dbt test suite provides repeatable controls for areas such as:

- uniqueness and model grain;
- null handling;
- accepted values;
- referential integrity;
- source and model reconciliation;
- KPI consistency;
- attribution and channel rules;
- semantic constraints; and
- serving-layer reconciliation.

These controls are executed as part of dependency-aware and project-level dbt builds.

### Manual SQL Validation

The SQL files under `phase_4/` and `phase_5/` provide deeper investigative validation where simple pass/fail tests are insufficient.

These checks support:

- distribution analysis;
- outlier investigation;
- cross-model reconciliation;
- metric diagnostics; and
- analytical review of governed populations.

Manual validation is therefore retained as complementary evidence rather than converted entirely into automated tests.

---

## Validation Coverage

The combined validation framework provides evidence across the governed analytical chain:

    GA4 Source
        ↓
    Staging
        ↓
    Intermediate Models
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

Not every project phase has a standalone validation report.

Early discovery, feasibility, architecture, and design decisions are documented under `docs/`, while Power BI semantic-model and report implementation evidence is maintained under `power_bi/documentation/`.

The `validation/reports/` directory is reserved for substantive validation and reconciliation evidence rather than serving as a phase-by-phase project archive.

---

## Current Validation Status

The governed analytical pipeline has completed end-to-end validation through Phase 11.

The final project-level quality gate passed all 384 selected dbt nodes with zero warnings, errors, or skipped nodes, and the final Power BI report passed its documented regression QA.

Known source and scope limitations remain documented in the relevant validation reports and project documentation.
