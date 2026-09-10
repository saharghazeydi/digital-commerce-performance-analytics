
````markdown
# AI Project Continuity Log

## Project

Digital Commerce Performance Analytics

---

## Purpose of This File

This file is an internal append-only continuity log for the development of the Digital Commerce Performance Analytics project.

Its purpose is to preserve operational context across long ChatGPT conversations and prevent project decisions, investigations, unresolved issues, and next actions from being lost when a conversation becomes too large or a new conversation must be started.

This file is NOT intended to replace formal project documentation such as:

- `project_tracker.md`
- `phase_checkpoints.md`
- architecture documents
- ADRs
- validation reports
- model contracts
- README documentation

Those files remain the formal project documentation.

This file instead acts as a working project handoff record between development sessions.

---

# Append-Only Rule

This document is APPEND-ONLY.

After the initial baseline is created:

- Do not rewrite previous entries.
- Do not delete previous entries.
- Do not silently correct previous entries.
- Do not reorganize historical entries.
- Do not update an old conclusion in place.

If a previous assumption, conclusion, decision, or result later becomes incorrect, add a NEW log entry that explicitly supersedes it.

Example:

```text
Previous conclusion:
Unknown channel appeared to represent approximately 100K sessions.

Later investigation:
This was confirmed to originate from 94,553 sessions without a selected
acquisition event plus sessions with `(data deleted)` attribution.

Status:
Previous interpretation superseded by this log entry.
````

This preserves the analytical trail and prevents loss of reasoning.

---

# How to Use This File in a New Chat

When a new ChatGPT conversation is started, provide this file and use the following instruction:

```text
This file is the authoritative continuity log for my
Digital Commerce Performance Analytics project.

Read it completely before giving project guidance.

Do not reconstruct missing project history from assumptions.
Do not mix this project with any previous Olist or Commercial Analytics project.

Continue from the latest LOG ENTRY and its Current Status,
Open Issues, Decisions, and Next Approved Actions.

Historical entries are append-only.
If a later entry supersedes an earlier conclusion, use the later entry.
```

---

# Project Identity

Project:

`digital-commerce-performance-analytics`

dbt project:

`digital_commerce_performance_analytics`

This project is separate from previous portfolio projects.

In particular:

* It is NOT the previous Olist Commercial Analytics project.
* Olist architecture, tables, phases, assumptions, and modeling decisions must not be imported into this project.
* The repository state and documentation for this project are the source of truth.

---

# Core Technology Stack

Current project stack:

* Google Analytics 4 public ecommerce sample
* BigQuery
* dbt Core
* SQL
* Power BI
* Git
* GitHub
* Python environment for project tooling where required

Primary analytical architecture:

```text
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
```

---

# Important Architecture Principles Already Established

The project follows warehouse-first analytical modeling.

Business marts must consume governed warehouse entities instead of rebuilding upstream logic.

Important governed inputs include:

* `fct_sessions`
* `fct_transactions`
* `dim_date`
* `dim_channel`

Business marts must not independently reconstruct:

* session identity
* transaction identity
* transaction deduplication
* channel classification
* purchase logic
* core warehouse relationships

Power BI must consume approved serving models and governed metrics.

Power BI must not redefine upstream:

* sessionization
* attribution
* channel classification
* KPI contracts

---

# Historical Project Status Before Current Continuity Log

The project had already progressed through the main dbt analytical layers before this continuity file was created.

Important completed areas include:

* GA4 source feasibility
* staging architecture
* GA4 staging implementation
* intermediate GA4 session and transaction entities
* Core Warehouse
* Business Marts
* Executive KPI Layer
* BI Serving Layer
* Power BI semantic model
* substantial Power BI report development

The current active work is Power BI report completion and final project review.

---

# Power BI Report Structure

Current report pages:

1. Executive Overview
2. Acquisition & Channel Performance
3. Commerce Performance
4. Customer Behaviour & Segmentation

---

# Power BI Visual System

The report currently uses a restrained professional visual system.

General design principles:

* white background
* restrained blue palette
* minimal decorative styling
* no unnecessary visual borders
* no unnecessary shadows
* consistent spacing
* business-readable visual titles
* clean executive reporting style

Established typography:

### Page Title

```text
Segoe UI Semibold
18 pt
```

### Page Subtitle

```text
Segoe UI Regular
11 pt
```

### KPI Callout Value

```text
Segoe UI Semibold
22 pt
```

### KPI Label

```text
Segoe UI Regular
10 pt
```

### Chart Title

```text
Segoe UI Semibold
12 pt
```

### Legend

```text
Segoe UI Regular
9 pt
```

### X-Axis Values

```text
Segoe UI Regular
9 pt
```

### X-Axis Title

```text
Segoe UI Semibold
9 pt
```

### Y-Axis Values

```text
Segoe UI Regular
9 pt
```

### Y-Axis Title

```text
Segoe UI Semibold
9 pt
```

The same visual hierarchy has also been applied to tables and KPI visuals where applicable.

---

# Executive Overview Status

The Executive Overview page has received its main visual-polish pass and is considered substantially complete.

Header:

```text
Executive Overview
Digital commerce performance, trends and key business signals
```

Reporting slicer label:

```text
Reporting Period
```

Main KPIs:

* Purchase Revenue
* Total Sessions
* Purchasing Sessions
* Conversion Rate
* Total Transactions
* Average Order Value

Trend charts:

* Revenue Trend
* Conversion Trend

Revenue trend series:

* Daily Revenue
* 7D Avg

Conversion trend series:

* Daily Conversion Rate
* 7D Avg

Bottom comparison KPIs:

* Revenue vs Prior Week
* Conversion vs Prior Week

Former awkward labels based on "WoW Change %" were replaced with business-readable labels.

All-period values observed during report validation:

```text
Purchase Revenue       ≈ $307.64K
Total Sessions         ≈ 360K
Purchasing Sessions      4,033
Conversion Rate          1.12%
Total Transactions       4,451
Average Order Value      $69.12
Revenue vs Prior Week   -78.91%
Conversion vs Prior Week -70.84%
```

Reporting Period slicer was validated across:

```text
2020-11
2020-12
2021-01
```

Observed examples:

### 2020-11

```text
Revenue               ≈ $92.96K
Sessions              ≈ 108K
Purchasing Sessions     1,162
Conversion Rate         1.07%
Revenue vs Prior Week  85.11%
Conversion vs Prior Week 47.42%
```

### 2020-12

```text
Revenue               ≈ $158.17K
Sessions              ≈ 133K
Purchasing Sessions     2,030
Conversion Rate         1.52%
Revenue vs Prior Week  -56.29%
Conversion vs Prior Week -41.35%
```

### 2021-01

```text
Revenue               ≈ $56.51K
Sessions              ≈ 118K
Purchasing Sessions       841
Conversion Rate         0.71%
Revenue vs Prior Week  -78.91%
Conversion vs Prior Week -70.84%
```

The Reporting Period slicer behavior was confirmed as functioning.

---

# Acquisition & Channel Performance Status

Current report page under active review:

```text
Acquisition & Channel Performance
```

Subtitle:

```text
Traffic, conversion and session-attributed commercial performance by channel
```

Slicer:

```text
Reporting Period
```

Current KPI row:

* Channel Sessions
* Channel Purchasing Sessions
* Channel Conversion Rate
* Channel Session Contribution

Current all-period KPI values observed:

```text
Channel Sessions                ≈ 360K
Channel Purchasing Sessions       4,033
Channel Conversion Rate           1.12%
Channel Session Contribution    100.00%
```

Current charts:

* Sessions by Channel
* Conversion Rate by Channel
* Revenue Contribution by Channel
* Revenue per Session by Channel

Current layout:

```text
2 × 2 bar-chart grid
```

A Power BI Q&A visual that previously existed on this page was removed.

---

# Known Power BI Design Issue

`Channel Session Contribution = 100%` when all channels are selected.

This is mathematically correct but analytically weak because the contribution of all selected channels to all selected channels is necessarily 100%.

Current decision:

DO NOT redesign this KPI during the current acquisition data investigation.

Potential future replacements include:

* Top Channel Session Contribution
* Top Channel Revenue Contribution

Revisit during the business narrative / insight layer rather than making an ad hoc change now.

---

# Channel Scrollbar Investigation

An early visual-review assumption incorrectly treated the page as having approximately six channels.

Later screenshots confirmed that more channel categories exist.

Observed governed channel groups include:

* Direct
* Organic Search
* Paid Search
* Referral
* Email
* Affiliate
* Other
* Unknown

Decision:

* Keep chart scrollbars for now.
* Do not remove categories only to improve appearance.
* Do not apply Top N until channel semantics are validated.
* Do not filter `Unknown` out of the report.

Previous recommendation to remove scrollbars was withdrawn.

---

# Unknown Channel Issue

During Power BI review, the `Unknown` acquisition channel appeared unusually large.

Initial visual observation suggested approximately:

```text
Unknown ≈ 100K sessions
```

This was too large to dismiss as minor attribution noise.

The issue was therefore escalated from visual polish to data-model validation.

Power BI visual polish on this page was paused until the acquisition classification could be investigated.

---

# Governed Channel Dimension

Current governed `dim_channel` contains eight categories:

```text
1 Direct
2 Organic Search
3 Paid Search
4 Referral
5 Email
6 Affiliate
7 Other
8 Unknown
```

Definitions include:

### Other

```text
Sessions with a recognized medium that is not mapped to a governed channel.
```

### Unknown

```text
Sessions where acquisition information is missing or unavailable.
```

Important finding:

`dim_channel` itself only defines the governed lookup values.

It does NOT determine which session is assigned to each channel.

Therefore the large Unknown population was not caused by the dimension table itself.

---

# Current fct_sessions Channel Classification

The session warehouse logic assigns channel keys using `medium`.

Current mapping:

```sql
case
    when medium is null
        or medium = '(data deleted)'
        then 8

    when medium = '(none)'
        then 1

    when medium = 'organic'
        then 2

    when medium = 'cpc'
        then 3

    when medium = 'referral'
        then 4

    when medium = 'email'
        then 5

    when medium = 'affiliate'
        then 6

    else 7
end as channel_key
```

Interpretation:

```text
NULL medium          → Unknown
(data deleted)       → Unknown
(none)               → Direct
organic              → Organic Search
cpc                  → Paid Search
referral             → Referral
email                → Email
affiliate            → Affiliate
other populated value → Other
```

Important semantic concern:

The implementation effectively defines:

```text
Unknown = medium missing
```

This is not necessarily equivalent to:

```text
Unknown = acquisition information missing or unavailable
```

---

# GA4 Staging Acquisition Extraction

`stg_ga4__events` currently extracts acquisition fields from event parameters:

```sql
(
    select value.string_value
    from unnest(event_params)
    where key = 'source'
    limit 1
) as source,

(
    select value.string_value
    from unnest(event_params)
    where key = 'medium'
    limit 1
) as medium,

(
    select value.string_value
    from unnest(event_params)
    where key = 'campaign'
    limit 1
) as campaign
```

The project source window currently used in staging is:

```text
2020-11-01 through 2021-01-31
```

---

# Intermediate Acquisition Selection Logic

`int_ga4__session_events` assigns an acquisition priority to events.

Current logic:

```sql
case
    when nullif(trim(source), '') is not null
        and nullif(trim(medium), '') is not null
        and nullif(trim(campaign), '') is not null
        then 1

    when nullif(trim(source), '') is not null
        or nullif(trim(medium), '') is not null
        or nullif(trim(campaign), '') is not null
        then 2

    else 3
end as acquisition_priority
```

Then acquisition events are ordered by:

```sql
row_number() over (
    partition by session_key
    order by
        acquisition_priority,
        event_timestamp,
        event_name
) as acquisition_sequence_number
```

And selected using:

```sql
acquisition_sequence_number = 1
    and acquisition_priority < 3
    as is_selected_acquisition_event
```

Therefore:

* priority 1 = complete source + medium + campaign
* priority 2 = partially populated acquisition information
* priority 3 = no acquisition information

Only priorities 1 and 2 can become the selected acquisition event.

---

# int_ga4__sessions Acquisition Behavior

`int_ga4__sessions` joins the selected acquisition event to the governed session.

Relevant logic:

```sql
selected_acquisition_events.source as source,
selected_acquisition_events.medium as medium,
selected_acquisition_events.campaign as campaign
```

The join is:

```sql
left join selected_acquisition_events
    on sessions.session_key = selected_acquisition_events.session_key
```

Therefore, if a session has no selected acquisition event:

```text
source   = NULL
medium   = NULL
campaign = NULL
```

The downstream warehouse mapping then currently assigns that session to:

```text
Unknown
```

---

# Acquisition Profiling Results

Event-level staging profiling showed the most common acquisition combinations.

Examples observed:

```text
NULL / NULL / NULL
shop.googlemerchandisestore.com / referral / (referral)
google / organic / (organic)
(direct) / (none) / (direct)
<Other> / <Other> / <Other>
(data deleted) / (data deleted) / (data deleted)
google / cpc / <Other>
Partners / affiliate / Data Share Promo
Newsletter... / email / ...
```

This confirmed the source contains:

* explicit direct traffic
* organic traffic
* referral traffic
* paid search
* affiliate
* email
* placeholder or obfuscated values
* data-deleted attribution
* events without acquisition parameters

---

# Selected Acquisition Event Distribution

Profiling of `is_selected_acquisition_event` produced approximately:

```text
organic          101,750
referral          84,920
(none)            37,839
<Other>           25,364
cpc                7,683
(data deleted)     6,493
affiliate           1,329
email                 197
NULL                    1
```

Total sessions with a selected acquisition event:

```text
265,576
```

Total governed sessions:

```text
360,129
```

Therefore:

```text
360,129 - 265,576 = 94,553
```

sessions have NO selected acquisition event.

This became the main explanation for the unexpectedly large Unknown channel.

---

# Unknown Reconciliation

Current `mart_channel_daily` output showed:

```text
Unknown = 101,047 sessions
```

The warehouse totals reconcile as follows:

```text
Sessions without selected acquisition event ≈ 94,553
Selected `(data deleted)` sessions          ≈ 6,493
Selected session with NULL medium           ≈ 1
--------------------------------------------------
Expected Unknown                            ≈ 101,047
```

This matches the observed `Unknown` total.

Important conclusion:

The approximately 101K Unknown sessions are NOT caused by Power BI.

They originate in upstream session acquisition classification.

---

# Acquisition Coverage Validation Gap

Earlier intermediate validation confirmed:

```text
at most one selected acquisition event per session
```

It did NOT require:

```text
exactly one selected acquisition event per session
```

Therefore, the previous dbt validation could legitimately pass while 94,553 sessions had no selected acquisition event.

This is a coverage/semantic-validation gap rather than a dbt test failure.

---

# Sessions Without Acquisition — Validation

Sessions were grouped by whether they had a selected acquisition event.

Observed:

```text
No selected acquisition event  94,553
Selected acquisition event    265,576
Total                         360,129
```

This confirmed the numerical gap exactly.

---

# Referrer Analysis for Sessions Without Acquisition

For the 94,553 sessions without a selected acquisition event:

Initial session-level analysis showed:

```text
No referrer observed       92,637
At least one referrer       1,916
Total                      94,553
```

However, this was not sufficient for attribution because internal navigation can create a referrer after session entry.

A stronger validation was therefore performed using the first event of each session.

---

# First-Event Referrer Validation

For the 94,553 sessions without selected acquisition:

```text
No first-event referrer    94,321
Has first-event referrer      232
Total                       94,553
```

Therefore:

```text
99.75% approximately
```

of sessions without selected acquisition have no first-event referrer.

This is strong evidence that most of these sessions behave like direct-entry sessions.

However, this finding has NOT yet been implemented as a classification change.

---

# First-Event Referrer Breakdown

The 232 sessions with a first-event referrer were inspected.

Most observed referrers were internal Google Merchandise Store URLs.

Examples:

```text
https://shop.googlemerchandisestore.com/?
https://shop.googlemerchandisestore.com/Google+Redesign/New?
https://shop.googlemerchandisestore.com/Google+Redesign/Apparel/Mens?
https://shop.googlemerchandisestore.com/Google+Redesign/Lifestyle/Bags?
https://shop.googlemerchandisestore.com/basket.html?
https://shop.googlemerchandisestore.com/store.html?
```

Approximate breakdown derived during the investigation:

```text
Internal store referrers ≈ 217
External Google URL referrers ≈ 15
Total = 232
```

The external examples were mostly Google redirect URLs.

Important analytical decision:

Do NOT automatically classify those external Google referrers as Organic Search.

A Google referrer alone is insufficient to prove organic rather than paid or another redirect scenario.

---

# Session Event Types for Sessions Without Acquisition

The 94,553 sessions without acquisition were also checked for event activity.

Common events included:

```text
session_start
page_view
first_visit
...
```

Approximately:

```text
session_start ≈ 92,891 sessions
page_view     ≈ 88,628 sessions
first_visit   ≈ 73,315 sessions
```

At least one purchase-related event was also observed.

Conclusion:

These sessions are not junk rows that can simply be removed.

They represent real observed analytics sessions and must remain in the governed analytical population.

---

# Candidate Future Acquisition Classification

The following classification was identified as a plausible improved semantic model:

```text
Explicit `(direct)` / `(none)`
    → Direct

No usable acquisition
+ no first-event referrer
    → Direct

No usable acquisition
+ internal first-event referrer
    → Direct

(data deleted)
    → Unknown

No usable acquisition
+ external first-event referrer
    → Unknown unless stronger attribution evidence exists

organic
    → Organic Search

cpc
    → Paid Search

referral
    → Referral

email
    → Email

affiliate
    → Affiliate

other populated medium
    → Other
```

If implemented, approximate expected channel counts were estimated as:

```text
Organic Search  ≈ 101,750
Referral        ≈ 84,920
Direct          ≈ 132,377
Other           ≈ 25,364
Paid Search     ≈ 7,683
Unknown         ≈ 6,509
Affiliate       ≈ 1,329
Email           ≈ 197
--------------------------------
Total            360,129
```

IMPORTANT:

This classification is currently a CANDIDATE, not an approved project change.

No SQL implementation has yet been modified.

---

# Current Decision on Unknown

DO NOT currently:

* remove Unknown
* filter Unknown out in Power BI
* rename Unknown
* remap Unknown
* modify channel classification
* modify `dim_channel`
* modify `mart_channel_daily`
* modify `bi_channel_daily`

before the repository architecture and historical documentation review is complete.

Reason:

The project already contains several layers of formal documentation and validation.

Before modifying a previously governed core model, verify:

1. what business rule was originally approved,
2. why the original rule was selected,
3. whether the current behavior contradicts that rule,
4. what downstream models depend on the rule,
5. which tests and documentation would require updates,
6. whether the semantic benefit justifies the project impact.

---

# Important Modeling Boundary

If channel attribution is eventually corrected:

The fix must NOT be implemented in:

```text
mart_channel_daily
bi_channel_daily
Power BI
```

because those layers are consumers of governed upstream classification.

The correction must occur in the appropriate upstream session / warehouse attribution logic.

Current architecture specifically requires the channel mart to preserve the governed classification coming from `fct_sessions`.

---

# Separate Unknown Semantics in Segment Mart

`mart_segment_daily` also uses the label `Unknown`.

This is a separate semantic concept.

In the segment mart:

```text
Unknown device_category
Unknown country
```

represent missing or invalid segmentation values.

The P6F validation confirmed:

```text
Unknown device sessions = 0
Unknown country sessions = 2,882
```

These values are unrelated to the acquisition Unknown issue.

Do NOT modify segment-mart Unknown handling as part of channel-attribution work.

---

# P6F Segment Mart Status

`mart_segment_daily` grain:

```text
session_date
+ device_category
+ country
```

Validated mart rows:

```text
17,052
```

Validated totals:

```text
Sessions              360,129
Purchasing Sessions     4,033
Transactions             4,451
Purchase Revenue       307,640.0
```

The mart reconciles with `fct_sessions`.

Approved device categories:

* desktop
* mobile
* tablet
* Unknown

Country missing/invalid values are normalized to:

```text
Unknown
```

Commercial measures use session attribution.

---

# Core Warehouse Validation Historical Status

Phase 5 previously validated the following models:

* `dim_date`
* `dim_channel`
* `fct_sessions`
* `fct_transactions`

Historical Phase 5 validation reported:

```text
71 tests
71 passed
0 warnings
0 errors
0 skipped
```

The warehouse reconciliation confirmed:

```text
fct_sessions rows = 360,129
distinct session keys = 360,129
purchasing sessions = 4,033
transactions = 4,451
purchase revenue = 307,640
```

The session fact reconciled exactly with the intermediate session entity.

Important interpretation discovered during the current investigation:

A successful relationship test only proves that every session has a valid channel key.

It does NOT prove that the semantic classification represented by that key is optimal.

Therefore:

```text
referential validity ≠ semantic attribution validity
```

This distinction is important for future validation design.

---

# Repository Audit Started

A full repository audit was started before making any acquisition-classification changes.

Reason:

The user wants the final repository to be professionally organized and wants to avoid unnecessary edits to already completed project layers.

Current repository root:

```text
digital-commerce-performance-analytics/
│
├── .git/
├── .github/
├── digital_commerce_performance_analytics/
├── docs/
├── logs/
├── powerbi/
├── power_bi/
├── scripts/
├── validation/
│
├── .editorconfig
├── .env.example
├── .gitattributes
├── .gitignore
├── CONTRIBUTING.md
├── README.md
└── requirements.txt
```

---

# dbt Project Structure

Current dbt project folder:

```text
digital_commerce_performance_analytics/
├── analyses/
├── dbt_packages/
├── docs/
│   ├── business_requirements/
│   └── technical_design/
├── logs/
├── macros/
├── models/
│   ├── intermediate/
│   │   └── ga4/
│   ├── marts/
│   │   ├── business/
│   │   ├── core/
│   │   ├── executive/
│   │   └── serving/
│   └── staging/
│       └── ga4/
├── seeds/
├── snapshots/
├── target/
└── tests/
    ├── intermediate/
    │   └── ga4/
    ├── marts/
    │   ├── business/
    │   └── core/
    └── staging/
        └── ga4/
```

Initial architecture assessment:

The main model layering is coherent:

```text
staging
→ intermediate
→ core
→ business
→ executive
→ serving
```

No major architectural rewrite is currently justified.

---

# Generated dbt Folders

Observed generated/local folders include:

* `dbt_packages/`
* `logs/`
* `target/`

These are not core authored project logic.

Future repository cleanup must verify whether they are excluded from Git rather than deleting or changing them blindly.

---

# Root Documentation Inventory

Current root `/docs` structure:

```text
docs/
├── project_blueprint.md
│
├── architecture/
│   ├── ga4_base_extraction_contract.md
│   ├── ga4_staging_architecture.md
│   └── target_architecture.md
│
├── data_quality/
│   ├── .gitkeep
│   └── ga4_source_feasibility_assessment.md
│
├── decisions/
│   ├── ADR-001-dbt-core-bigquery.md
│   └── ADR-002-ga4-order-identity-and-deduplication.md
│
└── project_management/
    ├── development_workflow.md
    ├── phase_checkpoints.md
    ├── project_tracker.md
    └── AI_PROJECT_CONTINUITY.md
```

Current assessment:

The root documentation structure is meaningful and should not currently be reorganized.

---

# Separate dbt Documentation

The dbt project also contains:

```text
digital_commerce_performance_analytics/docs/
├── business_requirements/
└── technical_design/
```

This is separate from root-level repository documentation.

Do not merge these directories without first reviewing their purposes and existing references.

---

# Potential Repository Cleanup Items

The audit identified areas that require later inspection.

### Potential duplicate Power BI directories

Both exist:

```text
powerbi/
power_bi/
```

This may represent historical duplication.

Do NOT delete either yet.

Future action:

* compare contents
* determine canonical directory
* check references from README/documentation
* consolidate only after dependency review

### Root logs directory

There is:

```text
logs/
```

at repository root, in addition to dbt-generated:

```text
digital_commerce_performance_analytics/logs/
```

Future action:

Determine whether the root logs directory has a real project purpose or is accidental/generated.

Do not delete it until inspected.

---

# Important Development Principle Established in Current Session

Do not modify previously validated upstream models simply because a Power BI visual looks undesirable.

The correct sequence is:

```text
1. Identify the visual anomaly.
2. Trace the metric to its serving model.
3. Trace the serving model to its business mart.
4. Trace the mart to the warehouse.
5. Trace the warehouse to intermediate/staging logic.
6. Reconcile observed values.
7. Validate the intended business semantics.
8. Review prior architecture decisions.
9. Determine downstream impact.
10. Only then change code if justified.
11. Add regression tests.
12. Rebuild downstream models.
13. Revalidate.
14. Refresh Power BI.
```

This process was used for the Unknown channel investigation.

---

# Power BI Work Temporarily Paused

Final visual polish of the Acquisition & Channel Performance page is paused.

Do NOT yet perform:

* Top N channel filtering
* Unknown filtering
* scrollbar removal
* final channel sorting decisions based on incomplete attribution
* Channel Session Contribution KPI redesign
* final spacing polish that could be affected by channel count changes

Once the attribution question is resolved, resume the page.

Planned visual tasks after data validation:

* sort each chart descending by its own metric
* align chart widths/heights
* maintain consistent 2×2 layout
* maintain approximately consistent vertical spacing
* keep data labels off unless justified
* use subtle gridlines
* hide raw axis field names such as `channel_group`
* keep business-readable titles
* perform final QA with Reporting Period = All

---

# Current Repository Review Strategy

Repository audit order:

```text
1. Repository root
2. Documentation
3. dbt models
4. tests
5. validation
6. Power BI folders and assets
7. scripts/configuration
8. README and final repository presentation
9. final cleanup
```

Repository root has been reviewed at a high level.

Root documentation inventory has been collected.

No files have yet been deleted, renamed, or moved during this audit.

---

# Current Open Issues

The following items remain open.

## Open Issue 1 — Acquisition Unknown

Question:

Should sessions without usable acquisition and without an external first-event referrer remain Unknown or be governed as Direct?

Status:

Under review.

Evidence strongly suggests most are Direct-like, but no implementation change has been approved.

---

## Open Issue 2 — Historical Attribution Decision

Need to determine whether the current treatment of missing acquisition as Unknown was an explicit approved business decision or simply a technical fallback.

Relevant areas to inspect:

* architecture documentation
* intermediate session design
* Core Warehouse design
* model contracts
* validation documentation
* channel mapping tests
* possible ADRs

---

## Open Issue 3 — Missing Acquisition Coverage Test

Current validation confirms:

```text
maximum one acquisition event per session
```

but does not govern acquisition coverage semantics.

If attribution logic is changed, consider adding a regression or diagnostic test that explicitly measures:

```text
sessions with selected acquisition
sessions without selected acquisition
```

The appropriate expected behavior must first be defined.

---

## Open Issue 4 — Duplicate Power BI Directories

Need to inspect:

```text
powerbi/
power_bi/
```

before consolidation.

---

## Open Issue 5 — Root logs Directory

Need to determine whether root:

```text
logs/
```

is intentional.

---

## Open Issue 6 — Final Repository Cleanup

After Power BI completion:

* inspect unused directories
* inspect empty scaffold directories
* review `.gitignore`
* inspect generated artifacts
* verify documentation links
* review screenshot structure
* review Power BI file organization
* review README
* confirm final Git status
* remove internal-only continuity documentation if desired before publication

---

# Current Explicit Non-Actions

Until a later log entry changes this:

DO NOT:

* modify `fct_sessions` channel classification
* modify `int_ga4__sessions`
* modify `int_ga4__session_events`
* modify `stg_ga4__events`
* modify `dim_channel`
* modify `mart_channel_daily`
* modify `bi_channel_daily`
* filter Unknown in Power BI
* delete Power BI directories
* delete repository folders
* reorganize documentation
* rerun dbt solely because of the current investigation

The project is currently in investigation/audit mode.

---

# Current Next Action

Continue repository and documentation audit before making a decision on channel-classification changes.

Priority:

Inspect existing documents and model/test definitions related to:

```text
acquisition
channel classification
Unknown
Direct
selected acquisition event
fct_sessions channel mapping
```

Then decide whether:

### Option A

The existing Unknown behavior is an intentional accepted limitation.

Result:

Keep the model unchanged and document the limitation clearly.

### Option B

The existing behavior is a semantic classification defect.

Result:

Implement a controlled upstream correction with:

* updated model logic
* regression tests
* dependency-aware dbt build
* reconciliation
* updated formal documentation
* Power BI refresh
* visual QA

No decision between Option A and Option B has yet been approved.

---

# LOG ENTRY 001

## Date

2026-09-10

## Session Area

Power BI Acquisition Page / Channel Attribution Investigation / Repository Audit

## Status

Active investigation.

## Work Completed

During this session:

* reviewed Acquisition & Channel Performance visual structure
* identified unexpectedly large Unknown channel
* confirmed chart scrollbar was required because more channels existed than initially assumed
* paused cosmetic filtering decisions
* inspected `dim_channel`
* inspected session-to-channel CASE logic
* inspected `int_ga4__sessions`
* inspected `int_ga4__session_events`
* inspected `stg_ga4__events`
* profiled source / medium / campaign
* profiled selected acquisition events
* reconciled Unknown channel count
* identified 94,553 sessions with no selected acquisition event
* reconciled approximately 101,047 Unknown sessions
* inspected first-event referrer behavior
* found 94,321 of 94,553 missing-acquisition sessions have no first-event referrer
* inspected the remaining 232 first-event referrers
* found most are internal store URLs
* established that the issue originates upstream of Power BI
* decided not to alter attribution until existing project architecture and documentation are reviewed
* started repository structure audit
* reviewed root repository structure
* reviewed dbt project structure
* reviewed root documentation inventory
* identified potential `powerbi` / `power_bi` duplication
* identified root `logs` as an item requiring inspection
* introduced this append-only continuity log

## Key Finding

The Power BI Unknown channel value is not a visualization bug.

It originates from upstream channel classification.

The current system assigns sessions with missing `medium` to Unknown.

A large portion of those sessions have no selected acquisition event.

## Key Numerical Reconciliation

```text
Total governed sessions                   360,129
Sessions with selected acquisition        265,576
Sessions without selected acquisition      94,553
Unknown in mart_channel_daily             101,047
```

The difference is explained primarily by:

```text
No selected acquisition ≈ 94,553
(data deleted)          ≈ 6,493
other selected NULL case ≈ 1
```

## First-Event Evidence

```text
No first-event referrer    94,321
Has first-event referrer      232
Total                       94,553
```

This strongly suggests that many sessions currently classified Unknown are Direct-like.

This does NOT yet constitute an approved reclassification.

## Decision

No upstream model changes during this log entry.

Continue audit first.

## Next Action

Review existing project documentation and model contracts for the original acquisition/channel-classification intent.

---

# Future Log Entry Template

Do not modify previous log entries.

Copy the template below and append it to the END of this document whenever a meaningful project checkpoint, investigation result, decision, or correction occurs.

````markdown
# LOG ENTRY XXX

## Date

YYYY-MM-DD

## Session Area

[Phase / model / Power BI page / investigation]

## Starting Point

[What state the project was in when this work started.]

## Work Completed

- item
- item
- item

## Files Reviewed

- `path/file.sql`
- `path/file.yml`
- `path/file.md`

## Files Changed

- None

or:

- `path/file.sql`
- `path/file.yml`

## Validation Performed

- validation
- validation

## Important Results

```text
metric = value
metric = value
````

## Problems Found

* problem
* problem

## Decisions Made

* decision
* decision

## Supersedes

None

or:

This entry supersedes LOG ENTRY XXX regarding [specific conclusion].

## Open Issues

* issue
* issue

## Explicit Non-Actions

* do not ...
* do not ...

## Current Status

[Exact project state after this entry.]

## Next Approved Action

[Exact next task.]

## Handoff Note

A new ChatGPT conversation should continue from this entry and must not
change prior architecture or business logic without reviewing the relevant
project documentation and dependencies.

```

---

# Continuity Rule for Future Sessions

Whenever substantial work is completed, append ONE meaningful log entry rather than documenting every individual click or command.

Recommended moments for a new entry:

- completion of a subphase
- important model change
- important Power BI page completion
- discovery of a significant data-quality issue
- resolution of a significant issue
- architecture decision
- KPI definition change
- repository restructuring
- formal validation result
- major regression
- phase closeout
- handoff to a new ChatGPT conversation

Do not use this file as a minute-by-minute activity log.

The goal is to preserve decisions and state, not noise.

---

# End of Initial Baseline

This baseline captures the project state known at the time the continuity system was introduced.

All future updates must be appended below this point.
```

### از این به بعد چطور استفاده می‌کنیم؟

خیلی ساده. **دیگر قسمت‌های بالا را دست نمی‌زنی.** حتی اگر مثلاً فردا بفهمیم تحلیل من درباره Direct اشتباه بوده، نمی‌رویم آن قسمت را اصلاح کنیم. در انتهای فایل می‌نویسیم:

```markdown
# LOG ENTRY 002

...

## Supersedes

LOG ENTRY 001 regarding the interpretation of sessions without acquisition.

## New Finding

...
```
---

## GA4 Channel Attribution Semantic Fix — Completed

### Status

Completed and validated.

Git commit:

`fde130e` — `fix: refine GA4 session channel attribution`

### Problem Identified

The original channel-classification logic in `fct_sessions` classified sessions primarily from `medium`.

This caused sessions with no selected acquisition event to be classified as `Unknown`, resulting in approximately 101K Unknown sessions (~28% of all sessions).

Investigation showed that this was not a staging or session-grain failure. The upstream GA4 session logic intentionally allows sessions with no usable acquisition event.

### Diagnostic Findings

Total sessions:

`360,129`

Sessions with a selected acquisition event:

`265,576`

Sessions without a selected acquisition event:

`94,553`

For the 94,553 sessions without selected acquisition:

- `94,321` had no first-event referrer.
- `217` had an internal referrer from `shop.googlemerchandisestore.com`.
- `15` had an external referrer.

Therefore, 94,538 sessions had strong Direct-like evidence and were reclassified as Direct.

### Governed Channel Rule

The current business rule is:

- Selected acquisition containing `(data deleted)` → `Unknown`
- Explicit `(direct)` / `(none)` → `Direct`
- `organic` → `Organic Search`
- `cpc` → `Paid Search`
- `referral` → `Referral`
- `email` → `Email`
- `affiliate` → `Affiliate`
- Other populated acquisition medium → `Other`
- Selected acquisition with no usable medium → `Unknown`
- No selected acquisition + no landing-page referrer → `Direct`
- No selected acquisition + internal `shop.googlemerchandisestore.com` referrer → `Direct`
- No selected acquisition + external referrer → `Unknown`

Power BI must not reconstruct or override this classification.

### Implementation Changes

`int_ga4__sessions.sql`

Added:

- `landing_page_referrer`
- `has_selected_acquisition`

`fct_sessions.sql`

Updated the governed `channel_key` classification to distinguish selected acquisition from sessions without usable acquisition and to use landing-page referrer evidence for the latter.

`assert_fct_sessions_channel_mapping_consistent.sql`

Updated to validate the new channel-classification contract.

### Validation

Targeted downstream build:

`dbt build --select int_ga4__sessions+`

Result:

`PASS=316 WARN=0 ERROR=0 SKIP=0`

Final validated channel distribution:

| Channel | Sessions | Share |
|---|---:|---:|
| Direct | 132,377 | 36.76% |
| Organic Search | 101,750 | 28.25% |
| Referral | 84,919 | 23.58% |
| Other | 25,364 | 7.04% |
| Paid Search | 7,683 | 2.13% |
| Unknown | 6,510 | 1.81% |
| Affiliate | 1,329 | 0.37% |
| Email | 197 | 0.05% |

Total remains exactly:

`360,129 sessions`

The one-session difference from the initial expected distribution was investigated and explained by:

- `source = (data deleted)`
- `medium = referral`
- `campaign = (referral)`

The governed rule intentionally gives `(data deleted)` precedence, so this session correctly remains `Unknown`.

### Power BI Validation

The refreshed `Acquisition & Channel Performance` page reflects the corrected warehouse classification.

`Sessions by Channel` now ranks:

1. Direct
2. Organic Search
3. Referral

The large previous Unknown population is no longer present.

### Important Continuity Decision

Do not reopen or redesign the channel-attribution logic unless new evidence shows a real semantic problem.

`Unknown = 6,510 (1.81%)` is the current validated and accepted result.

The remaining Power BI work should continue from this validated semantic baseline.

---

# LOG ENTRY 002

## Date

2026-09-10

## Session Area

Phase 10 — Power BI Report Completion and Closeout

## Starting Point

Channel attribution had been corrected and validated through commit `fde130e`.
The Power BI report had been refreshed against the corrected serving layer and final report-level QA was still in progress.

## Work Completed

- completed semantic and data validation for Executive Overview
- completed semantic and data validation for Acquisition & Channel Performance
- completed semantic and data validation for Commerce Performance
- completed semantic and data validation for Customer Behaviour & Segmentation
- validated Reporting Period slicer behavior across Pages 1–3
- confirmed Page 4 should remain full-observation-period because `bi_user_behavior` is user-grain and is not governed by the standard daily date relationship
- updated the Page 4 subtitle to communicate the full observation period explicitly
- completed report-level usability QA
- completed rendering and responsiveness review
- confirmed no report-level rendering or interaction errors
- saved and committed the final Power BI report artifact

## Files Changed

- `power_bi/digital_commerce_performance_analytics.pbix`
- `docs/project_management/project_tracker.md`
- `docs/project_management/AI_PROJECT_CONTINUITY.md`

## Validation Performed

- Pages 1–3 Reporting Period slicer QA passed
- Page 4 user KPI values reconciled to `bi_user_behavior`
- Page 4 device metrics reconciled to `bi_segment_daily`
- all four report pages rendered successfully
- no unexpected blank visuals or report-level errors observed

## Important Results

```text
Observed Users                         270,154
Purchasing Users                        3,702
Multi-Session Users                    47,364
Repeat Purchasing Session Users           284

Desktop Sessions                      208,942
Mobile Sessions                       143,185
Tablet Sessions                         8,002

Decisions Made
Page 4 will not use the standard Reporting Period slicer.
Page 4 represents full-observation-period user behaviour and segmentation.
No additional Power BI features will be added during Phase 10 closeout.
Report development is complete through P10K.
P10L is the current active work package.
Git Checkpoints
fde130e — fix: refine GA4 session channel attribution
52d7238 — feat: finalize Power BI performance report
Supersedes

This entry supersedes the prior continuity state that described Power BI report work as still active after the channel-attribution fix.

Current Status

Phase 10 report implementation is complete through P10K.

P10L — Report Handoff & Phase Closeout is in progress.

Next Approved Action

Complete Phase 10 handoff documentation, repository closeout, and readiness checks before formally closing Phase 10 and beginning Phase 11.

Handoff Note

A new ChatGPT conversation should continue from P10L and must treat the Power BI report and corrected channel-attribution semantics as the validated baseline.