{{ config(
    materialized = 'table'
) }}

with

ecommerce_daily as (

    select
        date_day,

        session_count,
        purchasing_session_count,

        transaction_count,
        purchase_revenue,

        session_attributed_transaction_count,
        session_attributed_purchase_revenue

    from {{ ref('mart_ecommerce_daily') }}

),

final as (

    select
        date_day,

        session_count,
        purchasing_session_count,

        transaction_count,
        purchase_revenue,

        session_attributed_transaction_count,
        session_attributed_purchase_revenue,

        safe_divide(
            purchasing_session_count,
            nullif(session_count, 0)
        ) as conversion_rate,

        safe_divide(
            purchase_revenue,
            nullif(transaction_count, 0)
        ) as average_order_value,

        safe_divide(
            session_attributed_purchase_revenue,
            nullif(session_count, 0)
        ) as revenue_per_session

    from ecommerce_daily

)

select *
from final