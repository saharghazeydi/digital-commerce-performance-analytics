-- Fails when the event staging model contains records
-- outside the approved GA4 extraction window.

select
    event_date
from {{ ref('stg_ga4__events') }}
where event_date < date '2020-11-01'
   or event_date > date '2021-01-31'