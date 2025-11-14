{{ config(materialized='view') }}

with support as (
    select * from {{ ref('stg_support_tickets') }}
),

support_metrics as (
    select
        user_id,
        count(*) as total_tickets,
        count(case when is_resolved then 1 end) as resolved_tickets,
        count(case when ticket_type = 'technical' then 1 end) as technical_tickets,
        count(case when ticket_type = 'billing' then 1 end) as billing_tickets,
        count(case when ticket_type = 'bug' then 1 end) as bug_tickets,
        count(case when ticket_type = 'feature_request' then 1 end) as feature_request_tickets,
        min(created_date) as first_ticket_date,
        max(created_date) as last_ticket_date,
        case 
            when count(*) > 0 
            then cast(count(case when is_resolved then 1 end) as double) / count(*) 
            else 0 
        end as ticket_resolution_rate
    from support
    group by user_id
)

select * from support_metrics

