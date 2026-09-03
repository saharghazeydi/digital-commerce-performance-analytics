with

base as (

    select
        date_day,
        session_count,
        purchasing_session_count,
        purchase_revenue

    from {{ ref('executive_kpi_daily') }}

),

expected_rolling as (

    select
        date_day,

        sum(purchase_revenue) over (
            order by date_day
            rows between 6 preceding and current row
        ) as expected_revenue_7d,

        sum(session_count) over (
            order by date_day
            rows between 6 preceding and current row
        ) as expected_sessions_7d,

        sum(purchasing_session_count) over (
            order by date_day
            rows between 6 preceding and current row
        ) as expected_purchasing_sessions_7d

    from base

),

expected_ratios as (

    select
        *,

        safe_divide(
            expected_purchasing_sessions_7d,
            nullif(expected_sessions_7d, 0)
        ) as expected_conversion_rate_7d

    from expected_rolling

),

expected_prior as (

    select
        *,

        lag(expected_revenue_7d, 7) over (
            order by date_day
        ) as expected_revenue_previous_7d,

        lag(expected_conversion_rate_7d, 7) over (
            order by date_day
        ) as expected_conversion_rate_previous_7d

    from expected_ratios

),

expected as (

    select
        *,

        expected_revenue_7d
            - expected_revenue_previous_7d
            as expected_revenue_wow_absolute_change,

        safe_divide(
            expected_revenue_7d - expected_revenue_previous_7d,
            nullif(expected_revenue_previous_7d, 0)
        ) as expected_revenue_wow_pct_change,

        expected_conversion_rate_7d
            - expected_conversion_rate_previous_7d
            as expected_conversion_wow_absolute_change,

        safe_divide(
            expected_conversion_rate_7d
                - expected_conversion_rate_previous_7d,
            nullif(expected_conversion_rate_previous_7d, 0)
        ) as expected_conversion_wow_pct_change

    from expected_prior

),

actual as (

    select *
    from {{ ref('executive_kpi_trends_daily') }}

),

validation as (

    select
        coalesce(a.date_day, e.date_day) as date_day,

        a.revenue_7d,
        e.expected_revenue_7d,

        a.sessions_7d,
        e.expected_sessions_7d,

        a.purchasing_sessions_7d,
        e.expected_purchasing_sessions_7d,

        a.conversion_rate_7d,
        e.expected_conversion_rate_7d,

        a.revenue_previous_7d,
        e.expected_revenue_previous_7d,

        a.conversion_rate_previous_7d,
        e.expected_conversion_rate_previous_7d,

        a.revenue_wow_absolute_change,
        e.expected_revenue_wow_absolute_change,

        a.revenue_wow_pct_change,
        e.expected_revenue_wow_pct_change,

        a.conversion_wow_absolute_change,
        e.expected_conversion_wow_absolute_change,

        a.conversion_wow_pct_change,
        e.expected_conversion_wow_pct_change

    from actual a

    full outer join expected e
        on a.date_day = e.date_day

)

select *
from validation

where
    revenue_7d is distinct from expected_revenue_7d

    or sessions_7d is distinct from expected_sessions_7d

    or purchasing_sessions_7d
        is distinct from expected_purchasing_sessions_7d

    or conversion_rate_7d
        is distinct from expected_conversion_rate_7d

    or revenue_previous_7d
        is distinct from expected_revenue_previous_7d

    or conversion_rate_previous_7d
        is distinct from expected_conversion_rate_previous_7d

    or revenue_wow_absolute_change
        is distinct from expected_revenue_wow_absolute_change

    or revenue_wow_pct_change
        is distinct from expected_revenue_wow_pct_change

    or conversion_wow_absolute_change
        is distinct from expected_conversion_wow_absolute_change

    or conversion_wow_pct_change
        is distinct from expected_conversion_wow_pct_change