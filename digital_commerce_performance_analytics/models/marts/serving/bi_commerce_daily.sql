{{ config(
    materialized='view'
) }}

select
    date_day,

    -- Transaction-date additive commercial measures
    transaction_count,
    purchase_revenue,
    refund_value,
    shipping_value,
    tax_value,
    total_item_quantity,

    -- Governed transaction-date ratios
    average_order_value,
    items_per_transaction

from {{ ref('mart_ecommerce_daily') }}