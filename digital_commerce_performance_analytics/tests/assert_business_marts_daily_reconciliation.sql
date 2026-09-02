with channel_daily as (

    select
        session_date as date_day,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue

    from {{ ref('mart_channel_daily') }}

    group by session_date

),

ecommerce_daily as (

    select
        date_day,
        session_count,
        purchasing_session_count,
        session_attributed_transaction_count as transaction_count,
        session_attributed_purchase_revenue as purchase_revenue

    from {{ ref('mart_ecommerce_daily') }}

    where session_count > 0

),

segment_daily as (

    select
        session_date as date_day,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue

    from {{ ref('mart_segment_daily') }}

    group by session_date

),

validation as (

    select
        ecommerce_daily.date_day,

        channel_daily.session_count
            - ecommerce_daily.session_count
            as channel_session_difference,

        segment_daily.session_count
            - ecommerce_daily.session_count
            as segment_session_difference,

        channel_daily.purchasing_session_count
            - ecommerce_daily.purchasing_session_count
            as channel_purchasing_session_difference,

        segment_daily.purchasing_session_count
            - ecommerce_daily.purchasing_session_count
            as segment_purchasing_session_difference,

        channel_daily.transaction_count
            - ecommerce_daily.transaction_count
            as channel_transaction_difference,

        segment_daily.transaction_count
            - ecommerce_daily.transaction_count
            as segment_transaction_difference,

        channel_daily.purchase_revenue
            - ecommerce_daily.purchase_revenue
            as channel_revenue_difference,

        segment_daily.purchase_revenue
            - ecommerce_daily.purchase_revenue
            as segment_revenue_difference

    from ecommerce_daily

    inner join channel_daily
        using (date_day)

    inner join segment_daily
        using (date_day)

)

select *
from validation

where
    channel_session_difference != 0
    or segment_session_difference != 0
    or channel_purchasing_session_difference != 0
    or segment_purchasing_session_difference != 0
    or channel_transaction_difference != 0
    or segment_transaction_difference != 0
    or abs(channel_revenue_difference) > 0.01
    or abs(segment_revenue_difference) > 0.01