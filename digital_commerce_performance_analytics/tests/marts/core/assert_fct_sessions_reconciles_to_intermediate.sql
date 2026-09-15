-- Fails when the core session fact does not preserve
-- the session population from the intermediate session model.

with intermediate_count as (

    select count(*) as row_count
    from {{ ref('int_ga4__sessions') }}

),

core_count as (

    select count(*) as row_count
    from {{ ref('fct_sessions') }}

)

select
    intermediate_count.row_count as intermediate_row_count,
    core_count.row_count as core_row_count
from intermediate_count
cross join core_count
where intermediate_count.row_count != core_count.row_count
