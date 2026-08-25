select
    session_key,
    medium,
    channel_key
from {{ ref('fct_sessions') }}
where channel_key !=
    case
        when medium is null
            or medium = '(data deleted)'
            then 8

        when medium = '(none)'
            then 1

        when medium = 'organic'
            then 2

        when medium = 'cpc'
            then 3

        when medium = 'referral'
            then 4

        when medium = 'email'
            then 5

        when medium = 'affiliate'
            then 6

        else 7
    end