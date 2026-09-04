with grain_check as (

    select
        session_date,
        channel_key,
        count(*) as row_count

    from {{ ref('executive_channel_drivers_daily') }}

    group by
        session_date,
        channel_key

)

select *
from grain_check
where row_count > 1