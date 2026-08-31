select
    user_pseudo_id,

    session_count,
    active_date_count,
    purchasing_session_count,
    purchasing_date_count,

    first_observed_session_date,
    last_observed_session_date,
    first_observed_purchase_date,
    last_observed_purchase_date,

    is_purchasing_user,
    is_multi_session_user,
    returned_on_later_date,
    is_repeat_purchasing_session_user,
    is_repeat_purchasing_date_user

from {{ ref('mart_user_behavior') }}

where
    first_observed_session_date > last_observed_session_date

    or (
        purchasing_session_count = 0
        and (
            first_observed_purchase_date is not null
            or last_observed_purchase_date is not null
        )
    )

    or (
        purchasing_session_count > 0
        and (
            first_observed_purchase_date is null
            or last_observed_purchase_date is null
        )
    )

    or first_observed_purchase_date > last_observed_purchase_date

    or is_purchasing_user
        != (purchasing_session_count > 0)

    or is_multi_session_user
        != (session_count > 1)

    or returned_on_later_date
        != (active_date_count > 1)

    or is_repeat_purchasing_session_user
        != (purchasing_session_count > 1)

    or is_repeat_purchasing_date_user
        != (purchasing_date_count > 1)