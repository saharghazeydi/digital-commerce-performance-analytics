# Contributing Guidelines

## Branching Strategy

Development work must be completed on a dedicated branch rather than directly on `main`.

Recommended branch names:

- `feature/<short-description>`
- `fix/<short-description>`
- `docs/<short-description>`
- `refactor/<short-description>`
- `test/<short-description>`
- `chore/<short-description>`

## Commit Convention

Commits must be small, focused, and written in the imperative style.

Examples:

- `feat: add GA4 source configuration`
- `test: add session grain validation`
- `docs: document channel attribution logic`
- `fix: prevent duplicate transaction revenue`
- `refactor: simplify session construction`
- `chore: configure dbt development environment`

## Validation Requirements

Before work is merged:

1. dbt parsing must succeed.
2. Modified models must build successfully.
3. Relevant tests must pass.
4. Documentation must be updated.
5. KPI outputs must reconcile where applicable.
6. No credentials or local artifacts may be committed.

## Pull Requests

Each pull request must explain:

- the purpose of the change
- the models or documentation affected
- the validation performed
- known limitations or follow-up work