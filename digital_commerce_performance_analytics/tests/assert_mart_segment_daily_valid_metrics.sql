select
    session_date,
    device_category,
    country,
    session_count,
    purchasing_session_count,
    conversion_rate,
    transaction_count,
    purchase_revenue,
    revenue_per_session

from {{ ref('mart_segment_daily') }}

where
    session_count <= 0

    or purchasing_session_count < 0
    or purchasing_session_count > session_count

    or transaction_count < 0

    or conversion_rate is null
    or conversion_rate < 0
    or conversion_rate > 1

    or revenue_per_session is null

    or abs(
        conversion_rate
        - safe_divide(
            purchasing_session_count,
            session_count
        )
    ) > 0.000001

    or abs(
        revenue_per_session
        - safe_divide(
            purchase_revenue,
            session_count
        )
    ) > 0.000001