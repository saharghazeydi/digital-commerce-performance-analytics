with expected as (

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

actual as (

    select
        date_day,
        transaction_count,
        purchase_revenue,
        refund_value,
        shipping_value,
        tax_value,
        total_item_quantity

    from {{ ref('mart_ecommerce_daily') }}

),

validation as (

    select
        coalesce(a.date_day, e.date_day) as date_day,

        coalesce(a.transaction_count, 0)
            - coalesce(e.transaction_count, 0)
            as transaction_count_difference,

        coalesce(a.purchase_revenue, 0)
            - coalesce(e.purchase_revenue, 0)
            as purchase_revenue_difference,

        coalesce(a.refund_value, 0)
            - coalesce(e.refund_value, 0)
            as refund_value_difference,

        coalesce(a.shipping_value, 0)
            - coalesce(e.shipping_value, 0)
            as shipping_value_difference,

        coalesce(a.tax_value, 0)
            - coalesce(e.tax_value, 0)
            as tax_value_difference,

        coalesce(a.total_item_quantity, 0)
            - coalesce(e.total_item_quantity, 0)
            as total_item_quantity_difference

    from actual a

    full outer join expected e
        on a.date_day = e.date_day

)

select *
from validation

where
    transaction_count_difference != 0
    or abs(purchase_revenue_difference) > 0.001
    or abs(refund_value_difference) > 0.001
    or abs(shipping_value_difference) > 0.001
    or abs(tax_value_difference) > 0.001
    or total_item_quantity_difference != 0