with required_dates as (

    select
        session_date as date_day
    from {{ ref('int_ga4__sessions') }}

    union distinct

    select
        transaction_date as date_day
    from {{ ref('int_ga4__transactions') }}

),

missing_dates as (

    select
        required_dates.date_day
    from required_dates
    left join {{ ref('dim_date') }} as dim_date
        on required_dates.date_day = dim_date.date_day
    where
        required_dates.date_day is not null
        and dim_date.date_day is null

)

select *
from missing_dates