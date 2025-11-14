{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'users') }}
),

renamed as (
    select
        user_id,
        email,
        signup_date,
        country,
        plan_type,
        status,
        churn_date,
        case 
            when status = 'deactivated' then true 
            else false 
        end as is_churned,
        case 
            when churn_date is not null 
            then datediff('day', signup_date, churn_date)
            else null
        end as days_to_churn
    from source
)

select * from renamed

