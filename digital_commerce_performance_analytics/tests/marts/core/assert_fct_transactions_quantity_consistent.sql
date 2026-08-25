select
    transaction_id,
    total_item_quantity,
    unique_items
from {{ ref('fct_transactions') }}
where
    total_item_quantity < 0
    or unique_items < 0
    or unique_items > total_item_quantity