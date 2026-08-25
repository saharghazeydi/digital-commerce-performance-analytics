select
    session_key,
    event_count
from {{ ref('fct_sessions') }}
where event_count <= 0