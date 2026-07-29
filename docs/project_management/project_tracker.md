# Project Tracker

## Project Overview

| Field | Current State |
|---|---|
| Project | Digital Commerce Performance Analytics |
| Delivery Model | Analytics engineering and business intelligence |
| Current Delivery Phase | Phase 3 — dbt Source and Staging Layer |
| Last Completed Phase | Phase 2 — Source Feasibility & Profiling |
| Current Work Package | P3D — Staging Models |
| Next Approved Work Package | P3E — Staging Tests, pending P3D review and merge |
| Repository Baseline | `main` through PR #9 |
| Overall Delivery Progress | Phase 0 foundation, Phase 1 development environment, and Phase 2 source feasibility complete; Phase 3 source-layer implementation is in progress |
| Last Updated | 2026-07-29 |

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

**Phase status:** In Progress
**Delivery outcome:** Define governed dbt sources and create standardized, tested, documented staging models.

| ID | Work Package | Deliverable | Status | Validation Summary | Pull Request |
|---|---|---|---|---|---|
| P3A | Source Definitions | Governed dbt source configuration and metadata for the GA4 daily event shards | Complete | `dbt parse` passed; source discovered with `dbt ls`; wildcard source resolved successfully through `dbt show`; 31,272 events validated for 2020-11-01 | PR #7 |
| P3B | Staging Architecture | Staging directories, naming standards, model boundaries, and staging grain conventions | Complete | Architecture reviewed; event and item grains defined; nested-field boundaries established; wildcard scan controls documented | PR #8 |
| P3C | Base Extraction Logic | Required source fields and nested attributes extracted consistently | Complete | Event staging model implemented and validated; 4,295,584 source events reconciled; 8/8 model and data checks passed | PR #9 |
| P3D | Staging Models | Standardized source-aligned dbt models | In Progress | `stg_ga4__items` implemented; 3,982,732 item rows reconciled; 13 item-model tests passed | — |
| P3E | Staging Tests | Generic and targeted staging tests | Not Started | Not yet executed | — |
| P3F | Staging Documentation | Model grains, columns, assumptions, and lineage documented | Not Started | Not yet executed | — |
| P3G | Staging Validation | Successful `dbt build` and source-to-staging reconciliation | Not Started | Not yet executed | — |

## Phase 4 — Intermediate Models

**Phase status:** Not Started
**Delivery outcome:** Transform source-aligned data into reusable analytical entities and business-ready transformation components.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P4A | Entity Design | Grain and key strategy for intermediate entities | Not Started |
| P4B | Event Transformation | Reusable event-level transformation logic | Not Started |
| P4C | Session Modeling | Session-level entity and session attributes | Not Started |
| P4D | Transaction Modeling | Transaction and purchase-level analytical entities | Not Started |
| P4E | Attribution Logic | Acquisition and channel attribution components | Not Started |
| P4F | Intermediate Tests | Grain, uniqueness, completeness, and reconciliation tests | Not Started |
| P4G | Intermediate Validation | Source-to-entity reconciliation and duplication review | Not Started |

---

## Phase 5 — Core Warehouse

**Phase status:** Not Started
**Delivery outcome:** Create reusable facts and dimensions with governed grains, keys, relationships, and data-quality controls.

| ID | Work Package | Deliverable | Status |
|---|---|---|---|
| P5A | Warehouse Model Design | Approved dimensional model and entity relationships | Not Started |
| P5B | Key Strategy | Natural, composite, and surrogate key standards | Not Started |
| P5C | Dimensions | Conformed analytical dimensions | Not Started |
| P5D | Facts | Governed session, transaction, and related fact models | Not Started |
| P5E | Referential Integrity | Relationship and orphan-record tests | Not Started |
| P5F | Core Reconciliation | Intermediate-to-core metric and row reconciliation | Not Started |
| P5G | Warehouse Documentation | Model diagram, grains, keys, and lineage | Not Started |

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

### Phase 3 — dbt Source and Staging Layer

## Current Work Package

### P3C — Base Extraction Logic

The current work package defines and implements the controlled extraction of required GA4 event, parameter, ecommerce, and item fields.

Field-level profiling has confirmed the required source paths and observed value types.

The extraction contract is documented in:

`docs/architecture/ga4_base_extraction_contract.md`

The work package will preserve raw event grain, isolate item-array expansion, retain source-level transaction multiplicity, and enforce bounded wildcard reads.

## Next Approved Work Package

### P3D — Staging Models

P3D may begin after the P3C extraction logic has been implemented, validated, reviewed, and merged.
