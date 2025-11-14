{{ config(materialized='view') }}

with users as (
    select * from {{ ref('stg_users') }}
),

events_agg as (
    select * from {{ ref('int_user_events_aggregated') }}
),

billing_summary as (
    select * from {{ ref('int_user_billing_summary') }}
),

support_metrics as (
    select * from {{ ref('int_user_support_metrics') }}
),

marketing as (
    select * from {{ ref('stg_marketing') }}
),

marketing_agg as (
    select
        user_id,
        count(*) as total_campaigns,
        count(case when campaign_type = 'acquisition' then 1 end) as acquisition_campaigns,
        count(case when campaign_type = 'retention' then 1 end) as retention_campaigns,
        count(case when campaign_type = 'upsell' then 1 end) as upsell_campaigns,
        count(case when engaged then 1 end) as engaged_campaigns,
        case 
            when count(*) > 0 
            then cast(count(case when engaged then 1 end) as double) / count(*) 
            else 0 
        end as campaign_engagement_rate
    from marketing
    group by user_id
),

engagement as (
    select
        u.user_id,
        u.email,
        u.signup_date,
        u.country,
        u.plan_type,
        u.status,
        u.is_churned,
        u.days_to_churn,
        datediff('day', u.signup_date, current_date) as days_since_signup,
        
        -- Event metrics
        coalesce(e.total_events, 0) as total_events,
        coalesce(e.active_days, 0) as active_days,
        coalesce(e.unique_event_types, 0) as unique_event_types,
        coalesce(e.login_count, 0) as login_count,
        coalesce(e.view_count, 0) as view_count,
        coalesce(e.click_count, 0) as click_count,
        coalesce(e.feature_use_count, 0) as feature_use_count,
        e.first_event_date,
        e.last_event_date,
        coalesce(e.event_span_days, 0) as event_span_days,
        coalesce(e.business_hours_ratio, 0) as business_hours_ratio,
        coalesce(e.active_weekdays, 0) as active_weekdays,
        
        -- Billing metrics
        coalesce(b.total_billing_records, 0) as total_billing_records,
        coalesce(b.successful_payments, 0) as successful_payments,
        coalesce(b.failed_payments, 0) as failed_payments,
        coalesce(b.total_amount_paid, 0) as total_amount_paid,
        coalesce(b.avg_payment_amount, 0) as avg_payment_amount,
        b.first_payment_date,
        b.last_payment_date,
        coalesce(b.billing_span_days, 0) as billing_span_days,
        coalesce(b.payment_success_rate, 0) as payment_success_rate,
        
        -- Support metrics
        coalesce(s.total_tickets, 0) as total_tickets,
        coalesce(s.resolved_tickets, 0) as resolved_tickets,
        coalesce(s.technical_tickets, 0) as technical_tickets,
        coalesce(s.billing_tickets, 0) as billing_tickets,
        coalesce(s.bug_tickets, 0) as bug_tickets,
        coalesce(s.feature_request_tickets, 0) as feature_request_tickets,
        s.first_ticket_date,
        s.last_ticket_date,
        coalesce(s.ticket_resolution_rate, 0) as ticket_resolution_rate,
        
        -- Marketing metrics
        coalesce(m.total_campaigns, 0) as total_campaigns,
        coalesce(m.acquisition_campaigns, 0) as acquisition_campaigns,
        coalesce(m.retention_campaigns, 0) as retention_campaigns,
        coalesce(m.upsell_campaigns, 0) as upsell_campaigns,
        coalesce(m.engaged_campaigns, 0) as engaged_campaigns,
        coalesce(m.campaign_engagement_rate, 0) as campaign_engagement_rate
        
    from users u
    left join events_agg e on u.user_id = e.user_id
    left join billing_summary b on u.user_id = b.user_id
    left join support_metrics s on u.user_id = s.user_id
    left join marketing_agg m on u.user_id = m.user_id
)

select * from engagement

