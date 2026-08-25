{{ config(
    materialized='table'
) }}

with date_boundaries as (

    select
        min(session_date) as min_date,
        max(session_date) as max_date
    from {{ ref('int_ga4__sessions') }}

),

transaction_boundaries as (

    select
        min(transaction_date) as min_date,
        max(transaction_date) as max_date
    from {{ ref('int_ga4__transactions') }}

),

combined_boundaries as (

    select
        least(
            session_boundaries.min_date,
            transaction_boundaries.min_date
        ) as min_date,

        greatest(
            session_boundaries.max_date,
            transaction_boundaries.max_date
        ) as max_date

    from date_boundaries as session_boundaries
    cross join transaction_boundaries

),

date_spine as (

    select date_day
    from combined_boundaries
    cross join unnest(
        generate_date_array(min_date, max_date)
    ) as date_day

),

final as (

    select
        date_day,

        extract(year from date_day) as year,
        extract(quarter from date_day) as quarter,

        concat(
            'Q',
            cast(extract(quarter from date_day) as string)
        ) as quarter_name,

        extract(month from date_day) as month_number,
        format_date('%B', date_day) as month_name,
        format_date('%Y-%m', date_day) as year_month,

        extract(week from date_day) as week_of_year,
        extract(day from date_day) as day_of_month,
        extract(dayofweek from date_day) as day_of_week,
        format_date('%A', date_day) as day_name,

        extract(dayofweek from date_day) in (1, 7) as is_weekend

    from date_spine

)

select *
from final