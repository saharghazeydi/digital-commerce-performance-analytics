{{ config(
    materialized='view'
) }}

select
    -- Grain and governed channel attributes
    session_date,
    channel_key,
    channel_group,
    channel_description,
    sort_order,

    -- Session-date measures
    session_count,
    purchasing_session_count,
    conversion_rate,

    -- Session-attributed commercial measures
    session_attributed_transaction_count,
    session_attributed_purchase_revenue,

    -- Governed daily contribution measures
    session_contribution,
    purchasing_session_contribution,
    transaction_contribution,
    revenue_contribution

from {{ ref('executive_channel_drivers_daily') }}