# Contributing Guidelines

## Purpose

These guidelines define how changes are developed, validated, documented, reviewed, and merged within the Digital Commerce Performance Analytics repository.

All contributors must also follow the repository operating standard documented in:

```text
docs/project_management/development_workflow.md
```

The development workflow is the authoritative reference for artifact handling, exploratory analysis, SQL promotion, documentation timing, validation evidence, screenshots, and work-package completion.

---

## Branching Strategy

Development must be completed on a dedicated branch rather than directly on `main`.

The `main` branch represents the latest reviewed and accepted project state.

Each branch should contain one approved work package, release package, or other coherent logical change.

Recommended branch names include:

```text
feat/<short-description>
fix/<short-description>
docs/<short-description>
refactor/<short-description>
test/<short-description>
chore/<short-description>
profile/<short-description>
```

Examples:

```text
docs/add-development-workflow
profile/ga4-source-inventory
feat/add-ga4-source-definitions
feat/build-staging-events
test/add-session-grain-validation
fix/prevent-transaction-duplication
```

Unrelated changes must not be combined in the same branch.

Completed branches should be deleted after their Pull Requests are merged.

---

## Commit Convention

Commits must be small, focused, understandable, and independently meaningful.

Commit messages should use an appropriate conventional prefix:

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
feat: add GA4 source configuration
test: add session grain validation
docs: define repository development workflow
docs: document channel attribution logic
fix: prevent duplicate transaction revenue
refactor: simplify session construction
chore: configure dbt development environment
```

Avoid vague commit messages such as:

```text
update files
changes
final version
work in progress
```

---

## Exploration and Repository Artifacts

Exploratory SQL and temporary query outputs are not committed by default.

Exploration may be performed in BigQuery to:

- inspect source structure
- profile data volume and date coverage
- investigate event names and nested fields
- assess grains and identifiers
- test data-quality hypotheses
- evaluate KPI and entity feasibility
- compare transformation approaches

Exploratory SQL may be promoted into the repository only after it has been validated, assigned to an approved deliverable, and restructured for the appropriate dbt layer.

Temporary screenshots, query exports, local notes, credentials, generated artifacts, and troubleshooting evidence must not be committed.

Detailed artifact rules are maintained in:

```text
docs/project_management/development_workflow.md
| `docs/project_management/reproduction_guide.md` | Environment setup, BigQuery/dbt configuration, execution, validation, and Power BI reproduction guidance |
```

---

## Documentation Requirements

Documentation must be updated when a change creates or modifies durable project knowledge.

This includes:

- business rules
- model grains
- analytical entities
- KPI definitions
- assumptions
- limitations
- architecture decisions
- data-quality findings
- reconciliation results
- project delivery status

Documentation responsibilities are divided as follows:

| Document or Location | Responsibility |
|---|---|
| `docs/project_blueprint.md` | Long-term scope, architecture, and design principles |
| `docs/project_management/project_tracker.md` | Current delivery status and upcoming work |
| `docs/project_management/phase_checkpoints.md` | Validated milestones, evidence, decisions, and acceptance |
| `docs/project_management/development_workflow.md` | Repository operating rules and artifact lifecycle |
| `docs/architecture/` | Target and implemented architecture |
| `docs/decisions/` | Significant architectural and technical decisions |
| `docs/data_quality/` | Durable data-quality findings and controls |
| dbt documentation | Models, grains, columns, tests, assumptions, and lineage |
| Power BI documentation and assets | Semantic model, measures, relationships, report behaviour, canonical PBIX, and approved report screenshots |

The Project Tracker must not be used as an exploratory analysis notebook.

---

## Validation Requirements

Validation depends on the type and scope of the change.

Before work is merged, complete all applicable checks:

1. Review all changed files.
2. Run `git diff --check`.
3. Confirm documentation is current.
4. Confirm no credentials, secrets, generated files, or local artifacts are included.
5. Confirm dbt project parsing succeeds when dbt files or configuration are affected.
6. Build relevant dbt models when transformation logic is affected.
7. Run relevant dbt tests.
8. Reconcile source, model, KPI, or reporting outputs where applicable.
9. Record known risks, assumptions, limitations, or intentionally deferred future enhancements.
10. Confirm the change belongs to the approved work package.

Documentation-only changes do not require a full `dbt build` unless they modify dbt configuration or document behaviour that should be technically verified.

---

## Pull Requests

Every Pull Request must have one clear purpose.

The Pull Request description must explain:

- the business or technical context
- the changes made
- the validation performed
- the relevant evidence
- known risks, assumptions, or limitations
- related documentation or decision records

Evidence should be durable and reproducible where possible.

Preferred evidence includes:

- dbt tests
- validation queries
- reconciliation results
- documented findings
- approved diagrams
- final screenshots where visual evidence is necessary

Temporary exploratory outputs and troubleshooting screenshots should not be attached.

---

## Review Expectations

Before merge, confirm that:

- the Pull Request contains one coherent change
- changed artifacts belong to the approved work package
- implementation and documentation are consistent
- durable findings and decisions are recorded
- applicable validation has passed
- repository standards are followed
- the next project state or formal project closure is clear

---

## Work Package Completion

A work package is complete only when:

1. The deliverable has been implemented.
2. Required validation has passed.
3. Results have been reconciled where applicable.
4. Durable findings and decisions have been documented.
5. Known limitations have been recorded.
6. The Project Tracker reflects the correct next state or formal project closure.
7. The relevant phase checkpoint has been updated when required.
8. The changes have been reviewed and merged through a Pull Request.
9. Local `main` has been synchronized with `origin/main`.
10. The completed feature branch has been removed.

Implementation alone does not constitute completion.