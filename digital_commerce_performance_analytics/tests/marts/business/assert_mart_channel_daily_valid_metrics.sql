select *

from {{ ref('mart_channel_daily') }}

where
    session_count <= 0
    or purchasing_session_count < 0
    or purchasing_session_count > session_count
    or transaction_count < 0
    or purchase_revenue < 0
    or total_item_quantity < 0