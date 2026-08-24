/*
===============================================================================
Phase 4F - Session Validation
Project : Digital Commerce Performance Analytics
Purpose : Validate session-level integrity before building marts.

QA sections:
1. Grain and integrity checks
2. Null checks
3. Duration and range checks
4. Event-count checks
5. User-session distribution checks
6. Business-rule and diagnostic checks

Expected grain:
One row per session_key
===============================================================================
*/


-- =============================================================================
-- SECTION 1: GRAIN AND INTEGRITY CHECKS
-- =============================================================================


-- Check 1: Reconcile session row count with distinct session keys
-- Expected:
--   session_row_count = distinct_session_key_count
--   duplicate_session_key_count = 0

select
    count(*) as session_row_count,
    count(distinct session_key) as distinct_session_key_count,
    count(*) - count(distinct session_key) as duplicate_session_key_count
from `analytics_dev.int_ga4__sessions`;


-- Check 2: Identify duplicated session keys
-- Expected: no rows returned

select
    session_key,
    count(*) as row_count
from `analytics_dev.int_ga4__sessions`
group by session_key
having count(*) > 1
order by row_count desc, session_key;


-- =============================================================================
-- SECTION 2: NULL CHECKS
-- =============================================================================


-- Check 3: Null critical session identifiers
-- Expected:
--   null_session_keys = 0
--   null_user_ids = 0
--   null_ga_session_ids = 0

select
    countif(session_key is null) as null_session_keys,
    countif(user_pseudo_id is null) as null_user_ids,
    countif(ga_session_id is null) as null_ga_session_ids
from `analytics_dev.int_ga4__sessions`;


-- Check 4: Null session timing fields
-- Expected:
--   null_session_dates = 0
--   null_session_start_timestamps = 0
--   null_session_end_timestamps = 0

select
    countif(session_date is null) as null_session_dates,
    countif(session_start_timestamp is null)
        as null_session_start_timestamps,
    countif(session_end_timestamp is null)
        as null_session_end_timestamps
from `analytics_dev.int_ga4__sessions`;


-- =============================================================================
-- SECTION 3: DURATION AND RANGE CHECKS
-- =============================================================================


-- Check 5: Session duration summary

select
    min(session_duration_seconds) as min_duration_seconds,
    max(session_duration_seconds) as max_duration_seconds,
    avg(session_duration_seconds) as avg_duration_seconds
from `analytics_dev.int_ga4__sessions`;


-- Check 6: Session duration quality indicators
-- Expected:
--   negative_duration_sessions = 0
-- Sessions over 24 hours are reviewed as tracking outliers.

select
    countif(session_duration_seconds < 0)
        as negative_duration_sessions,
    countif(session_duration_seconds = 0)
        as zero_duration_sessions,
    countif(session_duration_seconds > 1800)
        as sessions_over_30_minutes,
    countif(session_duration_seconds > 86400)
        as sessions_over_24_hours,
    round(
        100 * safe_divide(
            countif(session_duration_seconds > 86400),
            count(*)
        ),
        4
    ) as pct_sessions_over_24_hours
from `analytics_dev.int_ga4__sessions`;


-- Check 7: Session duration distribution

select
    duration_percentiles[offset(10)] as p10_duration_seconds,
    duration_percentiles[offset(25)] as p25_duration_seconds,
    duration_percentiles[offset(50)] as median_duration_seconds,
    duration_percentiles[offset(75)] as p75_duration_seconds,
    duration_percentiles[offset(90)] as p90_duration_seconds,
    duration_percentiles[offset(95)] as p95_duration_seconds,
    duration_percentiles[offset(99)] as p99_duration_seconds
from (
    select
        approx_quantiles(session_duration_seconds, 100)
            as duration_percentiles
    from `analytics_dev.int_ga4__sessions`
);


-- Check 8: Session timing consistency
-- Expected:
--   sessions_ending_before_start = 0
--   session_date_mismatches = 0

select
    countif(session_end_timestamp < session_start_timestamp)
        as sessions_ending_before_start,
    countif(session_date != date(session_start_timestamp))
        as session_date_mismatches
from `analytics_dev.int_ga4__sessions`;


-- =============================================================================
-- SECTION 4: EVENT-COUNT CHECKS
-- =============================================================================


-- Check 9: Event-count summary
-- Expected:
--   min_event_count >= 1
--   zero_event_sessions = 0
--   negative_event_sessions = 0

select
    min(event_count) as min_event_count,
    max(event_count) as max_event_count,
    avg(event_count) as avg_event_count,
    countif(event_count = 0) as zero_event_sessions,
    countif(event_count < 0) as negative_event_sessions
from `analytics_dev.int_ga4__sessions`;


-- Check 10: Event-count distribution

select
    event_count_percentiles[offset(10)] as p10_event_count,
    event_count_percentiles[offset(25)] as p25_event_count,
    event_count_percentiles[offset(50)] as median_event_count,
    event_count_percentiles[offset(75)] as p75_event_count,
    event_count_percentiles[offset(90)] as p90_event_count,
    event_count_percentiles[offset(95)] as p95_event_count,
    event_count_percentiles[offset(99)] as p99_event_count
from (
    select
        approx_quantiles(event_count, 100)
            as event_count_percentiles
    from `analytics_dev.int_ga4__sessions`
);


-- Check 11: Zero-duration sessions by event count
-- Zero-duration sessions with one event are usually expected.
-- Zero-duration sessions with multiple events require review.

select
    countif(
        session_duration_seconds = 0
        and event_count = 1
    ) as zero_duration_single_event_sessions,
    countif(
        session_duration_seconds = 0
        and event_count > 1
    ) as zero_duration_multi_event_sessions
from `analytics_dev.int_ga4__sessions`;


-- =============================================================================
-- SECTION 5: USER-SESSION DISTRIBUTION CHECKS
-- =============================================================================


-- Check 12: Sessions per user distribution

with sessions_per_user as (

    select
        user_pseudo_id,
        count(*) as session_count
    from `analytics_dev.int_ga4__sessions`
    group by user_pseudo_id

)

select
    count(*) as distinct_users,
    min(session_count) as min_sessions_per_user,
    max(session_count) as max_sessions_per_user,
    avg(session_count) as avg_sessions_per_user,
    approx_quantiles(session_count, 100)[offset(50)]
        as median_sessions_per_user,
    approx_quantiles(session_count, 100)[offset(95)]
        as p95_sessions_per_user,
    approx_quantiles(session_count, 100)[offset(99)]
        as p99_sessions_per_user
from sessions_per_user;


-- Check 13: Duplicate user-session combinations
-- Expected: no rows returned

select
    user_pseudo_id,
    ga_session_id,
    count(*) as row_count
from `analytics_dev.int_ga4__sessions`
group by
    user_pseudo_id,
    ga_session_id
having count(*) > 1
order by row_count desc;


-- =============================================================================
-- SECTION 6: BUSINESS-RULE AND DIAGNOSTIC CHECKS
-- =============================================================================


-- Check 14: Purchase flag consistency
-- Expected:
--   purchase_flag_transaction_mismatches = 0

select
    countif(
        has_purchase = true
        and transaction_count = 0
    ) as purchase_flag_without_transaction,
    countif(
        has_purchase = false
        and transaction_count > 0
    ) as transaction_without_purchase_flag
from `analytics_dev.int_ga4__sessions`;


-- Check 15: Purchase metric sanity
-- Expected:
--   negative_transaction_count_rows = 0
--   negative_purchase_revenue_rows = 0
--   negative_total_item_quantity_rows = 0
--   negative_unique_items_rows = 0
--   unique_items_exceeding_quantity_rows = 0

select
    countif(transaction_count < 0)
        as negative_transaction_count_rows,
    countif(purchase_revenue < 0)
        as negative_purchase_revenue_rows,
    countif(total_item_quantity < 0)
        as negative_total_item_quantity_rows,
    countif(unique_items < 0)
        as negative_unique_items_rows,
    countif(unique_items > total_item_quantity)
        as unique_items_exceeding_quantity_rows
from `analytics_dev.int_ga4__sessions`;


-- Check 16: Sessions with transaction count but zero revenue
-- Diagnostic output only.

select
    session_key,
    user_pseudo_id,
    session_date,
    transaction_count,
    purchase_revenue,
    total_item_quantity,
    unique_items
from `analytics_dev.int_ga4__sessions`
where
    transaction_count > 0
    and purchase_revenue = 0
order by session_date, session_key
limit 100;


-- Check 17: Inspect sessions longer than 24 hours
-- Diagnostic output only.

select
    session_key,
    user_pseudo_id,
    ga_session_id,
    session_date,
    session_start_timestamp,
    session_end_timestamp,
    session_duration_seconds,
    round(session_duration_seconds / 3600, 2)
        as session_duration_hours,
    event_count,
    transaction_count,
    purchase_revenue
from `analytics_dev.int_ga4__sessions`
where session_duration_seconds > 86400
order by session_duration_seconds desc;


-- Check 18: Inspect longest sessions
-- Diagnostic output only.

select
    session_key,
    user_pseudo_id,
    session_date,
    session_start_timestamp,
    session_end_timestamp,
    session_duration_seconds,
    round(session_duration_seconds / 3600, 2)
        as session_duration_hours,
    event_count,
    transaction_count,
    purchase_revenue
from `analytics_dev.int_ga4__sessions`
order by session_duration_seconds desc
limit 20;