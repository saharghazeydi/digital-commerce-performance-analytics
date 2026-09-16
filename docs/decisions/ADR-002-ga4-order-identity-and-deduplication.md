# ADR-002 — GA4 Order Identity and Deduplication

## Status

Accepted

## Context

GA4 purchase-event profiling identified repeated purchase events and duplicate
transaction identifiers.

Using raw purchase-event rows directly would overstate transaction counts and
purchase revenue.

Profiling also established that `transaction_id` alone is not the preferred
analytical identity for this source and that some purchase events contain
invalid or unavailable transaction identifiers.

A governed transaction identity and deduplication strategy is therefore required
before commercial metrics are calculated.

## Decision

For valid purchase records, the analytical transaction identity will be based on
the composite key:

`user_pseudo_id + transaction_id`

Repeated purchase events sharing this composite key will represent candidate
duplicate observations of the same analytical transaction.

Deduplication will be performed explicitly in the dbt transformation layer.

Duplicate source rows will not be removed or modified at ingestion or source
definition level.

Records with invalid transaction identifiers, including `NULL` and `(not set)`,
will not be assigned the standard transaction key. They will be handled
explicitly as a separate transaction-quality condition.

The final deterministic row-selection rule for repeated valid transaction events
will be implemented and tested when the transaction model is developed.

## Rationale

Profiling demonstrated that:

- duplicate purchase events exist;
- duplicate transaction identifiers can materially inflate revenue;
- the composite user-transaction identity reduces ambiguity compared with
  transaction ID alone;
- repeated observations of the composite key showed consistent commercial
  payloads in the assessed source;
- invalid transaction identifiers require separate handling.

This approach preserves source fidelity while providing a controlled business
grain for transaction-level analytics.

## Consequences

### Positive

- transaction counts can be reconciled to a governed business grain;
- revenue duplication can be prevented;
- source anomalies remain visible and testable;
- transaction logic becomes reproducible in dbt;
- downstream KPI models receive a stable transaction entity.

### Trade-offs

- transaction modeling requires additional transformation logic;
- invalid transaction IDs require separate treatment;
- the analytical key is source-specific and should not be assumed to represent
  a universal production order-key design.

## Validation Requirements

The downstream transaction model must validate:

- uniqueness of the governed transaction grain;
- deterministic duplicate handling;
- reconciliation of raw and deduplicated purchase counts;
- reconciliation of raw and deduplicated revenue;
- explicit treatment of invalid transaction identifiers;
- preservation of transaction-level item and revenue attributes.

## Scope

This decision applies to the GA4 source used by the Digital Commerce Performance
Analytics project.

It does not define transaction identity for unrelated datasets or previous
analytics projects.
