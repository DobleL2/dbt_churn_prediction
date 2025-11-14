{% snapshot snap_users %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='timestamp',
      updated_at='signup_date',
      invalidate_hard_deletes=True,
    )
}}

select * from {{ ref('stg_users') }}

{% endsnapshot %}

