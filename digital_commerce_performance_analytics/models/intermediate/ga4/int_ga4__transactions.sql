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

sessions as (

    select *
    from {{ ref('int_ga4__sessions') }}

),

deduplicated_transactions as (

    select
        normalized_transaction_id as transaction_id,
        session_key,
        user_pseudo_id,

        event_date as transaction_date,
        event_timestamp as transaction_timestamp,

        purchase_revenue,
        refund_value,
        shipping_value,
        tax_value,
        total_item_quantity,
        unique_items

    from session_events

    where is_first_valid_purchase

),

transactions_enriched as (

    select
        transactions.transaction_id,
        transactions.session_key,
        transactions.user_pseudo_id,

        transactions.transaction_date,
        transactions.transaction_timestamp,

        sessions.ga_session_id,
        sessions.ga_session_number,
        sessions.session_date,
        sessions.session_start_timestamp,
        sessions.session_end_timestamp,

        sessions.platform,
        sessions.landing_page,
        sessions.landing_page_title,

        sessions.source,
        sessions.medium,
        sessions.campaign,

        coalesce(transactions.purchase_revenue, 0) as purchase_revenue,
        coalesce(transactions.refund_value, 0) as refund_value,
        coalesce(transactions.shipping_value, 0) as shipping_value,
        coalesce(transactions.tax_value, 0) as tax_value,
        coalesce(transactions.total_item_quantity, 0) as total_item_quantity,
        coalesce(transactions.unique_items, 0) as unique_items

    from deduplicated_transactions as transactions

    left join sessions
        on transactions.session_key = sessions.session_key

)

select *
from transactions_enriched