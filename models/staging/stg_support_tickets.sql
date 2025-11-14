{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'support_tickets') }}
),

renamed as (
    select
        ticket_id,
        user_id,
        created_date,
        ticket_type,
        status as ticket_status,
        case 
            when status = 'resolved' then true 
            else false 
        end as is_resolved
    from source
)

select * from renamed

