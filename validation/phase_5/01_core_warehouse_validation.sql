/*
===============================================================================
Phase 5 - Core Warehouse Validation
Project : Digital Commerce Performance Analytics
Purpose : Validate warehouse grains, keys, and referential integrity.

Core models:
- dim_date
- dim_channel
- fct_sessions
- fct_transactions
===============================================================================
*/


-- =============================================================================
-- CHECK 1: DATE DIMENSION GRAIN
-- Expected:
--   row_count = distinct_date_count
--   duplicate_date_count = 0
-- =============================================================================

select
    count(*) as row_count,
    count(distinct date_day) as distinct_date_count,
    count(*) - count(distinct date_day) as duplicate_date_count
from `analytics_dev.dim_date`;


-- =============================================================================
-- CHECK 2: CHANNEL DIMENSION GRAIN
-- Expected:
--   row_count = distinct_channel_key_count
--   duplicate_channel_key_count = 0
-- =============================================================================

select
    count(*) as row_count,
    count(distinct channel_key) as distinct_channel_key_count,
    count(*) - count(distinct channel_key) as duplicate_channel_key_count
from `analytics_dev.dim_channel`;


-- =============================================================================
-- CHECK 3: SESSION FACT GRAIN
-- Expected:
--   session_row_count = distinct_session_count
--   duplicate_session_count = 0
-- =============================================================================

select
    count(*) as session_row_count,
    count(distinct session_key) as distinct_session_count,
    count(*) - count(distinct session_key) as duplicate_session_count
from `analytics_dev.fct_sessions`;


-- =============================================================================
-- CHECK 4: TRANSACTION FACT GRAIN
-- Expected:
--   transaction_row_count = distinct_transaction_count
--   duplicate_transaction_count = 0
-- =============================================================================

select
    count(*) as transaction_row_count,
    count(distinct transaction_id) as distinct_transaction_count,
    count(*) - count(distinct transaction_id)
        as duplicate_transaction_count
from `analytics_dev.fct_transactions`;


-- =============================================================================
-- CHECK 5: SESSION DATE REFERENTIAL INTEGRITY
-- Expected: 0
-- =============================================================================

select
    count(*) as sessions_without_valid_date
from `analytics_dev.fct_sessions` as sessions
left join `analytics_dev.dim_date` as dates
    on sessions.session_date = dates.date_day
where dates.date_day is null;


-- =============================================================================
-- CHECK 6: TRANSACTION DATE REFERENTIAL INTEGRITY
-- Expected: 0
-- =============================================================================

select
    count(*) as transactions_without_valid_date
from `analytics_dev.fct_transactions` as transactions
left join `analytics_dev.dim_date` as dates
    on transactions.transaction_date = dates.date_day
where dates.date_day is null;


-- =============================================================================
-- CHECK 7: TRANSACTION TO SESSION REFERENTIAL INTEGRITY
-- Expected: 0
-- =============================================================================

select
    count(*) as transactions_without_valid_session
from `analytics_dev.fct_transactions` as transactions
left join `analytics_dev.fct_sessions` as sessions
    on transactions.session_key = sessions.session_key
where sessions.session_key is null;


-- =============================================================================
-- CHECK 8: SESSION TO CHANNEL REFERENTIAL INTEGRITY
-- Expected: 0
-- =============================================================================

select
    count(*) as sessions_without_valid_channel
from `analytics_dev.fct_sessions` as sessions
left join `analytics_dev.dim_channel` as channels
    on sessions.channel_key = channels.channel_key
where channels.channel_key is null;


-- =============================================================================
-- CHECK 9: SESSION COMMERCIAL SANITY
-- Expected:
--   negative_transaction_count = 0
--   negative_purchase_revenue = 0
--   negative_item_quantity = 0
-- =============================================================================

select
    countif(transaction_count < 0) as negative_transaction_count,
    countif(purchase_revenue < 0) as negative_purchase_revenue,
    countif(total_item_quantity < 0) as negative_item_quantity
from `analytics_dev.fct_sessions`;


-- =============================================================================
-- CHECK 10: TRANSACTION COMMERCIAL SANITY
-- Expected:
--   all returned counts = 0
-- =============================================================================

select
    countif(purchase_revenue < 0) as negative_purchase_revenue,
    countif(shipping_value < 0) as negative_shipping_value,
    countif(tax_value < 0) as negative_tax_value,
    countif(total_item_quantity < 0) as negative_item_quantity,
    countif(unique_items < 0) as negative_unique_items,
    countif(unique_items > total_item_quantity)
        as unique_items_exceeding_quantity
from `analytics_dev.fct_transactions`;