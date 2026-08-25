select
    transaction_id,
    session_key,
    transaction_timestamp,
    session_start_timestamp,
    session_end_timestamp
from {{ ref('fct_transactions') }}
where
    transaction_timestamp < session_start_timestamp
    or transaction_timestamp > session_end_timestamp