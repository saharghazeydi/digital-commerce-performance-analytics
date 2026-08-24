select
    session_key
from {{ ref('int_ga4__session_events') }}
group by session_key
having countif(is_selected_acquisition_event) > 1