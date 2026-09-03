with

executive as (

    select *
    from {{ ref('executive_kpi_daily') }}

),

ecommerce as (

    select *
    from {{ ref('mart_ecommerce_daily') }}

),

validation as (

    select
        e.date_day,

        e.session_count as executive_session_count,
        m.session_count as mart_session_count,

        e.purchasing_session_count as executive_purchasing_session_count,
        m.purchasing_session_count as mart_purchasing_session_count,

        e.transaction_count as executive_transaction_count,
        m.transaction_count as mart_transaction_count,

        e.purchase_revenue as executive_purchase_revenue,
        m.purchase_revenue as mart_purchase_revenue,

        e.session_attributed_transaction_count
            as executive_session_attributed_transaction_count,
        m.session_attributed_transaction_count
            as mart_session_attributed_transaction_count,

        e.session_attributed_purchase_revenue
            as executive_session_attributed_purchase_revenue,
        m.session_attributed_purchase_revenue
            as mart_session_attributed_purchase_revenue,

        e.conversion_rate as executive_conversion_rate,
        m.conversion_rate as mart_conversion_rate,

        e.average_order_value as executive_average_order_value,
        m.average_order_value as mart_average_order_value,

        e.revenue_per_session as executive_revenue_per_session,
        m.revenue_per_session as mart_revenue_per_session

    from executive e

    full outer join ecommerce m
        on e.date_day = m.date_day

)

select *
from validation

where
    executive_session_count is distinct from mart_session_count

    or executive_purchasing_session_count
        is distinct from mart_purchasing_session_count

    or executive_transaction_count
        is distinct from mart_transaction_count

    or executive_purchase_revenue
        is distinct from mart_purchase_revenue

    or executive_session_attributed_transaction_count
        is distinct from mart_session_attributed_transaction_count

    or executive_session_attributed_purchase_revenue
        is distinct from mart_session_attributed_purchase_revenue

    or executive_conversion_rate
        is distinct from mart_conversion_rate

    or executive_average_order_value
        is distinct from mart_average_order_value

    or executive_revenue_per_session
        is distinct from mart_revenue_per_session