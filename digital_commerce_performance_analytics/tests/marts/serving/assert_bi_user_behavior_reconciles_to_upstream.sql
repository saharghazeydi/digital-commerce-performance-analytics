-- Fails when the BI user-behavior serving view does not preserve
-- the population of its governed upstream model.

with upstream_count as (

    select count(*) as row_count
    from {{ ref('mart_user_behavior') }}

),

serving_count as (

    select count(*) as row_count
    from {{ ref('bi_user_behavior') }}

)

select
    upstream_count.row_count as upstream_row_count,
    serving_count.row_count as serving_row_count
from upstream_count
cross join serving_count
where upstream_count.row_count != serving_count.row_count
