with

base as (

    select
        date_day,

        session_count,
        purchasing_session_count,

        transaction_count,
        purchase_revenue,

        session_attributed_transaction_count,
        session_attributed_purchase_revenue

    from {{ ref('executive_kpi_daily') }}

),

trends as (

    select
        date_day,

        session_count,
        purchasing_session_count,

        transaction_count,
        purchase_revenue,

        session_attributed_transaction_count,
        session_attributed_purchase_revenue

    from {{ ref('executive_kpi_trends_daily') }}

),

drivers as (

    select
        session_date,

        sum(session_count)
            as session_count,

        sum(purchasing_session_count)
            as purchasing_session_count,

        sum(session_attributed_transaction_count)
            as session_attributed_transaction_count,

        sum(session_attributed_purchase_revenue)
            as session_attributed_purchase_revenue

    from {{ ref('executive_channel_drivers_daily') }}

    group by
        session_date

),

reconciliation as (

    select
        coalesce(
            base.date_day,
            trends.date_day,
            drivers.session_date
        ) as date_day

    from base

    full outer join trends
        on base.date_day = trends.date_day

    full outer join drivers
        on coalesce(base.date_day, trends.date_day)
            = drivers.session_date

    where

        -- Date coverage must remain aligned across
        -- the executive base, trend, and driver branches.

        base.date_day is null
        or trends.date_day is null
        or drivers.session_date is null

        -- The trend layer must preserve the governed
        -- base additive populations without drift.

        or base.session_count
            is distinct from trends.session_count

        or base.purchasing_session_count
            is distinct from trends.purchasing_session_count

        or base.transaction_count
            is distinct from trends.transaction_count

        or base.purchase_revenue
            is distinct from trends.purchase_revenue

        or base.session_attributed_transaction_count
            is distinct from trends.session_attributed_transaction_count

        or base.session_attributed_purchase_revenue
            is distinct from trends.session_attributed_purchase_revenue

        -- The driver branch uses session-date and
        -- session-attributed semantics. Therefore only
        -- compatible populations are reconciled to base.

        or base.session_count
            is distinct from drivers.session_count

        or base.purchasing_session_count
            is distinct from drivers.purchasing_session_count

        or base.session_attributed_transaction_count
            is distinct from drivers.session_attributed_transaction_count

        or base.session_attributed_purchase_revenue
            is distinct from drivers.session_attributed_purchase_revenue

)

select *
from reconciliation