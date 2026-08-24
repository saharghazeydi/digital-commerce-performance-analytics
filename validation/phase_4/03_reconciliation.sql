/*
===============================================================================
Phase 4F - Session / Transaction Reconciliation
Project : Digital Commerce Performance Analytics

Purpose:
Validate consistency across the GA4 event-level, session-level and
transaction-level intermediate models.

Core reconciliation areas:
1. Transaction grain
2. Purchasing-session volume
3. Referential integrity
4. Purchase-flag consistency
5. Transaction counts by session
6. Revenue reconciliation
7. Source purchase-event reconciliation
8. Item-quantity reconciliation
9. Purchasing-user reconciliation
10. End-to-end model consistency
===============================================================================
*/


-- =============================================================================
-- CHECK 1: TRANSACTION COUNT RECONCILIATION
-- Expected:
--   transaction_rows = distinct_transaction_ids
-- =============================================================================

select
    count(*) as transaction_rows,
    count(distinct transaction_id) as distinct_transaction_ids
from `analytics_dev.int_ga4__transactions`;


-- =============================================================================
-- CHECK 2: PURCHASING SESSION RECONCILIATION
-- Quantify purchasing sessions and transactions.
-- =============================================================================

select
    count(distinct session_key) as purchasing_sessions,
    count(*) as transaction_count
from `analytics_dev.int_ga4__transactions`;


-- =============================================================================
-- CHECK 3: TRANSACTIONS WITHOUT MATCHING SESSION
-- Expected: 0
-- =============================================================================

select
    count(*) as unmatched_transactions
from `analytics_dev.int_ga4__transactions` as transactions
left join `analytics_dev.int_ga4__sessions` as sessions
    on transactions.session_key = sessions.session_key
where sessions.session_key is null;


-- =============================================================================
-- CHECK 4: TRANSACTIONS IN SESSIONS NOT FLAGGED AS PURCHASE
-- Expected: 0
-- =============================================================================

select
    count(*) as transactions_in_non_purchase_sessions
from `analytics_dev.int_ga4__transactions` as transactions
inner join `analytics_dev.int_ga4__sessions` as sessions
    on transactions.session_key = sessions.session_key
where sessions.has_purchase = false;


-- =============================================================================
-- CHECK 5: PURCHASE SESSIONS WITHOUT TRANSACTIONS
-- Expected: 0
-- =============================================================================

select
    count(*) as purchase_sessions_without_transactions
from `analytics_dev.int_ga4__sessions` as sessions
left join `analytics_dev.int_ga4__transactions` as transactions
    on sessions.session_key = transactions.session_key
where sessions.has_purchase = true
    and transactions.session_key is null;


-- =============================================================================
-- CHECK 6: SESSION TRANSACTION COUNT RECONCILIATION
-- Expected: 0 mismatches
-- =============================================================================

with transaction_counts as (

    select
        session_key,
        count(*) as actual_transaction_count
    from `analytics_dev.int_ga4__transactions`
    group by session_key

)

select
    count(*) as transaction_count_mismatches
from `analytics_dev.int_ga4__sessions` as sessions
left join transaction_counts
    on sessions.session_key = transaction_counts.session_key
where sessions.transaction_count
    != coalesce(transaction_counts.actual_transaction_count, 0);


-- =============================================================================
-- CHECK 7: REVENUE RECONCILIATION
-- Compare transaction-model revenue with session-model revenue.
-- Expected: values match
-- =============================================================================

select
    (
        select sum(purchase_revenue)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_model_revenue,

    (
        select sum(purchase_revenue)
        from `analytics_dev.int_ga4__sessions`
    ) as session_model_revenue;


-- =============================================================================
-- CHECK 8: SOURCE PURCHASE EVENT COUNT VS TRANSACTION MODEL
-- Expected:
--   selected_purchase_events = transaction_rows
-- =============================================================================

select
    (
        select count(*)
        from `analytics_dev.int_ga4__session_events`
        where is_first_valid_purchase
    ) as selected_purchase_events,

    (
        select count(*)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_rows;


-- =============================================================================
-- CHECK 9: SOURCE PURCHASE REVENUE VS TRANSACTION MODEL
-- Expected:
--   event_purchase_revenue = transaction_purchase_revenue
-- =============================================================================

select
    (
        select sum(coalesce(purchase_revenue, 0))
        from `analytics_dev.int_ga4__session_events`
        where is_first_valid_purchase
    ) as event_purchase_revenue,

    (
        select sum(purchase_revenue)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_purchase_revenue;


-- =============================================================================
-- CHECK 10: SOURCE ITEM QUANTITY VS TRANSACTION MODEL
-- Expected:
--   event_item_quantity = transaction_item_quantity
-- =============================================================================

select
    (
        select sum(coalesce(total_item_quantity, 0))
        from `analytics_dev.int_ga4__session_events`
        where is_first_valid_purchase
    ) as event_item_quantity,

    (
        select sum(total_item_quantity)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_item_quantity;


-- =============================================================================
-- CHECK 11: PER-SESSION REVENUE RECONCILIATION
-- Expected: 0 mismatches
-- =============================================================================

with transaction_revenue as (

    select
        session_key,
        sum(purchase_revenue) as transaction_revenue
    from `analytics_dev.int_ga4__transactions`
    group by session_key

)

select
    count(*) as session_revenue_mismatches
from `analytics_dev.int_ga4__sessions` as sessions
left join transaction_revenue
    on sessions.session_key = transaction_revenue.session_key
where abs(
    sessions.purchase_revenue
    - coalesce(transaction_revenue.transaction_revenue, 0)
) > 0.000001;


-- =============================================================================
-- CHECK 12: PER-SESSION ITEM QUANTITY RECONCILIATION
-- Expected: 0 mismatches
-- =============================================================================

with transaction_quantities as (

    select
        session_key,
        sum(total_item_quantity) as transaction_item_quantity
    from `analytics_dev.int_ga4__transactions`
    group by session_key

)

select
    count(*) as session_item_quantity_mismatches
from `analytics_dev.int_ga4__sessions` as sessions
left join transaction_quantities
    on sessions.session_key = transaction_quantities.session_key
where sessions.total_item_quantity
    != coalesce(transaction_quantities.transaction_item_quantity, 0);


-- =============================================================================
-- CHECK 13: PURCHASING USER RECONCILIATION
-- Expected: counts match
-- =============================================================================

select
    (
        select count(distinct user_pseudo_id)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_model_purchasing_users,

    (
        select count(distinct user_pseudo_id)
        from `analytics_dev.int_ga4__sessions`
        where has_purchase = true
    ) as session_model_purchasing_users;


-- =============================================================================
-- CHECK 14: END-TO-END RECONCILIATION SUMMARY
-- =============================================================================

select
    (
        select count(*)
        from `analytics_dev.int_ga4__sessions`
    ) as total_sessions,

    (
        select countif(has_purchase)
        from `analytics_dev.int_ga4__sessions`
    ) as purchasing_sessions,

    (
        select sum(transaction_count)
        from `analytics_dev.int_ga4__sessions`
    ) as session_model_transaction_count,

    (
        select count(*)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_model_transaction_count,

    (
        select sum(purchase_revenue)
        from `analytics_dev.int_ga4__sessions`
    ) as session_model_revenue,

    (
        select sum(purchase_revenue)
        from `analytics_dev.int_ga4__transactions`
    ) as transaction_model_revenue;