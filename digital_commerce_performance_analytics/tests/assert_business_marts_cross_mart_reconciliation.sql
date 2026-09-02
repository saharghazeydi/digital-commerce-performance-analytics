with mart_totals as (

    select
        'mart_channel_daily' as mart_name,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue
    from {{ ref('mart_channel_daily') }}

    union all

    select
        'mart_ecommerce_daily' as mart_name,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(session_attributed_transaction_count) as transaction_count,
        sum(session_attributed_purchase_revenue) as purchase_revenue
    from {{ ref('mart_ecommerce_daily') }}

    union all

    select
        'mart_segment_daily' as mart_name,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue
    from {{ ref('mart_segment_daily') }}

    union all

    select
        'mart_user_behavior' as mart_name,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue
    from {{ ref('mart_user_behavior') }}

),

reference_totals as (

    select *
    from mart_totals
    where mart_name = 'mart_channel_daily'

),

validation as (

    select
        mart_totals.mart_name,

        mart_totals.session_count
            - reference_totals.session_count
            as session_count_difference,

        mart_totals.purchasing_session_count
            - reference_totals.purchasing_session_count
            as purchasing_session_count_difference,

        mart_totals.transaction_count
            - reference_totals.transaction_count
            as transaction_count_difference,

        mart_totals.purchase_revenue
            - reference_totals.purchase_revenue
            as purchase_revenue_difference

    from mart_totals
    cross join reference_totals

)

select *
from validation
where
    session_count_difference != 0
    or purchasing_session_count_difference != 0
    or transaction_count_difference != 0
    or abs(purchase_revenue_difference) > 0.01