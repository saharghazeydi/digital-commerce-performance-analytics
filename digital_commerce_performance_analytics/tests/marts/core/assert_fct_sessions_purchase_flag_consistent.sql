select
    session_key,
    transaction_count,
    has_purchase
from {{ ref('fct_sessions') }}
where
    (has_purchase and transaction_count = 0)
    or
    (not has_purchase and transaction_count > 0)