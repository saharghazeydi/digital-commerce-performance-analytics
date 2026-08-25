/*
===============================================================================
Phase 5 - Core Warehouse Reconciliation
Project : Digital Commerce Performance Analytics
Purpose : Reconcile Core Warehouse outputs with validated Phase 4 intermediate
          models.
===============================================================================
*/


-- =============================================================================
-- CHECK 1: SESSION AGGREGATE RECONCILIATION
-- Expected: all differences = 0
-- =============================================================================

with intermediate as (

    select
        count(*) as row_count,
        count(distinct session_key) as distinct_key_count,
        countif(has_purchase) as purchasing_sessions,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(shipping_value) as shipping_value,
        sum(tax_value) as tax_value,
        sum(total_item_quantity) as total_item_quantity,
        sum(unique_items) as unique_items
    from `analytics_dev.int_ga4__sessions`

),

warehouse as (

    select
        count(*) as row_count,
        count(distinct session_key) as distinct_key_count,
        countif(has_purchase) as purchasing_sessions,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(shipping_value) as shipping_value,
        sum(tax_value) as tax_value,
        sum(total_item_quantity) as total_item_quantity,
        sum(unique_items) as unique_items
    from `analytics_dev.fct_sessions`

)

select
    warehouse.row_count - intermediate.row_count
        as row_count_difference,

    warehouse.distinct_key_count - intermediate.distinct_key_count
        as distinct_key_difference,

    warehouse.purchasing_sessions - intermediate.purchasing_sessions
        as purchasing_sessions_difference,

    warehouse.transaction_count - intermediate.transaction_count
        as transaction_count_difference,

    warehouse.purchase_revenue - intermediate.purchase_revenue
        as purchase_revenue_difference,

    warehouse.refund_value - intermediate.refund_value
        as refund_value_difference,

    warehouse.shipping_value - intermediate.shipping_value
        as shipping_value_difference,

    warehouse.tax_value - intermediate.tax_value
        as tax_value_difference,

    warehouse.total_item_quantity - intermediate.total_item_quantity
        as total_item_quantity_difference,

    warehouse.unique_items - intermediate.unique_items
        as unique_items_difference

from intermediate
cross join warehouse;


-- =============================================================================
-- CHECK 2: TRANSACTION AGGREGATE RECONCILIATION
-- Expected: all differences = 0
-- =============================================================================

with intermediate as (

    select
        count(*) as row_count,
        count(distinct transaction_id) as distinct_key_count,
        count(distinct session_key) as purchasing_session_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(shipping_value) as shipping_value,
        sum(tax_value) as tax_value,
        sum(total_item_quantity) as total_item_quantity,
        sum(unique_items) as unique_items
    from `analytics_dev.int_ga4__transactions`

),

warehouse as (

    select
        count(*) as row_count,
        count(distinct transaction_id) as distinct_key_count,
        count(distinct session_key) as purchasing_session_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(shipping_value) as shipping_value,
        sum(tax_value) as tax_value,
        sum(total_item_quantity) as total_item_quantity,
        sum(unique_items) as unique_items
    from `analytics_dev.fct_transactions`

)

select
    warehouse.row_count - intermediate.row_count
        as row_count_difference,

    warehouse.distinct_key_count - intermediate.distinct_key_count
        as distinct_key_difference,

    warehouse.purchasing_session_count - intermediate.purchasing_session_count
        as purchasing_session_difference,

    warehouse.purchase_revenue - intermediate.purchase_revenue
        as purchase_revenue_difference,

    warehouse.refund_value - intermediate.refund_value
        as refund_value_difference,

    warehouse.shipping_value - intermediate.shipping_value
        as shipping_value_difference,

    warehouse.tax_value - intermediate.tax_value
        as tax_value_difference,

    warehouse.total_item_quantity - intermediate.total_item_quantity
        as total_item_quantity_difference,

    warehouse.unique_items - intermediate.unique_items
        as unique_items_difference

from intermediate
cross join warehouse;


-- =============================================================================
-- CHECK 3: SESSION KEY-SET RECONCILIATION
-- Expected:
--   sessions_missing_from_warehouse = 0
--   unexpected_sessions_in_warehouse = 0
-- =============================================================================

with missing_from_warehouse as (

    select session_key
    from `analytics_dev.int_ga4__sessions`

    except distinct

    select session_key
    from `analytics_dev.fct_sessions`

),

unexpected_in_warehouse as (

    select session_key
    from `analytics_dev.fct_sessions`

    except distinct

    select session_key
    from `analytics_dev.int_ga4__sessions`

)

select
    (select count(*) from missing_from_warehouse)
        as sessions_missing_from_warehouse,

    (select count(*) from unexpected_in_warehouse)
        as unexpected_sessions_in_warehouse;


-- =============================================================================
-- CHECK 4: TRANSACTION KEY-SET RECONCILIATION
-- Expected:
--   transactions_missing_from_warehouse = 0
--   unexpected_transactions_in_warehouse = 0
-- =============================================================================

with missing_from_warehouse as (

    select transaction_id
    from `analytics_dev.int_ga4__transactions`

    except distinct

    select transaction_id
    from `analytics_dev.fct_transactions`

),

unexpected_in_warehouse as (

    select transaction_id
    from `analytics_dev.fct_transactions`

    except distinct

    select transaction_id
    from `analytics_dev.int_ga4__transactions`

)

select
    (select count(*) from missing_from_warehouse)
        as transactions_missing_from_warehouse,

    (select count(*) from unexpected_in_warehouse)
        as unexpected_transactions_in_warehouse;