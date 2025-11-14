{{ config(materialized='view') }}

with events as (
    select * from {{ ref('stg_app_events') }}
),

user_events_agg as (
    select
        user_id,
        count(*) as total_events,
        count(distinct event_date) as active_days,
        count(distinct event_type) as unique_event_types,
        count(case when event_type = 'login' then 1 end) as login_count,
        count(case when event_type = 'view' then 1 end) as view_count,
        count(case when event_type = 'click' then 1 end) as click_count,
        count(case when event_type = 'feature_use' then 1 end) as feature_use_count,
        min(event_timestamp) as first_event_date,
        max(event_timestamp) as last_event_date,
        datediff('day', min(event_date), max(event_date)) as event_span_days,
        avg(case when event_hour between 9 and 17 then 1 else 0 end) as business_hours_ratio,
        count(distinct event_day_of_week) as active_weekdays
    from events
    group by user_id
)

select * from user_events_agg

