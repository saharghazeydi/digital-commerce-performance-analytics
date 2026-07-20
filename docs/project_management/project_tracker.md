# Project Tracker

## Project

Digital Commerce Performance Analytics

## Status Definitions

- **Planned** — approved but not started
- **In Progress** — currently under development
- **Blocked** — cannot continue because of an unresolved dependency
- **Complete** — implemented and validated
- **Deferred** — intentionally postponed

## Phase 0 — Project Foundation

| ID | Work Package | Deliverable | Status | Validation | Pull Request |
|---|---|---|---|---|---|
| P0A | Environment Audit | Python, Git, and VS Code environment reviewed | Complete | Version and path checks | — |
| P0B | Project Blueprint | Business objective, scope, architecture principles, and testing strategy documented | Complete | Manual documentation review | — |
| P0C | Repository Governance | Repository standards, templates, configuration files, and directory structure established | Complete | Repository file audit | Initial baseline |
| P0D | GitHub Workflow Validation | Feature branch, commit, push, pull request, and merge workflow validated | Complete | Clean local and remote state | PR #1 |
| P0E | Architecture and Documentation Audit | Target architecture, project tracker, phase checkpoints, and initial decision record documented | In Progress | Documentation and repository audit | Pending |

## Phase 1 — dbt Development Environment

| ID | Work Package | Deliverable | Status | Validation | Pull Request |
|---|---|---|---|---|---|
| P1A | Python Virtual Environment | Isolated `.venv` created and activated | Planned | Python and pip path checks | Pending |
| P1B | dbt Installation | dbt Core and BigQuery adapter installed | Planned | `dbt --version` | Pending |
| P1C | dbt Project Initialization | Standard dbt project scaffold created | Planned | Project structure review | Pending |
| P1D | Local dbt Configuration | Local profile and environment configuration established | Planned | Configuration review | Pending |
| P1E | BigQuery Authentication | Local development credentials configured securely | Planned | Authentication check | Pending |
| P1F | dbt Connection Validation | dbt connected successfully to BigQuery | Planned | `dbt debug` | Pending |

## Phase 2 — Analytics Engineering Architecture

| ID | Work Package | Deliverable | Status | Validation | Pull Request |
|---|---|---|---|---|---|
| P2A | Source Configuration | GA4 BigQuery source definitions created | Planned | Source freshness and accessibility checks | Pending |
| P2B | Model Layer Design | Staging, intermediate, mart, and BI layer design finalized | Planned | Architecture review | Pending |
| P2C | Naming and SQL Standards | Model, column, SQL, and documentation conventions established | Planned | Standards review | Pending |
| P2D | Testing Strategy | Generic, singular, reconciliation, and business tests designed | Planned | Test coverage review | Pending |
| P2E | Documentation Strategy | dbt documentation and project documentation responsibilities defined | Planned | Documentation review | Pending |

## Future Delivery Phases

The detailed work packages for the following phases will be added before development begins:

- GA4 source profiling
- staging models
- session and transaction modeling
- dimensions and facts
- business marts
- executive KPI layer
- BI serving layer
- Power BI semantic model
- Power BI dashboards
- final reconciliation
- portfolio packaging

## Current Focus

**P0E — Architecture and Documentation Audit**

## Next Approved Work Package

**P1A — Python Virtual Environment**