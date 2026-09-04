{{ config(
    materialized='view'
) }}

select
    -- Grain dimensions
    session_date,
    device_category,
    country,

    -- Session-date measures
    session_count,
    purchasing_session_count,
    conversion_rate,

    -- Session-attributed commercial measures
    transaction_count as session_attributed_transaction_count,
    purchase_revenue as session_attributed_purchase_revenue,
    revenue_per_session

from {{ ref('mart_segment_daily') }}