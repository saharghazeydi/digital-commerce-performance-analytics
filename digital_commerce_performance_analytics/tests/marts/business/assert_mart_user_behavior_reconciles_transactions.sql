with mart_totals as (

    select
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue,
        sum(refund_value) as refund_value,
        sum(total_item_quantity) as total_item_quantity

    from {{ ref('mart_user_behavior') }}

),

source_totals as (

    select
        count(*) as transaction_count,
        sum(coalesce(purchase_revenue, 0)) as purchase_revenue,
        sum(coalesce(refund_value, 0)) as refund_value,
        sum(coalesce(total_item_quantity, 0)) as total_item_quantity

    from {{ ref('fct_transactions') }}

)

select
    mart.transaction_count as mart_transaction_count,
    source.transaction_count as source_transaction_count,

    mart.purchase_revenue as mart_purchase_revenue,
    source.purchase_revenue as source_purchase_revenue,

    mart.refund_value as mart_refund_value,
    source.refund_value as source_refund_value,

    mart.total_item_quantity as mart_total_item_quantity,
    source.total_item_quantity as source_total_item_quantity

from mart_totals as mart
cross join source_totals as source

where
    mart.transaction_count != source.transaction_count
    or mart.purchase_revenue != source.purchase_revenue
    or mart.refund_value != source.refund_value
    or mart.total_item_quantity != source.total_item_quantity