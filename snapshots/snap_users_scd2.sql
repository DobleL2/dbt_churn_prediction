{% snapshot snap_users_scd2 %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='check',
      check_cols=['status', 'plan_type', 'churn_date'],
      invalidate_hard_deletes=True,
    )
}}

select 
    user_id,
    email,
    signup_date,
    country,
    plan_type,
    status,
    churn_date,
    is_churned,
    days_to_churn
from {{ ref('stg_users') }}

{% endsnapshot %}

