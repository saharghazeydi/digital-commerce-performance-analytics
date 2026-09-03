with

daily_contributions as (

    select
        session_date,

        sum(session_count)
            as total_session_count,

        sum(purchasing_session_count)
            as total_purchasing_session_count,

        sum(session_attributed_transaction_count)
            as total_transaction_count,

        sum(session_attributed_purchase_revenue)
            as total_purchase_revenue,

        sum(session_contribution)
            as session_contribution_sum,

        sum(purchasing_session_contribution)
            as purchasing_session_contribution_sum,

        sum(transaction_contribution)
            as transaction_contribution_sum,

        sum(revenue_contribution)
            as revenue_contribution_sum

    from {{ ref('executive_channel_drivers_daily') }}

    group by
        session_date

)

select *
from daily_contributions

where

    (
        total_session_count > 0
        and abs(session_contribution_sum - 1.0) > 0.000001
    )

    or

    (
        total_purchasing_session_count > 0
        and abs(purchasing_session_contribution_sum - 1.0) > 0.000001
    )

    or

    (
        total_transaction_count > 0
        and abs(transaction_contribution_sum - 1.0) > 0.000001
    )

    or

    (
        total_purchase_revenue > 0
        and abs(revenue_contribution_sum - 1.0) > 0.000001
    )