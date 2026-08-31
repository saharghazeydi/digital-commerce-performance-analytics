with expected as (

    select
        session_date as date_day,
        count(*) as session_count,
        countif(has_purchase) as purchasing_session_count

    from {{ ref('fct_sessions') }}

    group by
        session_date

),

actual as (

    select
        date_day,
        session_count,
        purchasing_session_count

    from {{ ref('mart_ecommerce_daily') }}

),

validation as (

    select
        coalesce(a.date_day, e.date_day) as date_day,

        coalesce(a.session_count, 0)
            - coalesce(e.session_count, 0)
            as session_count_difference,

        coalesce(a.purchasing_session_count, 0)
            - coalesce(e.purchasing_session_count, 0)
            as purchasing_session_count_difference

    from actual a

    full outer join expected e
        on a.date_day = e.date_day

)

select *
from validation

where
    session_count_difference != 0
    or purchasing_session_count_difference != 0