{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'billing') }}
),

renamed as (
    select
        billing_id,
        user_id,
        billing_date,
        amount,
        status as billing_status,
        case 
            when status = 'success' then true 
            else false 
        end as is_payment_successful
    from source
)

select * from renamed

