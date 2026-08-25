{{ config(
    materialized='table'
) }}

with transactions as (

    select *
    from {{ ref('int_ga4__transactions') }}

),

final as (

    select
        -- identifiers
        transaction_id,
        session_key,
        user_pseudo_id,
        ga_session_id,
        ga_session_number,

        -- transaction and session timing
        transaction_date,
        transaction_timestamp,
        session_date,
        session_start_timestamp,
        session_end_timestamp,

        -- platform and acquisition
        platform,
        landing_page,
        landing_page_title,
        source,
        medium,
        campaign,

        -- commercial measures
        purchase_revenue,
        refund_value,
        shipping_value,
        tax_value,
        total_item_quantity,
        unique_items

    from transactions

)

select *
from final