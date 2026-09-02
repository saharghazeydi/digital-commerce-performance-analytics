with core as (

    select
        count(*) as session_count,
        countif(has_purchase) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(shipping_value) as shipping_value,
        sum(tax_value) as tax_value,
        sum(total_item_quantity) as total_item_quantity,
        sum(unique_items) as unique_items

    from {{ ref('fct_sessions') }}

),

mart as (

    select
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(shipping_value) as shipping_value,
        sum(tax_value) as tax_value,
        sum(total_item_quantity) as total_item_quantity,
        sum(unique_items) as unique_items

    from {{ ref('mart_channel_daily') }}

)

select
    core.session_count as core_session_count,
    mart.session_count as mart_session_count

from core
cross join mart

where
    core.session_count != mart.session_count
    or core.purchasing_session_count != mart.purchasing_session_count
    or core.transaction_count != mart.transaction_count
    or core.purchase_revenue != mart.purchase_revenue
    or core.refund_value != mart.refund_value
    or core.shipping_value != mart.shipping_value
    or core.tax_value != mart.tax_value
    or core.total_item_quantity != mart.total_item_quantity
    or core.unique_items != mart.unique_items