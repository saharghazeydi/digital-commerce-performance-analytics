select
    session_key,
    source,
    medium,
    landing_page_referrer,
    has_selected_acquisition,
    channel_key
from {{ ref('fct_sessions') }}
where channel_key !=
    case

        when has_selected_acquisition then

            case
                when lower(trim(source)) = '(data deleted)'
                    or lower(trim(medium)) = '(data deleted)'
                    then 8

                when lower(trim(source)) = '(direct)'
                    or lower(trim(medium)) = '(none)'
                    then 1

                when lower(trim(medium)) = 'organic'
                    then 2

                when lower(trim(medium)) = 'cpc'
                    then 3

                when lower(trim(medium)) = 'referral'
                    then 4

                when lower(trim(medium)) = 'email'
                    then 5

                when lower(trim(medium)) = 'affiliate'
                    then 6

                when nullif(trim(medium), '') is null
                    then 8

                else 7
            end

        when nullif(trim(landing_page_referrer), '') is null
            then 1

        when lower(
            regexp_extract(
                trim(landing_page_referrer),
                r'^https?://([^/:?#]+)'
            )
        ) = 'shop.googlemerchandisestore.com'
            then 1

        else 8

    end
    