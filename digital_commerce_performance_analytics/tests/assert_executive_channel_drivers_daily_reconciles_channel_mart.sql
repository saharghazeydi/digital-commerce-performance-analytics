with

expected as (

    select
        session_date,
        channel_key,
        channel_group,
        channel_description,
        sort_order,

        session_count,
        purchasing_session_count,

        transaction_count
            as session_attributed_transaction_count,

        purchase_revenue
            as session_attributed_purchase_revenue

    from {{ ref('mart_channel_daily') }}

),

actual as (

    select
        session_date,
        channel_key,
        channel_group,
        channel_description,
        sort_order,

        session_count,
        purchasing_session_count,
        session_attributed_transaction_count,
        session_attributed_purchase_revenue

    from {{ ref('executive_channel_drivers_daily') }}

),

reconciliation as (

    select
        coalesce(actual.session_date, expected.session_date)
            as session_date,

        coalesce(actual.channel_key, expected.channel_key)
            as channel_key

    from actual

    full outer join expected
        on actual.session_date = expected.session_date
        and actual.channel_key = expected.channel_key

    where
        actual.session_date is null
        or expected.session_date is null

        or actual.channel_group
            is distinct from expected.channel_group

        or actual.channel_description
            is distinct from expected.channel_description

        or actual.sort_order
            is distinct from expected.sort_order

        or actual.session_count
            is distinct from expected.session_count

        or actual.purchasing_session_count
            is distinct from expected.purchasing_session_count

        or actual.session_attributed_transaction_count
            is distinct from expected.session_attributed_transaction_count

        or actual.session_attributed_purchase_revenue
            is distinct from expected.session_attributed_purchase_revenue

)

select *
from reconciliation