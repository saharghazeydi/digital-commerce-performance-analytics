select
    session_key,
    has_purchase,
    transaction_count
from {{ ref('int_ga4__sessions') }}
where
    (has_purchase and transaction_count = 0)
    or (not has_purchase and transaction_count > 0)