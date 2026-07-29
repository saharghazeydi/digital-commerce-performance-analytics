-- Fails when more than one staged item shares the approved
-- composite item key.

select
    event_timestamp,
    user_pseudo_id,
    event_name,
    ga_session_id,
    item_offset,
    count(*) as row_count
from {{ ref('stg_ga4__items') }}
group by
    event_timestamp,
    user_pseudo_id,
    event_name,
    ga_session_id,
    item_offset
having count(*) > 1