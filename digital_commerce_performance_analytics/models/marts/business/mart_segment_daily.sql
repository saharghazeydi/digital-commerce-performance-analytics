{{ config(
    materialized='table'
) }}

with sessions as (

    select
        session_date,

        case
            when device_category is null
                or trim(device_category) = ''
                or lower(trim(device_category)) = '(not set)'
                then 'Unknown'
            else trim(device_category)
        end as device_category,

        case
            when country is null
                or trim(country) = ''
                or lower(trim(country)) = '(not set)'
                then 'Unknown'
            else trim(country)
        end as country,

        has_purchase,
        transaction_count,
        purchase_revenue

    from {{ ref('fct_sessions') }}

),

segment_daily as (

    select
        session_date,
        device_category,
        country,

        count(*) as session_count,

        countif(has_purchase) as purchasing_session_count,

        sum(transaction_count) as transaction_count,

        sum(purchase_revenue) as purchase_revenue

    from sessions

    group by
        session_date,
        device_category,
        country

),

final as (

    select
        session_date,
        device_category,
        country,

        session_count,
        purchasing_session_count,

        safe_divide(
            purchasing_session_count,
            session_count
        ) as conversion_rate,

        transaction_count,
        purchase_revenue,

        safe_divide(
            purchase_revenue,
            session_count
        ) as revenue_per_session

    from segment_daily

)

select *
from final