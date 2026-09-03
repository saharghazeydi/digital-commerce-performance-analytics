{{ config(
    materialized = 'table'
) }}

with

channel_daily as (

    select
        session_date,
        channel_key,
        channel_group,
        channel_description,
        sort_order,

        session_count,
        purchasing_session_count,
        transaction_count,
        purchase_revenue

    from {{ ref('mart_channel_daily') }}

),

daily_totals as (

    select
        session_date,

        sum(session_count)
            as total_session_count,

        sum(purchasing_session_count)
            as total_purchasing_session_count,

        sum(transaction_count)
            as total_session_attributed_transaction_count,

        sum(purchase_revenue)
            as total_session_attributed_purchase_revenue

    from channel_daily

    group by
        session_date

),

final as (

    select
        channel.session_date,
        channel.channel_key,
        channel.channel_group,
        channel.channel_description,
        channel.sort_order,

        channel.session_count,
        channel.purchasing_session_count,
        channel.transaction_count
            as session_attributed_transaction_count,
        channel.purchase_revenue
            as session_attributed_purchase_revenue,

        safe_divide(
            channel.purchasing_session_count,
            nullif(channel.session_count, 0)
        ) as conversion_rate,

        safe_divide(
            channel.session_count,
            nullif(totals.total_session_count, 0)
        ) as session_contribution,

        safe_divide(
            channel.purchasing_session_count,
            nullif(totals.total_purchasing_session_count, 0)
        ) as purchasing_session_contribution,

        safe_divide(
            channel.transaction_count,
            nullif(totals.total_session_attributed_transaction_count, 0)
        ) as transaction_contribution,

        safe_divide(
            channel.purchase_revenue,
            nullif(totals.total_session_attributed_purchase_revenue, 0)
        ) as revenue_contribution

    from channel_daily as channel

    inner join daily_totals as totals
        on channel.session_date = totals.session_date

)

select *
from final