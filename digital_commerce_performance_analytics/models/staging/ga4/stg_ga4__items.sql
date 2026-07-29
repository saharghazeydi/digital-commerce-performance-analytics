with source as (

    select *
    from {{ source('ga4', 'events') }}
    where _TABLE_SUFFIX between '20201101' and '20210131'

),

items as (

    select
        parse_date('%Y%m%d', event_date) as event_date,
        timestamp_micros(event_timestamp) as event_timestamp,
        event_name,
        user_pseudo_id,
        platform,

        (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_id'
            limit 1
        ) as ga_session_id,

        ecommerce.transaction_id as transaction_id,

        item_offset,
        item.item_id as item_id,
        item.item_name as item_name,
        item.item_brand as item_brand,
        item.item_variant as item_variant,
        item.item_category as item_category,
        item.price as price,
        item.quantity as quantity,
        item.item_revenue as item_revenue,
        item.coupon as coupon,
        item.affiliation as affiliation

    from source
    cross join unnest(items) as item with offset as item_offset

)

select *
from items
