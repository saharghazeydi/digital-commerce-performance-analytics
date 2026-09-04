with

trends as (

    select
        date_day,
        revenue_previous_7d,
        conversion_rate_previous_7d,
        revenue_wow_absolute_change,
        revenue_wow_pct_change,
        conversion_wow_absolute_change,
        conversion_wow_pct_change,

        row_number() over (
            order by date_day
        ) as date_row_number

    from {{ ref('executive_kpi_trends_daily') }}

)

select *
from trends

where

    (
        date_row_number <= 7
        and (
            revenue_previous_7d is not null
            or conversion_rate_previous_7d is not null
            or revenue_wow_absolute_change is not null
            or revenue_wow_pct_change is not null
            or conversion_wow_absolute_change is not null
            or conversion_wow_pct_change is not null
        )
    )

    or

    (
        date_row_number > 7
        and (
            revenue_previous_7d is null
            or conversion_rate_previous_7d is null
        )
    )