/*
===============================================================================
Phase 4F - Transaction Validation
Project : Digital Commerce Performance Analytics
Purpose : Validate transaction-level integrity before building marts.

QA sections:
1. Grain and integrity checks
2. Null checks
3. Referential integrity checks
4. Monetary and quantity checks
5. Distribution checks
6. Diagnostic checks

Expected grain:
One row per valid transaction_id
===============================================================================
*/


-- =============================================================================
-- SECTION 1: GRAIN AND INTEGRITY CHECKS
-- =============================================================================


-- Check 1: Reconcile row count with distinct transaction IDs
-- Expected:
--   transaction_row_count = distinct_transaction_id_count
--   duplicate_transaction_id_count = 0

select
    count(*) as transaction_row_count,
    count(distinct transaction_id) as distinct_transaction_id_count,
    count(*) - count(distinct transaction_id)
        as duplicate_transaction_id_count
from `analytics_dev.int_ga4__transactions`;


-- Check 2: Identify duplicated transaction IDs
-- Expected: no rows returned

select
    transaction_id,
    count(*) as row_count
from `analytics_dev.int_ga4__transactions`
group by transaction_id
having count(*) > 1
order by row_count desc, transaction_id;


-- =============================================================================
-- SECTION 2: NULL CHECKS
-- =============================================================================


-- Check 3: Null critical identifiers
-- Expected:
--   null_transaction_ids = 0
--   null_session_keys = 0
--   null_user_ids = 0

select
    countif(transaction_id is null) as null_transaction_ids,
    countif(session_key is null) as null_session_keys,
    countif(user_pseudo_id is null) as null_user_ids
from `analytics_dev.int_ga4__transactions`;


-- Check 4: Null transaction timing fields
-- Expected:
--   null_transaction_dates = 0
--   null_transaction_timestamps = 0

select
    countif(transaction_date is null) as null_transaction_dates,
    countif(transaction_timestamp is null)
        as null_transaction_timestamps
from `analytics_dev.int_ga4__transactions`;


-- =============================================================================
-- SECTION 3: REFERENTIAL INTEGRITY CHECKS
-- =============================================================================


-- Check 5: Transactions without a matching session
-- Expected: 0

select
    count(*) as transactions_without_matching_session
from `analytics_dev.int_ga4__transactions` as transactions
left join `analytics_dev.int_ga4__sessions` as sessions
    on transactions.session_key = sessions.session_key
where sessions.session_key is null;


-- Check 6: Transaction and session user mismatch
-- Expected: 0

select
    count(*) as transaction_session_user_mismatches
from `analytics_dev.int_ga4__transactions` as transactions
inner join `analytics_dev.int_ga4__sessions` as sessions
    on transactions.session_key = sessions.session_key
where transactions.user_pseudo_id != sessions.user_pseudo_id;


-- Check 7: Transaction timestamp outside session boundaries
-- Expected: ideally 0
-- Returned rows require investigation before being classified as failures.

select
    count(*) as transactions_outside_session_window
from `analytics_dev.int_ga4__transactions` as transactions
where
    transactions.transaction_timestamp
        < transactions.session_start_timestamp
    or transactions.transaction_timestamp
        > transactions.session_end_timestamp;


-- =============================================================================
-- SECTION 4: MONETARY AND QUANTITY CHECKS
-- =============================================================================


-- Check 8: Monetary value summary

select
    count(*) as transaction_count,
    sum(purchase_revenue) as total_purchase_revenue,
    sum(refund_value) as total_refund_value,
    sum(shipping_value) as total_shipping_value,
    sum(tax_value) as total_tax_value,
    avg(purchase_revenue) as avg_purchase_revenue,
    min(purchase_revenue) as min_purchase_revenue,
    max(purchase_revenue) as max_purchase_revenue
from `analytics_dev.int_ga4__transactions`;


-- Check 9: Invalid negative monetary values
-- Negative refunds may be valid depending on source-system semantics.
-- Purchase, shipping and tax values are expected to be non-negative.

select
    countif(purchase_revenue < 0) as negative_purchase_revenue_rows,
    countif(shipping_value < 0) as negative_shipping_value_rows,
    countif(tax_value < 0) as negative_tax_value_rows,
    countif(refund_value < 0) as negative_refund_value_rows
from `analytics_dev.int_ga4__transactions`;


-- Check 10: Quantity sanity
-- Expected:
--   negative_total_item_quantity_rows = 0
--   negative_unique_items_rows = 0
--   unique_items_exceeding_quantity_rows = 0

select
    countif(total_item_quantity < 0)
        as negative_total_item_quantity_rows,
    countif(unique_items < 0)
        as negative_unique_items_rows,
    countif(unique_items > total_item_quantity)
        as unique_items_exceeding_quantity_rows,
    countif(total_item_quantity = 0)
        as zero_quantity_transaction_rows
from `analytics_dev.int_ga4__transactions`;


-- =============================================================================
-- SECTION 5: DISTRIBUTION CHECKS
-- =============================================================================


-- Check 11: Purchase revenue distribution

select
    revenue_percentiles[offset(0)] as min_revenue,
    revenue_percentiles[offset(25)] as p25_revenue,
    revenue_percentiles[offset(50)] as median_revenue,
    revenue_percentiles[offset(75)] as p75_revenue,
    revenue_percentiles[offset(90)] as p90_revenue,
    revenue_percentiles[offset(95)] as p95_revenue,
    revenue_percentiles[offset(99)] as p99_revenue,
    revenue_percentiles[offset(100)] as max_revenue
from (
    select
        approx_quantiles(purchase_revenue, 100)
            as revenue_percentiles
    from `analytics_dev.int_ga4__transactions`
);


-- Check 12: Transactions per session distribution
-- Sessions with multiple transactions are valid but should be quantified.

with transactions_per_session as (

    select
        session_key,
        count(*) as transaction_count
    from `analytics_dev.int_ga4__transactions`
    group by session_key

)

select
    count(*) as purchasing_sessions,
    min(transaction_count) as min_transactions_per_session,
    max(transaction_count) as max_transactions_per_session,
    avg(transaction_count) as avg_transactions_per_session,
    countif(transaction_count > 1) as sessions_with_multiple_transactions
from transactions_per_session;


-- =============================================================================
-- SECTION 6: DIAGNOSTIC CHECKS
-- =============================================================================


-- Check 13: Inspect highest-value transactions
-- Diagnostic output only.

select
    transaction_id,
    session_key,
    user_pseudo_id,
    transaction_date,
    purchase_revenue,
    refund_value,
    shipping_value,
    tax_value,
    total_item_quantity,
    unique_items
from `analytics_dev.int_ga4__transactions`
order by purchase_revenue desc
limit 20;


-- Check 14: Inspect transactions with zero revenue or zero quantity
-- Rows returned require interpretation against GA4 measurement behavior.

select
    transaction_id,
    session_key,
    transaction_date,
    purchase_revenue,
    total_item_quantity,
    unique_items
from `analytics_dev.int_ga4__transactions`
where
    purchase_revenue = 0
    or total_item_quantity = 0
order by transaction_date, transaction_id
limit 100;