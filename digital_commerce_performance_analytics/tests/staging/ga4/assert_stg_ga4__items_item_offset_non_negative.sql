-- Fails when an item has an invalid negative position
-- within the parent GA4 event items array.

select
    event_date,
    event_timestamp,
    event_name,
    user_pseudo_id,
    ga_session_id,
    item_offset
from {{ ref('stg_ga4__items') }}
where item_offset < 0