select
    date_day,
    session_count,
    purchasing_session_count,
    conversion_rate,
    transaction_count,
    purchase_revenue,
    total_item_quantity,
    average_order_value,
    items_per_transaction,
    session_attributed_transaction_count,
    session_attributed_purchase_revenue,
    revenue_per_session,
    transactions_per_purchasing_session

from {{ ref('mart_ecommerce_daily') }}

where
    (
        conversion_rate is distinct from
        safe_divide(
            purchasing_session_count,
            session_count
        )
    )

    or (
        average_order_value is distinct from
        safe_divide(
            purchase_revenue,
            transaction_count
        )
    )

    or (
        items_per_transaction is distinct from
        safe_divide(
            total_item_quantity,
            transaction_count
        )
    )

    or (
        revenue_per_session is distinct from
        safe_divide(
            session_attributed_purchase_revenue,
            session_count
        )
    )

    or (
        transactions_per_purchasing_session is distinct from
        safe_divide(
            session_attributed_transaction_count,
            purchasing_session_count
        )
    )