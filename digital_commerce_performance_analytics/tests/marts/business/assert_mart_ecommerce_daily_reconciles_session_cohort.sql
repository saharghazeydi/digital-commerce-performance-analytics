with expected as (

    select
        session_date as date_day,

        count(*) as session_attributed_transaction_count,

        sum(coalesce(purchase_revenue, 0))
            as session_attributed_purchase_revenue

    from {{ ref('fct_transactions') }}

    group by
        session_date

),

actual as (

    select
        date_day,
        session_attributed_transaction_count,
        session_attributed_purchase_revenue

    from {{ ref('mart_ecommerce_daily') }}

),

validation as (

    select
        coalesce(a.date_day, e.date_day) as date_day,

        coalesce(a.session_attributed_transaction_count, 0)
            - coalesce(e.session_attributed_transaction_count, 0)
            as transaction_count_difference,

        coalesce(a.session_attributed_purchase_revenue, 0)
            - coalesce(e.session_attributed_purchase_revenue, 0)
            as purchase_revenue_difference

    from actual a

    full outer join expected e
        on a.date_day = e.date_day

)

select *
from validation

where
    transaction_count_difference != 0
    or abs(purchase_revenue_difference) > 0.001