select
    session_date,
    device_category,
    country

from {{ ref('mart_segment_daily') }}

where
    device_category is null
    or trim(device_category) = ''
    or lower(trim(device_category)) = '(not set)'

    or country is null
    or trim(country) = ''
    or lower(trim(country)) = '(not set)'