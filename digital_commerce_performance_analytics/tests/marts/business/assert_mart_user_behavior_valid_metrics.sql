select
    user_pseudo_id,
    session_count,
    active_date_count,
    purchasing_session_count,
    purchasing_date_count,
    transaction_count,
    purchase_revenue,
    refund_value,
    total_item_quantity,
    observed_user_span_days

from {{ ref('mart_user_behavior') }}

where
    session_count < 1
    or active_date_count < 1

    or purchasing_session_count < 0
    or purchasing_session_count > session_count

    or purchasing_date_count < 0
    or purchasing_date_count > active_date_count
    or purchasing_date_count > purchasing_session_count

    or transaction_count < 0
    or purchase_revenue < 0
    or refund_value < 0
    or total_item_quantity < 0

    or observed_user_span_days < 0