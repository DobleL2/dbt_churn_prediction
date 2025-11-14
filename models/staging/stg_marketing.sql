{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'marketing') }}
),

renamed as (
    select
        campaign_id,
        user_id,
        campaign_date,
        campaign_type,
        channel,
        engaged
    from source
)

select * from renamed

