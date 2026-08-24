select
    session_key,
    event_count
from {{ ref('int_ga4__sessions') }}
where event_count < 1