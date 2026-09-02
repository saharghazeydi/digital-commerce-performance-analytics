{{ config(
    materialized='table'
) }}

with sessions as (

    select
        session_date,
        channel_key,
        has_purchase,
        transaction_count,
        purchase_revenue,
        refund_value,
        shipping_value,
        tax_value,
        total_item_quantity,
        unique_items

    from {{ ref('fct_sessions') }}

),

channels as (

    select
        channel_key,
        channel_group,
        channel_description,
        sort_order

    from {{ ref('dim_channel') }}

),

daily_channel_performance as (

    select
        session_date,
        channel_key,

        count(*) as session_count,

        countif(has_purchase)
            as purchasing_session_count,

        sum(transaction_count)
            as transaction_count,

        sum(purchase_revenue)
            as purchase_revenue,

        sum(refund_value)
            as refund_value,

        sum(shipping_value)
            as shipping_value,

        sum(tax_value)
            as tax_value,

        sum(total_item_quantity)
            as total_item_quantity,

        sum(unique_items)
            as unique_items

    from sessions

    group by
        session_date,
        channel_key

),

final as (

    select
        performance.session_date,
        performance.channel_key,

        channels.channel_group,
        channels.channel_description,
        channels.sort_order,

        performance.session_count,
        performance.purchasing_session_count,
        performance.transaction_count,
        performance.purchase_revenue,
        performance.refund_value,
        performance.shipping_value,
        performance.tax_value,
        performance.total_item_quantity,
        performance.unique_items

    from daily_channel_performance as performance

    inner join channels
        on performance.channel_key = channels.channel_key

)

select *
from final