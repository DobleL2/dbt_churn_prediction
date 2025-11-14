{{ config(materialized='view') }}

with billing as (
    select * from {{ ref('stg_billing') }}
),

billing_summary as (
    select
        user_id,
        count(*) as total_billing_records,
        count(case when is_payment_successful then 1 end) as successful_payments,
        count(case when not is_payment_successful then 1 end) as failed_payments,
        sum(amount) as total_amount_paid,
        avg(amount) as avg_payment_amount,
        min(billing_date) as first_payment_date,
        max(billing_date) as last_payment_date,
        datediff('day', min(billing_date), max(billing_date)) as billing_span_days,
        case 
            when count(*) > 0 
            then cast(count(case when is_payment_successful then 1 end) as double) / count(*) 
            else 0 
        end as payment_success_rate
    from billing
    group by user_id
)

select * from billing_summary

