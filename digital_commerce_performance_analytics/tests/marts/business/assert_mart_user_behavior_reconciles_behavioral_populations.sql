with source_user_behavior as (

    select
        user_pseudo_id,

        count(*) as session_count,
        count(distinct session_date) as active_date_count,
        countif(has_purchase) as purchasing_session_count,

        count(
            distinct if(
                has_purchase,
                session_date,
                null
            )
        ) as purchasing_date_count

    from {{ ref('fct_sessions') }}

    group by
        user_pseudo_id

),

source_populations as (

    select
        countif(purchasing_session_count > 0)
            as purchasing_user_count,

        countif(session_count > 1)
            as multi_session_user_count,

        countif(active_date_count > 1)
            as returned_on_later_date_user_count,

        countif(purchasing_session_count > 1)
            as repeat_purchasing_session_user_count,

        countif(purchasing_date_count > 1)
            as repeat_purchasing_date_user_count

    from source_user_behavior

),

mart_populations as (

    select
        countif(is_purchasing_user)
            as purchasing_user_count,

        countif(is_multi_session_user)
            as multi_session_user_count,

        countif(returned_on_later_date)
            as returned_on_later_date_user_count,

        countif(is_repeat_purchasing_session_user)
            as repeat_purchasing_session_user_count,

        countif(is_repeat_purchasing_date_user)
            as repeat_purchasing_date_user_count

    from {{ ref('mart_user_behavior') }}

)

select
    mart.purchasing_user_count
        as mart_purchasing_user_count,
    source.purchasing_user_count
        as source_purchasing_user_count,

    mart.multi_session_user_count
        as mart_multi_session_user_count,
    source.multi_session_user_count
        as source_multi_session_user_count,

    mart.returned_on_later_date_user_count
        as mart_returned_on_later_date_user_count,
    source.returned_on_later_date_user_count
        as source_returned_on_later_date_user_count,

    mart.repeat_purchasing_session_user_count
        as mart_repeat_purchasing_session_user_count,
    source.repeat_purchasing_session_user_count
        as source_repeat_purchasing_session_user_count,

    mart.repeat_purchasing_date_user_count
        as mart_repeat_purchasing_date_user_count,
    source.repeat_purchasing_date_user_count
        as source_repeat_purchasing_date_user_count

from mart_populations as mart
cross join source_populations as source

where
    mart.purchasing_user_count
        != source.purchasing_user_count

    or mart.multi_session_user_count
        != source.multi_session_user_count

    or mart.returned_on_later_date_user_count
        != source.returned_on_later_date_user_count

    or mart.repeat_purchasing_session_user_count
        != source.repeat_purchasing_session_user_count

    or mart.repeat_purchasing_date_user_count
        != source.repeat_purchasing_date_user_count