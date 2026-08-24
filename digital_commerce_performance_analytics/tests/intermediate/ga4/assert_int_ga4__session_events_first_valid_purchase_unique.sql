select
    normalized_transaction_id
from {{ ref('int_ga4__session_events') }}
where is_first_valid_purchase
group by normalized_transaction_id
having
    normalized_transaction_id is null
    or count(*) > 1