select
    *

from {{ ref('mart_ecommerce_daily') }}

where
    session_count < 0

    or purchasing_session_count < 0

    or purchasing_session_count > session_count

    or transaction_count < 0

    or purchase_revenue < 0

    or refund_value < 0

    or shipping_value < 0

    or tax_value < 0

    or total_item_quantity < 0

    or session_attributed_transaction_count < 0

    or session_attributed_purchase_revenue < 0

    or conversion_rate < 0

    or conversion_rate > 1

    or average_order_value < 0

    or items_per_transaction < 0

    or revenue_per_session < 0

    or transactions_per_purchasing_session < 0