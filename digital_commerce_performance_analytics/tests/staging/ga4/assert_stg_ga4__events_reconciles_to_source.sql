-- Fails when the number of staged GA4 events does not reconcile
-- to the number of source events in the approved extraction window.

with source_count as (

    select
        count(*) as row_count
    from {{ source('ga4', 'events') }}
    where _TABLE_SUFFIX between '20201101' and '20210131'

),

staging_count as (

    select
        count(*) as row_count
    from {{ ref('stg_ga4__events') }}

)

select
    source_count.row_count as source_row_count,
    staging_count.row_count as staging_row_count
from source_count
cross join staging_count
where source_count.row_count != staging_count.row_count
