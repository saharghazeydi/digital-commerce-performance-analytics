{{ config(
    materialized='view'
) }}

select
    date_day,

    -- Session-date measures
    session_count,
    purchasing_session_count,
    conversion_rate,

    -- Transaction-date measures
    transaction_count,
    purchase_revenue,
    average_order_value,

    -- Session-cohort measures
    session_attributed_transaction_count,
    session_attributed_purchase_revenue,
    revenue_per_session,

    -- Governed seven-day trend measures
    revenue_7d,
    sessions_7d,
    purchasing_sessions_7d,
    conversion_rate_7d,

    -- Governed prior-period and Week-over-Week measures
    revenue_previous_7d,
    conversion_rate_previous_7d,
    revenue_wow_absolute_change,
    revenue_wow_pct_change,
    conversion_wow_absolute_change,
    conversion_wow_pct_change

from {{ ref('executive_kpi_trends_daily') }}