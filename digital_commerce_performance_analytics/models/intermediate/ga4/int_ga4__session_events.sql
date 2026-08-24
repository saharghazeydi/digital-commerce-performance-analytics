{{ config(
    materialized='table'
) }}

with staged_events as (

    select *
    from {{ ref('stg_ga4__events') }}

),

session_keys as (

    select

        {{ generate_surrogate_key([
            'user_pseudo_id',
            'ga_session_id'
        ]) }} as session_key,

        *

    from staged_events

),

normalized_events as (

    select

        *,

        case
            when nullif(trim(transaction_id), '') is null
                then null

            when lower(trim(transaction_id)) in (
                '(not set)',
                'not set'
            )
                then null

            else trim(transaction_id)
        end as normalized_transaction_id

    from session_keys

),

classified_events as (

    select

        *,

        case
            when nullif(trim(source), '') is not null
                and nullif(trim(medium), '') is not null
                and nullif(trim(campaign), '') is not null
                then 1

            when nullif(trim(source), '') is not null
                or nullif(trim(medium), '') is not null
                or nullif(trim(campaign), '') is not null
                then 2

            else 3
        end as acquisition_priority,

        normalized_transaction_id is not null
            as is_valid_purchase

    from normalized_events

),

ordered_events as (

    select

        *,

        row_number() over (
            partition by session_key
            order by event_timestamp, event_name
        ) as event_sequence_number,

        row_number() over (
            partition by session_key
            order by event_timestamp desc, event_name desc
        ) as reverse_event_sequence_number,

        row_number() over (
            partition by session_key
            order by
                acquisition_priority,
                event_timestamp,
                event_name
        ) as acquisition_sequence_number,

        case
            when is_valid_purchase then
                row_number() over (
                    partition by
                        if(
                            is_valid_purchase,
                            normalized_transaction_id,
                            concat('__invalid__', session_key)
                        )
                    order by
                        event_timestamp,
                        event_name,
                        session_key
                )
        end as purchase_sequence_number

    from classified_events

),

session_events as (

    select

        *,

        event_sequence_number = 1
            as is_first_event,

        reverse_event_sequence_number = 1
            as is_last_event,

        acquisition_sequence_number = 1
            and acquisition_priority < 3
            as is_selected_acquisition_event,

        is_valid_purchase
            and purchase_sequence_number = 1
            as is_first_valid_purchase

    from ordered_events

)

select *
from session_events