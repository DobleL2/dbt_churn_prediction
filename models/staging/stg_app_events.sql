{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'app_events') }}
),

renamed as (
    select
        event_id,
        user_id,
        event_timestamp,
        event_type,
        date(event_timestamp) as event_date,
        extract(hour from event_timestamp) as event_hour,
        extract(dow from event_timestamp) as event_day_of_week
    from source
)

select * from renamed

