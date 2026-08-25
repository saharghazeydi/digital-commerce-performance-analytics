/*
===============================================================================
Model   : dim_channel
Project : Digital Commerce Performance Analytics
Layer   : Core Warehouse
Grain   : One row per governed channel group
Purpose : Provide a stable business-facing acquisition channel dimension for
          downstream analytics and BI reporting.
===============================================================================
*/

with channel_groups as (

    select
        1 as channel_key,
        'Direct' as channel_group,
        'Sessions with no referring marketing medium.' as channel_description,
        1 as sort_order

    union all

    select
        2,
        'Organic Search',
        'Sessions acquired through unpaid search engine traffic.',
        2

    union all

    select
        3,
        'Paid Search',
        'Sessions acquired through paid search advertising.',
        3

    union all

    select
        4,
        'Referral',
        'Sessions referred from another website or digital property.',
        4

    union all

    select
        5,
        'Email',
        'Sessions acquired through email marketing activity.',
        5

    union all

    select
        6,
        'Affiliate',
        'Sessions acquired through affiliate or partner traffic.',
        6

    union all

    select
        7,
        'Other',
        'Sessions with a recognized medium that is not mapped to a governed channel.',
        7

    union all

    select
        8,
        'Unknown',
        'Sessions where acquisition information is missing or unavailable.',
        8

)

select
    channel_key,
    channel_group,
    channel_description,
    sort_order
from channel_groups