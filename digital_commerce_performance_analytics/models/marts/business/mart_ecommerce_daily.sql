{{ config(
    materialized = 'table'
) }}

with

date_spine as (

    select
        date_day,
        year,
        quarter,
        quarter_name,
        month_number,
        month_name,
        year_month,
        week_of_year,
        day_of_month,
        day_of_week,
        day_name,
        is_weekend

    from {{ ref('dim_date') }}

),

session_daily as (

    select
        session_date as date_day,

        count(*) as session_count,
        countif(has_purchase) as purchasing_session_count

    from {{ ref('fct_sessions') }}

    group by
        session_date

),

transaction_daily as (

    select
        transaction_date as date_day,

        count(*) as transaction_count,
        sum(coalesce(purchase_revenue, 0)) as purchase_revenue,
        sum(coalesce(refund_value, 0)) as refund_value,
        sum(coalesce(shipping_value, 0)) as shipping_value,
        sum(coalesce(tax_value, 0)) as tax_value,
        sum(coalesce(total_item_quantity, 0)) as total_item_quantity

    from {{ ref('fct_transactions') }}

    group by
        transaction_date

),

session_cohort_daily as (

    select
        session_date as date_day,

        count(*) as session_attributed_transaction_count,
        sum(coalesce(purchase_revenue, 0))
            as session_attributed_purchase_revenue

    from {{ ref('fct_transactions') }}

    group by
        session_date

),

final as (

    select
        d.date_day,
        d.year,
        d.quarter,
        d.quarter_name,
        d.month_number,
        d.month_name,
        d.year_month,
        d.week_of_year,
        d.day_of_month,
        d.day_of_week,
        d.day_name,
        d.is_weekend,

        coalesce(s.session_count, 0) as session_count,
        coalesce(s.purchasing_session_count, 0)
            as purchasing_session_count,

        safe_divide(
            coalesce(s.purchasing_session_count, 0),
            nullif(coalesce(s.session_count, 0), 0)
        ) as conversion_rate,

        coalesce(t.transaction_count, 0) as transaction_count,
        coalesce(t.purchase_revenue, 0) as purchase_revenue,
        coalesce(t.refund_value, 0) as refund_value,
        coalesce(t.shipping_value, 0) as shipping_value,
        coalesce(t.tax_value, 0) as tax_value,
        coalesce(t.total_item_quantity, 0) as total_item_quantity,

        safe_divide(
            coalesce(t.purchase_revenue, 0),
            nullif(coalesce(t.transaction_count, 0), 0)
        ) as average_order_value,

        safe_divide(
            coalesce(t.total_item_quantity, 0),
            nullif(coalesce(t.transaction_count, 0), 0)
        ) as items_per_transaction,

        coalesce(c.session_attributed_transaction_count, 0)
            as session_attributed_transaction_count,

        coalesce(c.session_attributed_purchase_revenue, 0)
            as session_attributed_purchase_revenue,

        safe_divide(
            coalesce(c.session_attributed_purchase_revenue, 0),
            nullif(coalesce(s.session_count, 0), 0)
        ) as revenue_per_session,

        safe_divide(
            coalesce(c.session_attributed_transaction_count, 0),
            nullif(coalesce(s.purchasing_session_count, 0), 0)
        ) as transactions_per_purchasing_session

    from date_spine d

    left join session_daily s
        on d.date_day = s.date_day

    left join transaction_daily t
        on d.date_day = t.date_day

    left join session_cohort_daily c
        on d.date_day = c.date_day

)

select *
from final