{{ config(
    materialized='table'
) }}

with session_user as (

    select
        user_pseudo_id,

        count(*) as session_count,

        count(distinct session_date) as active_date_count,

        countif(has_purchase) as purchasing_session_count,

        count(
            distinct if(
                has_purchase,
                session_date,
                null
            )
        ) as purchasing_date_count,

        min(session_date) as first_observed_session_date,

        max(session_date) as last_observed_session_date,

        min(
            if(
                has_purchase,
                session_date,
                null
            )
        ) as first_observed_purchase_date,

        max(
            if(
                has_purchase,
                session_date,
                null
            )
        ) as last_observed_purchase_date

    from {{ ref('fct_sessions') }}

    group by
        user_pseudo_id

),

transaction_user as (

    select
        user_pseudo_id,

        count(*) as transaction_count,

        sum(coalesce(purchase_revenue, 0)) as purchase_revenue,

        sum(coalesce(refund_value, 0)) as refund_value,

        sum(coalesce(total_item_quantity, 0)) as total_item_quantity

    from {{ ref('fct_transactions') }}

    group by
        user_pseudo_id

),

user_behavior as (

    select
        s.user_pseudo_id,

        s.session_count,
        s.active_date_count,
        s.purchasing_session_count,
        s.purchasing_date_count,

        s.first_observed_session_date,
        s.last_observed_session_date,

        s.first_observed_purchase_date,
        s.last_observed_purchase_date,

        date_diff(
            s.last_observed_session_date,
            s.first_observed_session_date,
            day
        ) as observed_user_span_days,

        coalesce(t.transaction_count, 0) as transaction_count,

        coalesce(t.purchase_revenue, 0) as purchase_revenue,

        coalesce(t.refund_value, 0) as refund_value,

        coalesce(t.total_item_quantity, 0) as total_item_quantity,

        s.purchasing_session_count > 0 as is_purchasing_user,

        s.session_count > 1 as is_multi_session_user,

        s.active_date_count > 1 as returned_on_later_date,

        s.purchasing_session_count > 1
            as is_repeat_purchasing_session_user,

        s.purchasing_date_count > 1
            as is_repeat_purchasing_date_user

    from session_user as s

    left join transaction_user as t
        on s.user_pseudo_id = t.user_pseudo_id

)

select
    user_pseudo_id,

    session_count,
    active_date_count,
    purchasing_session_count,
    purchasing_date_count,

    first_observed_session_date,
    last_observed_session_date,
    first_observed_purchase_date,
    last_observed_purchase_date,
    observed_user_span_days,

    transaction_count,
    purchase_revenue,
    refund_value,
    total_item_quantity,

    is_purchasing_user,
    is_multi_session_user,
    returned_on_later_date,
    is_repeat_purchasing_session_user,
    is_repeat_purchasing_date_user

from user_behavior