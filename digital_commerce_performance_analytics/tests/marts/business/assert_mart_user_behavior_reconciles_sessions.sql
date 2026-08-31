with mart_totals as (

    select
        count(*) as user_count,
        sum(session_count) as session_count,
        sum(purchasing_session_count) as purchasing_session_count

    from {{ ref('mart_user_behavior') }}

),

source_totals as (

    select
        count(distinct user_pseudo_id) as user_count,
        count(*) as session_count,
        countif(has_purchase) as purchasing_session_count

    from {{ ref('fct_sessions') }}

)

select
    mart.user_count as mart_user_count,
    source.user_count as source_user_count,

    mart.session_count as mart_session_count,
    source.session_count as source_session_count,

    mart.purchasing_session_count as mart_purchasing_session_count,
    source.purchasing_session_count as source_purchasing_session_count

from mart_totals as mart
cross join source_totals as source

where
    mart.user_count != source.user_count
    or mart.session_count != source.session_count
    or mart.purchasing_session_count != source.purchasing_session_count