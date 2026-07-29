-- Fails when more than one staged event shares the approved
-- composite event key.

select
    event_timestamp,
    user_pseudo_id,
    event_name,
    ga_session_id,
    count(*) as row_count
from {{ ref('stg_ga4__events') }}
group by
    event_timestamp,
    user_pseudo_id,
    event_name,
    ga_session_id
having count(*) > 1