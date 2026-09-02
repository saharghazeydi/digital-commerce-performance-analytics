with fact_totals as (

    select
        count(*) as session_count,
        countif(has_purchase) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue

    from {{ ref('fct_sessions') }}

),

mart_totals as (

    select
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count,
        sum(transaction_count) as transaction_count,
        sum(purchase_revenue) as purchase_revenue

    from {{ ref('mart_segment_daily') }}

)

select
    fact_totals.session_count as fact_session_count,
    mart_totals.session_count as mart_session_count,

    fact_totals.purchasing_session_count as fact_purchasing_session_count,
    mart_totals.purchasing_session_count as mart_purchasing_session_count,

    fact_totals.transaction_count as fact_transaction_count,
    mart_totals.transaction_count as mart_transaction_count,

    fact_totals.purchase_revenue as fact_purchase_revenue,
    mart_totals.purchase_revenue as mart_purchase_revenue

from fact_totals
cross join mart_totals

where
    fact_totals.session_count != mart_totals.session_count
    or fact_totals.purchasing_session_count != mart_totals.purchasing_session_count
    or fact_totals.transaction_count != mart_totals.transaction_count
    or abs(
        fact_totals.purchase_revenue - mart_totals.purchase_revenue
    ) > 0.000001