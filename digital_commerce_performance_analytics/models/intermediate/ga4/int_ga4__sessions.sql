{{ config(
    materialized='table',
    cluster_by=[
        "user_pseudo_id",
        "source",
        "medium"
    ]
) }}
with session_events as (

    select *
    from {{ ref('int_ga4__session_events') }}

),

first_events as (

    select *
    from session_events
    where is_first_event

),

last_events as (

    select *
    from session_events
    where is_last_event

),

selected_acquisition_events as (

    select *
    from session_events
    where is_selected_acquisition_event

),

deduplicated_purchase_events as (

    select *
    from session_events
    where is_first_valid_purchase

),

aggregated_sessions as (

    select
        session_key,
        any_value(user_pseudo_id) as user_pseudo_id,
        any_value(ga_session_id) as ga_session_id,
        max(ga_session_number) as ga_session_number,
        min(event_date) as session_date,
        min(event_timestamp) as session_start_timestamp,
        max(event_timestamp) as session_end_timestamp,

        timestamp_diff(
            max(event_timestamp),
            min(event_timestamp),
            second
        ) as session_duration_seconds,

        count(*) as event_count

    from session_events

    group by session_key

),

purchase_metrics as (

    select
        session_key,

        count(*) as transaction_count,

        sum(coalesce(purchase_revenue, 0)) as purchase_revenue,

        sum(coalesce(refund_value, 0)) as refund_value,

        sum(coalesce(shipping_value, 0)) as shipping_value,

        sum(coalesce(tax_value, 0)) as tax_value,

        sum(coalesce(total_item_quantity, 0)) as total_item_quantity,

        sum(coalesce(unique_items, 0)) as unique_items

    from deduplicated_purchase_events

    group by session_key

),

session_enriched as (

    select
        sessions.*,

        first_events.platform as platform,
        first_events.page_location as landing_page,
        first_events.page_title as landing_page_title,

        last_events.page_location as exit_page,
        last_events.page_title as exit_page_title,

        selected_acquisition_events.source as source,
        selected_acquisition_events.medium as medium,
        selected_acquisition_events.campaign as campaign,

        coalesce(purchase_metrics.transaction_count, 0) as transaction_count,

        coalesce(purchase_metrics.purchase_revenue, 0) as purchase_revenue,

        coalesce(purchase_metrics.refund_value, 0) as refund_value,

        coalesce(purchase_metrics.shipping_value, 0) as shipping_value,

        coalesce(purchase_metrics.tax_value, 0) as tax_value,

        coalesce(
            purchase_metrics.total_item_quantity,
            0
        ) as total_item_quantity,

        coalesce(purchase_metrics.unique_items, 0) as unique_items,

        purchase_metrics.transaction_count is not null as has_purchase

    from aggregated_sessions as sessions

    left join first_events
        on sessions.session_key = first_events.session_key

    left join last_events
        on sessions.session_key = last_events.session_key

    left join selected_acquisition_events
        on sessions.session_key = selected_acquisition_events.session_key

    left join purchase_metrics
        on sessions.session_key = purchase_metrics.session_key

)

select *
from session_enriched