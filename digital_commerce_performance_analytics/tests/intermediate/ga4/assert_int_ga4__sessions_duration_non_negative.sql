select
    session_key,
    session_duration_seconds
from {{ ref('int_ga4__sessions') }}
where session_duration_seconds < 0