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

        case
            when medium is null
                or medium = '(data deleted)'
                then 8

            when medium = '(none)'
                then 1

            when medium = 'organic'
                then 2

            when medium = 'cpc'
                then 3

            when medium = 'referral'
                then 4

            when medium = 'email'
                then 5

            when medium = 'affiliate'
                then 6

            else 7
        end as channel_key,

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