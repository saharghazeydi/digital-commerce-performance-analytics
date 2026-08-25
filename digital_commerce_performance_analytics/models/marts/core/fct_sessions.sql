{{ config(
    materialized='table'
) }}

with sessions as (

    select *
    from {{ ref('int_ga4__sessions') }}

),

final as (

    select
        -- identifiers
        session_key,
        user_pseudo_id,
        ga_session_id,
        ga_session_number,

        -- session timing
        session_date,
        session_start_timestamp,
        session_end_timestamp,
        session_duration_seconds,

        -- behavioral measures
        event_count,

        -- platform and navigation
        platform,
        landing_page,
        landing_page_title,
        exit_page,
        exit_page_title,

        -- acquisition
        source,
        medium,
        campaign,

        -- commercial measures
        transaction_count,
        purchase_revenue,
        refund_value,
        shipping_value,
        tax_value,
        total_item_quantity,
        unique_items,
        has_purchase

    from sessions

)

select *
from final