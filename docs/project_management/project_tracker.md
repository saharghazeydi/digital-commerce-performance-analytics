# Project Tracker

## Project Overview

| Field | Current State |
|---|---|
| Project | Digital Commerce Performance Analytics |
| Delivery Model | Analytics engineering and business intelligence |
| Current Delivery Phase | Phase 5 — Core Warehouse |
| Last Completed Phase | Phase 4 — Intermediate Models |
| Current Work Package | P5I — Documentation & Phase 5 Closeout |
| Next Approved Work Package | P6A — Mart Requirements, after Phase 5 closeout review and merge |
| Repository Baseline | `main` through Phase 4 closeout and PR #13; Phase 5 implementation and validation are complete on `feat/core-warehouse`, with formal closeout in progress |
| Overall Delivery Progress | Phases 0–4 are complete and merged. Phase 5 core warehouse architecture, dimensions, facts, governed channel classification, automated tests, referential-integrity controls, and intermediate-to-core reconciliation are complete. Phase 5 documentation and repository closeout remain before progression to Phase 6. |
| Last Updated | 2026-08-25 |

## Tracker Purpose

This tracker provides the current delivery status of the project at phase and work-package level.

Detailed acceptance criteria, validation evidence, commands, reconciliation results, and completion decisions are maintained in `docs/project_management/phase_checkpoints.md`.

Long-term scope, architecture, design principles, and target deliverables are maintained in `docs/project_management/project_blueprint.md`.

## Status Definitions

| Status | Definition |
|---|---|
| Not Started | The work package is included in the roadmap but has not yet been approved for execution. |
| Planned | The work package is approved and ready to begin. |
| In Progress | Implementation or validation is actively underway. |
| In Review | Implementation is complete and awaiting technical or documentation review. |
| Blocked | Progress cannot continue because of an unresolved dependency or decision. |
| Complete | The deliverable has been implemented, validated, reviewed, and merged where applicable. |
| Deferred | The work package has intentionally been postponed and is not part of the current delivery sequence. |

---

## Phase 0 — Project Foundation and Governance

**Phase status:** Complete
**Delivery outcome:** Repository governance, target architecture, documentation controls, and the GitHub delivery workflow were established and validated.

| ID | Work Package | Deliverable | Status | Validation Summary | Pull Request |
|---|---|---|---|---|---|
| P0A | Environment Audit | Python, Git, VS Code, and local repository environment reviewed | Complete | Required tools, versions, paths, and repository access reviewed | Not Applicable |
| P0B | Project Blueprint | Business objective, delivery scope, architecture principles, and validation approach documented | Complete | Documentation structure and project boundaries reviewed | PR #2 |
| P0C | Repository Governance | Repository standards, configuration files, templates, and directory structure established | Complete | Repository file and exclusion-rule audit completed | PR #1 |
| P0D | GitHub Workflow Validation | Branch, commit, push, pull request, review, merge, pull, and branch-cleanup workflow validated | Complete | Local and remote repositories reconciled successfully | PR #1 |
| P0E | Architecture and Documentation Audit | Target architecture, project tracker, phase checkpoints, and architecture decision record established | Complete | Documentation and repository architecture reviewed | PR #2 |

---

## Phase 1 — dbt Development Environment

**Phase status:** Complete
**Delivery outcome:** A reproducible local dbt Core development environment was established and connected securely to BigQuery.

| ID | Work Package | Deliverable | Status | Validation Summary | Pull Request |
|---|---|---|---|---|---|
| P1A | Python Virtual Environment | Isolated Python 3.11 virtual environment created | Complete | Virtual-environment Python and pip paths confirmed | PR #3 |
| P1B | Environment Activation and Validation | Local environment activated and isolated from global Python packages | Complete | Active interpreter resolved to repository `.venv` | PR #3 |
| P1C | Packaging Toolchain | pip, setuptools, and wheel upgraded | Complete | Package installation completed without dependency conflicts | PR #3 |
| P1D | dbt BigQuery Installation | dbt Core and BigQuery adapter installed | Complete | `dbt --version` confirmed compatible core and adapter versions | PR #3 |
| P1E | Dependency Snapshot | Python dependencies recorded in `requirements.txt` | Complete | Dependency snapshot created and included in version control | PR #3 |
| P1F | dbt Project Initialization | Initial dbt project scaffold created | Complete | Required dbt directories and project configuration confirmed | PR #3 |
| P1G | dbt Scaffold Refinement | Example models removed and generated artifacts excluded | Complete | Scaffold reviewed; logs, packages, and build artifacts ignored | PR #3 |
| P1H | Local dbt Profile | Local BigQuery development target configured | Complete | Profile resolved successfully from the local `.dbt` directory | PR #3 |
| P1I | Google Cloud Authentication | Google Cloud CLI and Application Default Credentials configured | Complete | Authenticated account and project configuration confirmed | PR #3 |
| P1J | BigQuery Connection Validation | dbt connectivity to the development dataset verified | Complete | `dbt debug` returned `All checks passed!` | PR #3 |
| P1K | Phase Integration | Environment setup committed, reviewed, merged, and synchronized locally | Complete | PR #3 merged; local `main` clean and aligned with `origin/main` | PR #3 |

---

## Phase 2 — Source Feasibility & Profiling

**Phase status:** Complete
**Delivery outcome:** The GA4 ecommerce source has been profiled and assessed as feasible for the planned analytics-engineering implementation, subject to documented transformation controls for session identity, transaction deduplication, invalid transaction identifiers, nested item handling, and bounded source scanning.

| ID | Work Package | Deliverable | Status | Validation Summary | Pull Request |
|---|---|---|---|---|---|
| P2A | Source Scope and Access | Approved source inventory, access confirmation, location, date coverage, and intended analytical use | Complete | Public GA4 source confirmed; 92 daily tables covering 2020-11-01 through 2021-01-31; query access validated | PR #6 |
| P2B | Table Inventory | Source tables, naming patterns, physical structure, date ranges, and row volumes documented | Complete | Daily `events_YYYYMMDD` base tables confirmed; no missing daily shards; approximately 4.30M event rows profiled | PR #6 |
| P2C | Schema and Grain Profiling | Source grain, nested structures, identifiers, data types, and key fields assessed | Complete | Event grain, repeated item arrays, user identifiers, session parameters, transaction identifiers, and product identifiers assessed | PR #6 |
| P2D | Data Quality Profiling | Nulls, duplicates, missing identifiers, invalid values, and structural anomalies assessed | Complete | Duplicate purchases, invalid transaction IDs, placeholder item rows, quantity outliers, and revenue reconciliation reviewed | PR #6 |
| P2E | Analytical Entity Feasibility | Feasibility of users, sessions, transactions, products, and acquisition entities assessed | Complete | Composite session identity and composite user-transaction identity validated; product and acquisition feasibility confirmed | PR #6 |
| P2F | KPI Feasibility | Feasibility of revenue, transactions, sessions, conversion rate, AOV, and related KPIs assessed | Complete | Revenue, purchase, session, funnel, and product fields assessed; governed entities required before KPI aggregation | PR #6 |
| P2G | Cost and Performance Review | Query volume, shard filtering, development windows, and cost controls documented | Complete | Daily sharded structure confirmed; `_TABLE_SUFFIX` filtering and bounded development windows required; broad scan estimates reviewed | PR #6 |
| P2H | Risks and Assumptions | Source limitations, assumptions, exclusions, and mitigation decisions documented | Complete | Source limitations documented in feasibility assessment; order identity and deduplication decision captured in ADR-002 | PR #6 |
| P2I | Phase Validation | Source feasibility decision and Phase 3 entry recommendation documented | Complete | GA4 source accepted as feasible; no blocking source limitation identified; progression to Phase 3 approved | PR #6 |

## Phase 3 — dbt Source and Staging Layer

**Phase status:** Complete
**Delivery outcome:** Governed GA4 dbt sources and standardized event- and item-grain staging models were implemented, tested, documented, reconciled, reviewed, and formally closed. The validated staging layer is approved as the source-aligned input to Phase 4 intermediate modeling.

| ID | Work Package | Deliverable | Status | Validation Summary | Pull Request |
|---|---|---|---|---|---|
| P3A | Source Definitions | Governed dbt source configuration and metadata for the GA4 daily event shards | Complete | `dbt parse` passed; source discovered with `dbt ls`; wildcard source resolved successfully through `dbt show`; 31,272 events validated for 2020-11-01 | PR #7 |
| P3B | Staging Architecture | Staging directories, naming standards, model boundaries, and staging grain conventions | Complete | Architecture reviewed; event and item grains defined; nested-field boundaries established; wildcard scan controls documented | PR #8 |
| P3C | Base Extraction Logic | Required source fields and nested attributes extracted consistently | Complete | `stg_ga4__events` implemented and validated; 4,295,584 source events reconciled with zero row-count difference | PR #9 |
| P3D | Staging Models | Standardized source-aligned event- and item-grain dbt models | Complete | `stg_ga4__items` implemented; 3,982,732 item rows reconciled; model implementation reviewed and merged | PR #10 |
| P3E | Staging Tests | Generic and targeted staging data-quality tests | Complete | 26 generic and singular tests implemented across both staging models; composite grain, date-window, parent-event, item-offset, and required-field controls passed | PR #11 |
| P3F | Staging Documentation | Model grains, columns, assumptions, and lineage documented | Complete | Both staging models and all published columns documented in `_ga4__models.yml`; source-aligned transaction placeholder behaviour and model grains documented | PR #9 and PR #10 |
| P3G | Staging Validation | Successful dbt parsing, build, documentation generation, and source-to-staging reconciliation | Complete | `dbt parse --no-partial-parse` passed; `dbt build` completed successfully for 2 models and 26 tests; 28/28 nodes succeeded; `dbt docs generate` produced the catalog successfully | Phase 3 closeout PR |

## Phase 4 — Intermediate Models

**Phase status:** Complete

**Delivery outcome:** Governed reusable GA4 intermediate entities were implemented at event, session, and transaction grain, with deterministic keys, acquisition logic, purchase deduplication, documented business rules, automated tests, and end-to-end cross-model reconciliation.

| ID | Work Package | Deliverable | Status | Validation Summary |
|---|---|---|---|---|
| P4A | Define Sessionization Rules | Approved session grain, identity, ordering, attribution, and implementation rules | Complete | Composite session identity and deterministic surrogate-key strategy defined; session design documented |
| P4B | Extract Session Attributes | Reusable session attributes and acquisition-selection logic | Complete | First/last event logic, landing/exit attributes, acquisition selection, and purchase-normalization rules implemented |
| P4C | Build Event-Level Intermediate Model | `int_ga4__session_events` | Complete | Event grain preserved; deterministic session keys, sequencing, acquisition flags, normalized transaction IDs, and deduplicated purchase flags validated |
| P4D | Build Session-Level Model | `int_ga4__sessions` | Complete | 360,129 unique sessions produced; session timing, event counts, acquisition attributes, and purchase metrics validated |
| P4E | Build Transaction-Level Model | `int_ga4__transactions` | Complete | 4,451 unique valid transactions produced; transaction-to-session referential integrity and transaction grain validated |
| P4F | Reconcile Users, Sessions and Purchases | Manual QA suite and cross-model reconciliation | Complete | 4,033 purchasing sessions, 4,451 transactions, 3,702 purchasing users, 307,640 purchase revenue, and 19,459 item quantity reconciled with zero identified cross-model mismatches |
| P4G | Add Intermediate Tests | Final automated dbt test coverage for intermediate models | Complete | Targeted business-rule tests added for event sequencing, acquisition selection, purchase uniqueness, session metrics, purchase consistency, and transaction session-window integrity; final intermediate test suite passed with 61/61 tests |
| P4H | Validate Row Counts and Grains | Final Phase 4 dbt quality gate and acceptance validation | Complete | Final dbt build passed 75/75 nodes with zero warnings or errors; session, transaction, purchasing-session, and revenue grains reconciled successfully across intermediate models |

---

## Phase 5 — Core Warehouse

**Phase status:** In Progress

**Delivery outcome:** A governed Core Warehouse has been implemented on top of the validated GA4 intermediate layer, providing reusable calendar and channel dimensions plus session- and transaction-grain facts with explicit grains, stable keys, tested relationships, documented business rules, and zero-difference reconciliation to the intermediate layer.

| ID | Work Package | Deliverable | Status | Validation Summary |
|---|---|---|---|---|
| P5A | Warehouse Architecture & Grain Design | Approved Core Warehouse architecture, entity boundaries, analytical grains, and dimensionality decisions | Complete | Core Warehouse scope defined as `dim_date`, `dim_channel`, `fct_sessions`, and `fct_transactions`; unnecessary low-value dimensions intentionally avoided |
| P5B | Key Strategy & Model Contracts | Governed keys, model contracts, upstream dependencies, column ownership, measures, and materialization strategy | Complete | Native date keys, governed session and transaction keys, model grains, source dependencies, reconciliation requirements, and quality gates documented before implementation |
| P5C | Date Dimension | `dim_date` | Complete | 92 calendar dates generated across the governed analytical date range; date grain, required attributes, accepted values, uniqueness, non-null rules, and fact-date coverage validated |
| P5D | Channel Dimension | `dim_channel` and governed session channel classification | Complete | Acquisition data profiled before design; 8 governed business-facing channel groups implemented; session channel mapping, dimension uniqueness, and session-to-channel referential integrity validated |
| P5E | Session Fact | `fct_sessions` | Complete | 360,129 unique session rows preserved from the intermediate layer; session grain, date relationship, channel relationship, behavioral measures, commercial measures, and business rules validated |
| P5F | Transaction Fact | `fct_transactions` | Complete | 4,451 unique valid transaction rows preserved; transaction grain, transaction-to-session and transaction-to-date relationships, monetary rules, quantity rules, and session-window integrity validated |
| P5G | Referential Integrity & Warehouse Tests | Core Warehouse generic and business-rule dbt quality gate | Complete | Final warehouse test execution passed 71/71 tests; dependency-aware Core Warehouse build passed 75/75 selected nodes with zero warnings, errors, or skipped nodes |
| P5H | Core Reconciliation | Intermediate-to-core aggregate and key-set reconciliation | Complete | Session and transaction row counts, distinct keys, purchasing-session counts, commercial measures, quantities, and key populations reconciled with zero differences and zero missing or unexpected keys |
| P5I | Documentation & Phase 5 Closeout | Validation evidence, project tracking, checkpoint, final quality gate, review, and merge | In Progress | Phase 5 validation SQL and validation summary prepared; project-management closeout documentation and final repository review are in progress |

---

## Phase 6 — Business Marts

**Phase status:** Not Started
**Delivery outcome:** Build domain-oriented marts that answer defined commercial, acquisition, customer, and ecommerce performance questions.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P6A | Mart Requirements | Consumers, decisions, and business questions defined | Not Started |
| P6B | KPI Contracts | KPI definitions, grains, filters, and ownership documented | Not Started |
| P6C | Acquisition Mart | Channel and acquisition performance model | Not Started |
| P6D | Commerce Mart | Revenue, transaction, and conversion performance model | Not Started |
| P6E | Customer Behaviour Mart | Customer and engagement behaviour model | Not Started |
| P6F | Segment Performance Mart | Device, geography, and other approved segment models | Not Started |
| P6G | Mart Validation | Business-rule tests and core-to-mart reconciliation | Not Started |

---

## Phase 7 — Executive KPI Layer

**Phase status:** Not Started
**Delivery outcome:** Establish a controlled and reconciled KPI layer for leadership-level monitoring and decision support.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P7A | Executive KPI Scope | Approved executive metric set and decision use cases | Not Started |
| P7B | KPI Calculation Layer | Governed executive KPI models | Not Started |
| P7C | Trend Metrics | Rolling, period-over-period, and variance metrics | Not Started |
| P7D | Driver Metrics | Channel, segment, and performance-contribution metrics | Not Started |
| P7E | KPI Reconciliation | Independent validation of all executive metrics | Not Started |
| P7F | KPI Documentation | Definitions, formulas, filters, and known limitations | Not Started |

---

## Phase 8 — BI Serving Layer

**Phase status:** Not Started
**Delivery outcome:** Provide stable, performant, business-readable datasets optimized for Power BI consumption.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P8A | Serving Requirements | BI grains, refresh requirements, and consumer needs | Not Started |
| P8B | Serving Models | Power BI-ready fact, summary, and filter models | Not Started |
| P8C | Business Naming | Business-readable fields and consistent naming | Not Started |
| P8D | Performance Optimization | Partitioning, clustering, size, and query-performance review | Not Started |
| P8E | Serving Validation | Mart-to-serving reconciliation and schema review | Not Started |

---

## Phase 9 — Power BI Semantic Model

**Phase status:** Not Started
**Delivery outcome:** Build a governed Power BI semantic model with clear relationships, measures, formatting, and filter behaviour.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P9A | BigQuery Connection | Controlled Power BI connection to serving datasets | Not Started |
| P9B | Semantic Architecture | Star-schema relationships and filter direction | Not Started |
| P9C | Date Model | Dedicated and validated date dimension | Not Started |
| P9D | DAX Measures | Business measures and calculation groups where appropriate | Not Started |
| P9E | Model Usability | Technical fields hidden and business folders organized | Not Started |
| P9F | Semantic Validation | Relationship, total, filter, and KPI reconciliation tests | Not Started |

---

## Phase 10 — Power BI Report

**Phase status:** Not Started
**Delivery outcome:** Deliver an executive-ready, decision-oriented Power BI report with consistent interaction and visual design.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P10A | Report Requirements | Audiences, decisions, pages, and success criteria defined | Not Started |
| P10B | Executive Overview | Leadership-level KPI and trend page | Not Started |
| P10C | Acquisition Analysis | Channel and acquisition performance page | Not Started |
| P10D | Commerce Performance | Revenue, conversion, and transaction page | Not Started |
| P10E | Customer and Segment Analysis | Behaviour and segment performance page | Not Started |
| P10F | Interaction Design | Tooltips, drill-through, navigation, and slicers | Not Started |
| P10G | Visual QA | Layout, formatting, readability, and narrative review | Not Started |

---

## Phase 11 — Final Validation

**Phase status:** Not Started
**Delivery outcome:** Validate the complete analytical chain from source data through dbt models, BigQuery outputs, semantic measures, and report visuals.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P11A | Source-to-Staging Reconciliation | Source and staging results reconciled | Not Started |
| P11B | Warehouse Reconciliation | Intermediate, core, and mart layers reconciled | Not Started |
| P11C | BI Reconciliation | Serving, semantic-model, and report values reconciled | Not Started |
| P11D | dbt Quality Gate | Full dbt parsing, build, test, and documentation validation | Not Started |
| P11E | Repository Audit | Secrets, generated files, documentation, links, and structure reviewed | Not Started |
| P11F | Power BI QA | Filters, totals, navigation, empty states, and interactions tested | Not Started |
| P11G | Final Acceptance | All critical checks approved or explicitly documented | Not Started |

---

## Phase 12 — Portfolio Packaging

**Phase status:** Not Started
**Delivery outcome:** Package the technical implementation and business analysis as a reproducible, interview-ready analytics engineering case study.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P12A | Repository Narrative | Final README and project walkthrough | Not Started |
| P12B | Architecture Assets | Architecture, lineage, and data-model diagrams | Not Started |
| P12C | Business Documentation | KPI dictionary, assumptions, limitations, and decisions | Not Started |
| P12D | Validation Evidence | Curated technical and business validation evidence | Not Started |
| P12E | Dashboard Assets | Final report screenshots and presentation views | Not Started |
| P12F | Reproduction Guide | Environment and execution instructions | Not Started |
| P12G | Interview Preparation | Project narrative, trade-offs, findings, and defensible talking points | Not Started |
| P12H | Portfolio Release | Final repository review and portfolio publication | Not Started |

---
## Current Focus

### Phase 5 — Core Warehouse — Closeout

Phase 5 technical implementation and validation are complete. Formal documentation and repository closeout are in progress.

Implemented Core Warehouse models:

- `dim_date`
- `dim_channel`
- `fct_sessions`
- `fct_transactions`

Core Warehouse design decisions include:

- explicit and governed analytical grains
- native BigQuery `DATE` values for calendar relationships
- preservation of governed Phase 4 session and transaction keys
- business-facing acquisition channel classification
- retention of detailed `source`, `medium`, and `campaign` attributes for drill-down analysis
- session-level channel ownership through `channel_key`
- no reconstruction of sessionization or transaction-deduplication logic in the warehouse layer

Final warehouse validation confirms:

- 92 governed calendar dates
- 8 governed channel groups
- 360,129 unique sessions
- 4,451 unique valid transactions
- zero duplicate session keys
- zero duplicate transaction IDs
- zero invalid session-to-date relationships
- zero invalid transaction-to-date relationships
- zero invalid transaction-to-session relationships
- zero invalid session-to-channel relationships
- governed session channel mapping validated
- session business-rule tests passed
- transaction business-rule tests passed
- final Core Warehouse dbt test suite: 71/71 passed
- final dependency-aware Core Warehouse build: 75/75 passed
- zero warnings, errors, and skipped nodes in the final Core Warehouse quality gate
- session aggregate reconciliation differences: 0
- transaction aggregate reconciliation differences: 0
- sessions missing from Core Warehouse: 0
- unexpected sessions in Core Warehouse: 0
- transactions missing from Core Warehouse: 0
- unexpected transactions in Core Warehouse: 0

Phase 5 is technically accepted. Documentation closeout, final repository review, Pull Request review, merge, and synchronization with `main` remain before Phase 6 begins.

## Next Approved Work Package

### P6A — Mart Requirements

Define the consumers, business decisions, analytical questions, required grains, and downstream reporting requirements for the Business Marts layer.

P6A will begin only after Phase 5 closeout is reviewed, merged, and the local `main` branch is synchronized with `origin/main`.
