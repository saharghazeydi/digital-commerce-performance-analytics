select
    session_date,
    device_category,
    country,
    count(*) as row_count

from {{ ref('mart_segment_daily') }}

group by
    session_date,
    device_category,
    country

having count(*) > 1