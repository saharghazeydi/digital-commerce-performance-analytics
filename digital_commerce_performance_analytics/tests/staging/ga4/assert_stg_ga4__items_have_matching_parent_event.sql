-- Fails when an item row cannot be matched to its parent GA4 event
-- using the approved composite event key.

with event_keys as (

    select distinct
        event_date,
        event_timestamp,
        event_name,
        user_pseudo_id,
        ga_session_id
    from {{ ref('stg_ga4__events') }}

)

select
    i.event_date,
    i.event_timestamp,
    i.event_name,
    i.user_pseudo_id,
    i.ga_session_id,
    i.item_offset,
    i.item_id
from {{ ref('stg_ga4__items') }} as i
left join event_keys as e
    on i.event_date = e.event_date
   and i.event_timestamp = e.event_timestamp
   and i.event_name = e.event_name
   and i.user_pseudo_id = e.user_pseudo_id
   and i.ga_session_id = e.ga_session_id
where e.event_timestamp is null