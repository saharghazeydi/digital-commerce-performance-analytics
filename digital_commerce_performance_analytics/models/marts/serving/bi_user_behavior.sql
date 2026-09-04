{{ config(
    materialized='view'
) }}

select
    -- Analytical pseudo-user identifier
    user_pseudo_id,

    -- Observed session behaviour
    session_count,
    active_date_count,
    purchasing_session_count,
    purchasing_date_count,

    -- Observation-window dates
    first_observed_session_date,
    last_observed_session_date,
    first_observed_purchase_date,
    last_observed_purchase_date,
    observed_user_span_days,

    -- Observed commercial activity
    transaction_count,
    purchase_revenue,
    refund_value,
    total_item_quantity,

    -- Observed behavioural flags
    is_purchasing_user,
    is_multi_session_user,
    returned_on_later_date,
    is_repeat_purchasing_session_user,
    is_repeat_purchasing_date_user

from {{ ref('mart_user_behavior') }}