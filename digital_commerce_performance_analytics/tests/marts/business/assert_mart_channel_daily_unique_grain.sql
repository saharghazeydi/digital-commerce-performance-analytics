select
    session_date,
    channel_key,
    count(*) as row_count

from {{ ref('mart_channel_daily') }}

group by
    session_date,
    channel_key

having count(*) > 1