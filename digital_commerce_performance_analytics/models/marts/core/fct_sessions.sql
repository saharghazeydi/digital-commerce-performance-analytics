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
        device_category,
        country,
        landing_page,
        landing_page_title,
        landing_page_referrer,
        exit_page,
        exit_page_title,

        -- acquisition
        source,
        medium,
        campaign,
        has_selected_acquisition,

        case

            when has_selected_acquisition then

                case
                    when lower(trim(source)) = '(data deleted)'
                        or lower(trim(medium)) = '(data deleted)'
                        then 8

                    when lower(trim(source)) = '(direct)'
                        or lower(trim(medium)) = '(none)'
                        then 1

                    when lower(trim(medium)) = 'organic'
                        then 2

                    when lower(trim(medium)) = 'cpc'
                        then 3

                    when lower(trim(medium)) = 'referral'
                        then 4

                    when lower(trim(medium)) = 'email'
                        then 5

                    when lower(trim(medium)) = 'affiliate'
                        then 6

                    when nullif(trim(medium), '') is null
                        then 8

                    else 7
                end

            when nullif(trim(landing_page_referrer), '') is null
                then 1

            when lower(
                regexp_extract(
                    trim(landing_page_referrer),
                    r'^https?://([^/:?#]+)'
                )
            ) = 'shop.googlemerchandisestore.com'
                then 1

            else 8

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