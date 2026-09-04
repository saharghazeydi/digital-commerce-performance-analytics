{{ config(
    materialized = 'table'
) }}

with

base as (

    select
        date_day,

        session_count,
        purchasing_session_count,

        transaction_count,
        purchase_revenue,

        conversion_rate,
        average_order_value,
        revenue_per_session,

        session_attributed_transaction_count,
        session_attributed_purchase_revenue

    from {{ ref('executive_kpi_daily') }}

),

rolling_metrics as (

    select
        *,

        sum(purchase_revenue) over (
            order by date_day
            rows between 6 preceding and current row
        ) as revenue_7d,

        sum(session_count) over (
            order by date_day
            rows between 6 preceding and current row
        ) as sessions_7d,

        sum(purchasing_session_count) over (
            order by date_day
            rows between 6 preceding and current row
        ) as purchasing_sessions_7d

    from base

),

rolling_ratios as (

    select
        *,

        safe_divide(
            purchasing_sessions_7d,
            nullif(sessions_7d, 0)
        ) as conversion_rate_7d

    from rolling_metrics

),

prior_period as (

    select
        *,

        lag(revenue_7d, 7) over (
            order by date_day
        ) as revenue_previous_7d,

        lag(conversion_rate_7d, 7) over (
            order by date_day
        ) as conversion_rate_previous_7d

    from rolling_ratios

),

final as (

    select
        *,

        revenue_7d
            - revenue_previous_7d
            as revenue_wow_absolute_change,

        safe_divide(
            revenue_7d - revenue_previous_7d,
            nullif(revenue_previous_7d, 0)
        ) as revenue_wow_pct_change,

        conversion_rate_7d
            - conversion_rate_previous_7d
            as conversion_wow_absolute_change,

        safe_divide(
            conversion_rate_7d - conversion_rate_previous_7d,
            nullif(conversion_rate_previous_7d, 0)
        ) as conversion_wow_pct_change

    from prior_period

)

select *
from final