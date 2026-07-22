# Development Workflow and Repository Operating Standard

## Purpose

This document defines how analytical work is explored, validated, documented, implemented, reviewed, and stored within the Digital Commerce Performance Analytics repository.

Its purpose is to keep the repository reproducible, maintainable, reviewable, and suitable for professional analytics engineering delivery.

This document governs working practices. Project scope and target architecture are defined in `docs/project_blueprint.md`, while delivery status and validated milestones are maintained in the project tracker and phase checkpoints.

---

## Core Workflow

All analytical work follows the sequence below:

```text
Business or Technical Question
            ↓
Exploration
            ↓
Validation
            ↓
Finding
            ↓
Decision
            ↓
Implementation
            ↓
Testing and Reconciliation
            ↓
Documentation
            ↓
Pull Request and Review
```

Exploration does not automatically become implementation.

Only validated, reusable, and project-relevant work is promoted into the repository.

---

## Repository Artifact Policy

### Artifacts Included in Git

The following artifacts may be committed when they support a durable project deliverable:

* dbt models, macros, tests, seeds, and snapshots
* approved SQL transformation logic
* model and column documentation
* architecture documentation and diagrams
* Architecture Decision Records
* source-assessment and data-quality findings
* KPI definitions and business rules
* Power BI project assets and approved report screenshots
* scripts required to reproduce or validate the project
* environment dependency files
* repository configuration and governance documents
* curated validation evidence that remains useful after the work package is complete

### Artifacts Excluded from Git

The following artifacts must not be committed:

* ad hoc exploratory SQL with no continuing project value
* temporary query exports
* raw BigQuery result downloads
* screenshots used only for discussion or troubleshooting
* local credentials, tokens, profiles, or secrets
* virtual environments
* dbt logs, compiled files, packages, and target artifacts
* Power BI cache or temporary files
* local scratch notes
* automatically generated directory listings
* duplicated documentation
* files retained only because they may be useful later

An artifact must have a clear long-term purpose before it is committed.

---

## Exploration Policy

Exploratory analysis is performed primarily in BigQuery.

Exploratory queries are used to:

* understand source structure
* profile volume and date coverage
* inspect event names and nested fields
* assess grain and identifiers
* test data-quality hypotheses
* evaluate entity and KPI feasibility
* compare alternative transformation approaches

Exploratory queries are temporary by default and do not belong in Git.

During exploration, query outputs may be shared for discussion and review without being added to the repository.

A query becomes a repository artifact only when it satisfies the promotion criteria defined below.

---

## SQL Promotion Criteria

Exploratory SQL may be promoted into dbt when all of the following conditions are met:

1. The query supports an approved analytical entity, KPI, control, or validation requirement.
2. The intended output grain is explicitly defined.
3. Required source fields and business rules are understood.
4. Duplicate and row-multiplication risks have been assessed.
5. Null and edge-case handling are defined.
6. The logic is reusable or required for a governed project deliverable.
7. The query has been independently validated against the source.
8. The appropriate dbt layer has been selected.
9. Required tests and documentation have been identified.
10. The work belongs to an approved work package.

Exploratory SQL must not be copied directly into dbt without review and restructuring.

Promoted SQL must follow project naming, formatting, testing, documentation, and materialization standards.

---

## dbt Layer Placement

Promoted transformation logic must be placed according to responsibility:

| Layer          | Responsibility                                                                          |
| -------------- | --------------------------------------------------------------------------------------- |
| Source         | Source declarations, metadata, freshness, and upstream traceability                     |
| Staging        | Source-aligned extraction, naming, casting, and minimal cleaning                        |
| Intermediate   | Reusable transformations, entity construction, deduplication, and shared business logic |
| Core           | Governed facts, dimensions, keys, relationships, and documented grains                  |
| Business Marts | Domain-oriented business metrics and analytical outputs                                 |
| BI Serving     | Stable, business-readable datasets optimized for Power BI                               |

Business logic must not be placed in a lower layer merely because it is convenient.

---

## Documentation Policy

Documentation is updated when information becomes sufficiently stable to be useful beyond the current exploration session.

### Documentation During a Work Package

Documentation may be updated during implementation when:

* a decision affects ongoing development
* a new risk or assumption must be recorded immediately
* the project scope or architecture changes
* other work depends on the documented rule
* delaying documentation would create ambiguity or rework

### Documentation at Work Package Completion

Before a work package is considered complete:

* durable findings must be recorded
* decisions and trade-offs must be documented
* model grains and business rules must be stated
* validation and reconciliation results must be captured
* known limitations must be recorded
* the project tracker must reflect the new delivery status
* the phase checkpoint must be updated when formal acceptance occurs

Documentation is not postponed until the entire phase is complete when individual work packages produce durable decisions.

---

## Document Responsibilities

| Document or Location                              | Purpose                                                                       |
| ------------------------------------------------- | ----------------------------------------------------------------------------- |
| `docs/project_blueprint.md`                       | Long-term objective, scope, architecture, and design principles               |
| `docs/project_management/project_tracker.md`      | Current phase, work-package status, focus, and upcoming milestones            |
| `docs/project_management/phase_checkpoints.md`    | Validated milestone evidence, decisions, limitations, and acceptance          |
| `docs/project_management/development_workflow.md` | Repository operating rules and artifact lifecycle                             |
| `docs/architecture/`                              | Target and implemented architecture documentation                             |
| `docs/decisions/`                                 | Significant architectural and technical decisions                             |
| `docs/data_quality/`                              | Durable source-quality findings, controls, limitations, and reconciliations   |
| dbt documentation                                 | Model purpose, grain, columns, tests, lineage, and implementation assumptions |
| Power BI documentation                            | Semantic model, measures, relationships, interactions, and report design      |

The Project Tracker must not be used as a detailed analysis notebook.

---

## Finding and Decision Standard

Important exploration results must be converted into structured knowledge before being documented.

Use the following format where appropriate:

### Finding

State what was observed in the source data.

### Evidence

Record the relevant metric, validation result, date range, or source reference.

### Impact

Explain how the finding affects feasibility, modeling, KPI design, data quality, or reporting.

### Decision

State the approved implementation or project response.

### Limitation

Record uncertainty, exclusions, or unresolved risk.

Raw query output alone is not sufficient documentation.

---

## Screenshot Policy

Screenshots are temporary by default.

### Screenshots Not Stored in Git

Do not retain screenshots that show only:

* exploratory query results
* temporary BigQuery tabs
* terminal troubleshooting
* transient errors
* intermediate formatting
* routine successful commands
* information already preserved more reliably as text or code

These screenshots may be shared during development but are not repository artifacts.

### Screenshots Eligible for Git

Screenshots may be retained when they provide durable visual evidence that cannot be represented adequately through text or code, including:

* final Power BI report pages
* final Power BI semantic-model relationships
* approved architecture diagrams
* dbt lineage or documentation views
* important user-interface configuration that is part of the reproduction guide
* final validation evidence required for the portfolio narrative

### Screenshot Timing

Final screenshots are captured only after:

* the underlying implementation is complete
* validation has passed
* naming and formatting are stable
* temporary or sensitive content has been removed
* the image has a defined documentation or portfolio purpose

Screenshots must not be captured merely because a task was completed.

---

## Screenshot Storage

Approved screenshots must be stored in a purpose-specific location.

Planned examples include:

```text
powerbi/screenshots/
docs/architecture/images/
docs/data_quality/evidence/
```

A directory should be created only when the first approved artifact for that directory exists.

Screenshot filenames must be descriptive and stable.

Examples:

```text
executive_overview.png
power_bi_semantic_model.png
dbt_lineage_business_marts.png
source_reconciliation_summary.png
```

Avoid filenames such as:

```text
screenshot1.png
final-final.png
image-new.png
```

---

## Validation Evidence Policy

Validation evidence should be committed only when it remains useful for review, reproduction, or portfolio defense.

Preferred evidence formats are:

1. dbt tests and singular test SQL
2. documented reconciliation logic
3. reproducible validation queries
4. concise Markdown result summaries
5. screenshots only when visual evidence is necessary

Text, tests, and executable code are preferred over screenshots.

---

## Git Branch Policy

* `main` represents the latest reviewed and accepted project state.
* Direct development on `main` is prohibited.
* Each logical change uses a dedicated branch.
* A branch should represent one work package or one coherent change.
* Unrelated cleanup must not be bundled into a feature branch.
* Completed branches are deleted after merge.

Examples:

```text
docs/add-development-workflow
profile/ga4-source-inventory
feat/add-ga4-sources
feat/build-staging-events
test/add-session-grain-tests
fix/prevent-transaction-duplication
```

---

## Commit Policy

Commits must be focused, understandable, and independently meaningful.

Preferred commit prefixes include:

```text
feat:
fix:
docs:
test:
refactor:
chore:
```

Examples:

```text
docs: define repository development workflow
feat: add GA4 source definitions
test: add transaction revenue reconciliation
fix: prevent duplicate purchase revenue
```

Avoid vague messages such as:

```text
update files
changes
final version
work in progress
```

---

## Pull Request Policy

Every Pull Request must:

* have one clear purpose
* explain the business or technical context
* identify changed artifacts
* include relevant validation
* state risks, assumptions, or limitations
* exclude secrets and local artifacts
* update documentation where required
* pass applicable quality checks before merge

Validation requirements depend on the change.

Documentation-only Pull Requests do not require a full `dbt build` unless dbt configuration or documented behavior has changed.

---

## Work Package Completion Criteria

A work package is complete only when:

1. The deliverable has been implemented.
2. Required validation has passed.
3. Results have been reconciled where applicable.
4. Durable findings and decisions have been documented.
5. Known limitations have been recorded.
6. The Project Tracker reflects the correct next state.
7. The relevant phase checkpoint has been updated when acceptance is required.
8. Changes have been reviewed and merged through a Pull Request.
9. Local `main` has been synchronized with `origin/main`.
10. The completed feature branch has been removed.

Implementation alone does not constitute completion.

---

## Phase Completion Criteria

A phase is complete only when:

* all required work packages are complete
* cross-layer reconciliation has passed
* unresolved risks are explicitly accepted or deferred
* required documentation is current
* the phase checkpoint records formal acceptance
* the Project Tracker identifies the next approved phase
* all phase changes have been merged into `main`

---

## Phase 2 Working Rule

During Source Feasibility and Profiling:

* exploratory SQL remains in BigQuery unless promoted
* screenshots may be shared for review but are not committed by default
* durable source findings are documented after validation
* source limitations and assumptions are recorded
* dbt implementation does not begin until the relevant feasibility decisions are approved
* source profiling must inform model grains, keys, tests, KPI feasibility, and cost controls

---

## Governance Review

This workflow may be updated when the project exposes a genuine process gap.

Changes must:

* solve a recurring or material problem
* avoid unnecessary process overhead
* remain consistent with the project architecture
* be reviewed through a dedicated Pull Request

The workflow should not be changed for isolated convenience.
