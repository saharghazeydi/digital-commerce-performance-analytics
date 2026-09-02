with channel_dates as (

    select distinct
        session_date as date_day

    from {{ ref('mart_channel_daily') }}

),

ecommerce_dates as (

    select distinct
        date_day

    from {{ ref('mart_ecommerce_daily') }}

    where session_count > 0

),

segment_dates as (

    select distinct
        session_date as date_day

    from {{ ref('mart_segment_daily') }}

),

all_dates as (

    select date_day from channel_dates

    union distinct

    select date_day from ecommerce_dates

    union distinct

    select date_day from segment_dates

),

validation as (

    select
        all_dates.date_day,

        channel_dates.date_day is null
            as missing_from_channel,

        ecommerce_dates.date_day is null
            as missing_from_ecommerce,

        segment_dates.date_day is null
            as missing_from_segment

    from all_dates

    left join channel_dates
        using (date_day)

    left join ecommerce_dates
        using (date_day)

    left join segment_dates
        using (date_day)

)

select *
from validation

where
    missing_from_channel
    or missing_from_ecommerce
    or missing_from_segment