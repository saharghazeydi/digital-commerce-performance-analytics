with source as (

    select *
    from {{ source('ga4', 'events') }}
    where _TABLE_SUFFIX between '20201101' and '20210131'

),

events as (

    select

        parse_date('%Y%m%d', event_date) as event_date,
        timestamp_micros(event_timestamp) as event_timestamp,
        event_name,
        user_pseudo_id,
        platform,

        device.category as device_category,
        geo.country as country,

        (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_id'
            limit 1
        ) as ga_session_id,

        (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_number'
            limit 1
        ) as ga_session_number,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'page_location'
            limit 1
        ) as page_location,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'page_title'
            limit 1
        ) as page_title,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'page_referrer'
            limit 1
        ) as page_referrer,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'source'
            limit 1
        ) as source,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'medium'
            limit 1
        ) as medium,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'campaign'
            limit 1
        ) as campaign,

        ecommerce.transaction_id as transaction_id,
        ecommerce.purchase_revenue as purchase_revenue,
        ecommerce.refund_value as refund_value,
        ecommerce.shipping_value as shipping_value,
        ecommerce.tax_value as tax_value,
        ecommerce.total_item_quantity as total_item_quantity,
        ecommerce.unique_items as unique_items

    from source

)

select *
from events
