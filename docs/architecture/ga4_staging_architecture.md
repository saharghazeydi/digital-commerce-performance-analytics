# GA4 Staging Architecture

## Purpose

This document defines the staging-layer architecture for the GA4 ecommerce source used by the Digital Commerce Performance Analytics project.

The staging layer establishes a controlled boundary between the raw GA4 export structure and downstream analytical models.

Its purpose is to standardize source access, field extraction, naming, typing, grain, and data-quality responsibilities before business logic is introduced.

This document defines the architectural rules implemented by the GA4 staging layer. Detailed field-level extraction rules are documented separately in the GA4 Base Extraction Contract.

---

## Source Context

The governed dbt source is:

`source('ga4', 'events')`

The physical source consists of daily BigQuery tables exposed through the wildcard relation:

`events_*`

The approved analytical source window is:

- start date: `2020-11-01`
- end date: `2021-01-31`
- daily shards: `92`

All models reading the wildcard source must restrict scans using `_TABLE_SUFFIX` and an explicit bounded date range.

The source characteristics, risks, and feasibility findings are documented in:

- `docs/data_quality/ga4_source_feasibility_assessment.md`
- `docs/decisions/ADR-002-ga4-order-identity-and-deduplication.md`

---

## Architectural Principles

The staging layer follows these principles:

1. **Preserve source meaning**

   Staging models standardize raw fields without introducing business-level interpretation.

2. **Define explicit grain**

   Every model must have a documented and testable row grain.

3. **Extract nested structures deliberately**

   GA4 nested and repeated fields are expanded only when required by the target entity.

4. **Avoid uncontrolled row multiplication**

   Repeated arrays must not be unnested together when doing so could create Cartesian multiplication.

5. **Use deterministic transformations**

   Field extraction, deduplication, and canonicalization rules must produce reproducible results.

6. **Control BigQuery scans**

   Every direct read from the wildcard GA4 source must use bounded `_TABLE_SUFFIX` filtering.

7. **Separate structural transformation from business logic**

   Staging models perform source-aligned cleanup and standardization. Business metrics and reporting logic belong downstream.

8. **Document data-quality assumptions**

   Known source limitations must remain visible rather than being silently hidden by transformations.

---

## Implemented Staging Structure

The GA4 staging layer resides under:

`models/staging/ga4/`

The implemented structure is:

models/
└── staging/
    └── ga4/
        ├── _ga4__sources.yml
        ├── _ga4__models.yml
        ├── stg_ga4__events.sql
        └── stg_ga4__items.sql

Additional staging models may be introduced only when a distinct source-aligned grain or transformation responsibility requires them.

---

## Model Responsibilities

### `stg_ga4__events`

**Target grain:** one row per raw GA4 event.

Responsibilities:

- read the governed wildcard GA4 source;
- enforce the approved `_TABLE_SUFFIX` source window;
- expose core event identifiers and timestamps;
- standardize event-level fields;
- extract approved scalar event parameters required broadly downstream;
- expose ecommerce event-level attributes required by later models;
- preserve sufficient identifiers for deterministic downstream joins.

This model must not calculate business KPIs or aggregate events.

---

### `stg_ga4__items`

**Target grain:** one row per item occurrence within a raw GA4 event.

Responsibilities:

- unnest the GA4 `items` repeated structure;
- preserve transaction and event context;
- expose product identifiers and descriptive attributes;
- expose quantity, price, revenue, coupon, and other approved item attributes;
- retain fields required for deterministic product canonicalization downstream.

This model must not define the governed order entity or perform final transaction deduplication.

---

## Event Identity

The staging layer must preserve the fields required to identify and trace individual raw events.

At minimum, event-level models should retain relevant source fields such as:

- `event_date`
- `event_timestamp`
- `event_name`
- `user_pseudo_id`
- `event_bundle_sequence_id`
- `batch_event_index` where available and useful

---

## User Identity

The available analytical user identifier is:

`user_pseudo_id`

Authenticated `user_id` is not available in the approved source.

The staging layer must preserve `user_pseudo_id` without redefining it as a known customer identity.

---

## Session Identity

The approved analytical session identity is the composite of:

- `user_pseudo_id`
- `ga_session_id`

`ga_session_id` must be extracted from GA4 event parameters where required.

`ga_session_id` alone must not be treated as globally unique.

Final session-level entity construction belongs downstream of staging.

---

## Transaction Identity

Transaction handling must follow ADR-002.

For valid transaction identifiers, the approved transaction identity is:

- `user_pseudo_id`
- `transaction_id`

Repeated valid purchase events must not be silently removed during generic source cleanup.

The staging layer preserves the information required for deterministic transaction deduplication.

Final governed order deduplication belongs to a downstream transformation layer.

Invalid transaction identifiers, including null and placeholder values, must remain distinguishable from valid transaction identities.

---

## Nested and Repeated Fields

GA4 contains nested and repeated structures including:

- `event_params`
- `user_properties`
- `items`

These structures must be handled independently.

Multiple repeated arrays must not be unnested in the same transformation unless the resulting row multiplication is explicitly intended and validated.

Frequently required scalar parameters may be promoted into `stg_ga4__events` through deterministic conditional extraction.

Repeated structures with their own analytical grain should remain in dedicated staging models.

---

## Naming Conventions

Staging models use:

`stg_<source>__<entity>`

For this source:

`stg_ga4__<entity>`

Column names should:

- use `snake_case`;
- remain business-readable;
- preserve source terminology where it carries established GA4 meaning;
- avoid unnecessary abbreviations;
- distinguish timestamps, dates, identifiers, quantities, and monetary values clearly.

Renaming should improve consistency without changing semantic meaning.

---

## Type Standardization

Staging models are responsible for predictable analytical types where source representation requires normalization.

Type conversions must be explicit.

Particular care is required for:

- GA4 parameter values distributed across string, integer, float, and double fields;
- microsecond event timestamps;
- source date strings;
- monetary values;
- integer quantities;
- nullable identifiers.

Unsafe casts should not silently convert malformed values into misleading analytical values.

---

## Date and Timestamp Handling

`event_date` originates as a GA4 date-formatted string and should be exposed downstream as a proper SQL `DATE`.

`event_timestamp` originates as microseconds since Unix epoch and should be exposed as a proper BigQuery timestamp while preserving the original source field when traceability requires it.

The project must use a consistent timezone interpretation for downstream calendar analysis.

Any timezone-dependent business transformation must be explicitly documented rather than inferred in staging.

---

## Source Window and Scan Control

Direct reads from:

`source('ga4', 'events')`

must include an explicit `_TABLE_SUFFIX` restriction.

The approved historical window is:

`20201101` through `20210131`

Models must not rely on unrestricted wildcard scans.

During development, narrower bounded windows may be used when appropriate to reduce BigQuery processing cost.

Any model intended to represent the full approved project history must explicitly use the approved source bounds.

---

## Materialization Strategy

The implemented staging models use lightweight `view` materializations.

This preserves a transparent source-aligned transformation boundary while avoiding unnecessary physical duplication of the bounded GA4 source data.

Materialization decisions are defined in the dbt project configuration and may be reconsidered only when supported by measured performance, cost, or downstream reuse requirements.

Materialization changes should not be made solely as premature optimization.

---

## Testing Responsibilities

Staging tests validate structural and source-contract assumptions.

Implemented staging quality controls include:

- required-field `not_null` checks where source profiling supports the expectation;
- accepted values for tightly controlled categorical fields where appropriate;
- uniqueness tests only where the model grain guarantees uniqueness;
- relationship tests where a stable parent-child relationship has been intentionally modeled;
- custom data tests for source-specific invariants when generic tests are insufficient.

Tests must reflect observed source behavior.

Known source defects must not be converted into failing tests unless the transformation contract explicitly resolves those defects.

---

## Documentation Responsibilities

Each staging model documents:

- model purpose;
- row grain;
- important identifiers;
- renamed or derived fields;
- material source assumptions;
- relevant source limitations.

Important columns used for joins, entity identity, business calculations, or downstream interpretation receive explicit dbt descriptions.

Documentation should explain analytical meaning rather than simply repeat column names.

---

## Staging Boundaries

The staging layer may:

- rename source fields;
- cast data types;
- extract scalar nested values;
- unnest one repeated structure into an intentional grain;
- standardize null representations where governed;
- expose technical keys required downstream;
- apply deterministic source-aligned cleanup.

The staging layer must not:

- calculate executive KPIs;
- aggregate business metrics;
- define reporting dimensions;
- perform final customer segmentation;
- implement dashboard-specific logic;
- define final order-level revenue;
- perform final transaction deduplication;
- hide known source-quality problems without documentation.

Those responsibilities belong to downstream transformation layers.

---

## Acceptance Criteria and Implementation Status

The staging architecture was accepted against the following criteria:

- model grains are explicitly defined;
- staging responsibilities are separated from downstream business logic;
- wildcard source scan controls are established;
- user, session, event, and transaction identity responsibilities are clear;
- repeated-field handling prevents unintended row multiplication;
- naming and typing conventions are established;
- materialization strategy is defined;
- staging testing and documentation responsibilities are established;
- the architecture is reviewed through the repository Pull Request workflow.

These criteria were satisfied during implementation. The staging layer now consists of the governed source definition, `stg_ga4__events`, `stg_ga4__items`, model and column documentation, and automated source-contract and reconciliation tests.

Final Phase 11 validation confirmed that the staging models reconcile to the approved bounded GA4 source population and participate in the successful project-level dbt quality gate.
