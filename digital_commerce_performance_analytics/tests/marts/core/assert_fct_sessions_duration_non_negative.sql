select
    session_key,
    session_duration_seconds
from {{ ref('fct_sessions') }}
where session_duration_seconds < 0