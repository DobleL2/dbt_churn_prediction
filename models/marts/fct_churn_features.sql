{{ config(materialized='table') }}

with engagement as (
    select * from {{ ref('int_user_engagement') }}
),

churn_features as (
    select
        -- Identifiers
        user_id,
        email,
        country,
        plan_type,
        status,
        
        -- Target variable
        is_churned,
        days_to_churn,
        
        -- Time-based features
        signup_date,
        days_since_signup,
        datediff('month', signup_date, current_date) as months_since_signup,
        extract(month from signup_date) as signup_month,
        extract(quarter from signup_date) as signup_quarter,
        extract(dow from signup_date) as signup_day_of_week,
        
        -- Event-based features (10+ features)
        total_events,
        active_days,
        unique_event_types,
        login_count,
        view_count,
        click_count,
        feature_use_count,
        first_event_date,
        last_event_date,
        event_span_days,
        business_hours_ratio,
        active_weekdays,
        case 
            when days_since_signup > 0 
            then cast(total_events as double) / days_since_signup 
            else 0 
        end as events_per_day,
        case 
            when active_days > 0 
            then cast(total_events as double) / active_days 
            else 0 
        end as events_per_active_day,
        datediff('day', last_event_date, current_date) as days_since_last_event,
        case 
            when login_count > 0 
            then cast(feature_use_count as double) / login_count 
            else 0 
        end as feature_use_per_login,
        
        -- Billing features (8+ features)
        total_billing_records,
        successful_payments,
        failed_payments,
        total_amount_paid,
        avg_payment_amount,
        first_payment_date,
        last_payment_date,
        billing_span_days,
        payment_success_rate,
        case 
            when days_since_signup > 0 
            then cast(total_billing_records as double) / (days_since_signup / 30.0) 
            else 0 
        end as payments_per_month,
        datediff('day', last_payment_date, current_date) as days_since_last_payment,
        case 
            when plan_type = 'free' then 0
            when plan_type = 'pro' then 29.99
            when plan_type = 'premium' then 99.99
            else 0
        end as expected_monthly_revenue,
        
        -- Support features (8+ features)
        total_tickets,
        resolved_tickets,
        technical_tickets,
        billing_tickets,
        bug_tickets,
        feature_request_tickets,
        first_ticket_date,
        last_ticket_date,
        ticket_resolution_rate,
        case 
            when days_since_signup > 0 
            then cast(total_tickets as double) / days_since_signup 
            else 0 
        end as tickets_per_day,
        datediff('day', last_ticket_date, current_date) as days_since_last_ticket,
        case 
            when total_tickets > 0 
            then cast(bug_tickets as double) / total_tickets 
            else 0 
        end as bug_ticket_ratio,
        
        -- Marketing features (6+ features)
        total_campaigns,
        acquisition_campaigns,
        retention_campaigns,
        upsell_campaigns,
        engaged_campaigns,
        campaign_engagement_rate,
        
        -- Derived engagement features
        case 
            when days_since_signup > 0 and active_days > 0
            then cast(active_days as double) / days_since_signup 
            else 0 
        end as activity_rate,
        case 
            when total_events > 0 
            then cast(login_count as double) / total_events 
            else 0 
        end as login_ratio,
        case 
            when total_events > 0 
            then cast(click_count as double) / total_events 
            else 0 
        end as click_ratio,
        
        -- Plan type flags
        case when plan_type = 'free' then 1 else 0 end as is_free_plan,
        case when plan_type = 'pro' then 1 else 0 end as is_pro_plan,
        case when plan_type = 'premium' then 1 else 0 end as is_premium_plan,
        
        -- Country flags (top countries)
        case when country = 'US' then 1 else 0 end as is_us,
        case when country in ('UK', 'CA', 'MX', 'BR', 'AR', 'ES') then 1 else 0 end as is_international,
        
        -- Risk indicators
        case 
            when failed_payments > 0 then 1 
            else 0 
        end as has_failed_payments,
        case 
            when total_tickets > 3 then 1 
            else 0 
        end as has_high_support_volume,
        case 
            when days_since_last_event > 30 then 1 
            else 0 
        end as is_inactive_30d,
        case 
            when days_since_last_event > 7 then 1 
            else 0 
        end as is_inactive_7d,
        
        -- Current timestamp for tracking
        current_timestamp as feature_generated_at
        
    from engagement
)

select * from churn_features

