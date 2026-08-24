# Data Validation

This directory contains manual SQL quality-assurance and reconciliation checks used to validate analytical models before downstream reporting and mart development.

## Directory Structure

The validation layer contains three main SQL validation files under `phase_4`:

- `01_session_validation.sql`
- `02_transaction_validation.sql`
- `03_reconciliation.sql`

Validation results and conclusions are documented in:

- `reports/phase4_validation_summary.md`

## Phase 4 Validation

Phase 4 validates the GA4 intermediate modeling layer.

### 01 — Session Validation

`01_session_validation.sql` validates the session-level model, including:

- Session grain
- Duplicate and null identifiers
- Session timing consistency
- Session-duration distributions
- Event-count distributions
- Purchasing-session consistency
- Diagnostic session outliers

### 02 — Transaction Validation

`02_transaction_validation.sql` validates the transaction-level model, including:

- Transaction grain
- Duplicate and null identifiers
- Session referential integrity
- Transaction timing
- Monetary values
- Item quantities
- Revenue distributions
- Multi-transaction sessions
- Transaction-level diagnostics

### 03 — Cross-Model Reconciliation

`03_reconciliation.sql` reconciles the event, session, and transaction models, including:

- Purchase-event counts
- Transaction counts
- Purchasing sessions
- Revenue
- Item quantities
- Purchasing users
- Per-session transaction metrics
- Referential integrity

## Validation Approach

dbt tests enforce repeatable structural data-quality rules.

The SQL files in this directory provide deeper analytical validation, reconciliation, distribution analysis, and diagnostic investigation that are not appropriate as simple pass/fail tests.

The final Phase 4 validation results are documented in `reports/phase4_validation_summary.md`.