select
    transaction_id,
    purchase_revenue,
    shipping_value,
    tax_value
from {{ ref('fct_transactions') }}
where
    purchase_revenue < 0
    or shipping_value < 0
    or tax_value < 0