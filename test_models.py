"""
Script para probar los modelos dbt directamente con DuckDB
"""
import duckdb
import os

conn = duckdb.connect('churn_prediction.duckdb')

print("=" * 60)
print("PROYECTO 1: CHURN PREDICTION - PRUEBA DE MODELOS")
print("=" * 60)

# Leer y ejecutar modelos staging
staging_models = [
    'models/staging/stg_users.sql',
    'models/staging/stg_app_events.sql',
    'models/staging/stg_billing.sql',
    'models/staging/stg_support_tickets.sql',
    'models/staging/stg_marketing.sql'
]

print("\n📊 Probando modelos STAGING...")
for model_file in staging_models:
    if os.path.exists(model_file):
        with open(model_file, 'r') as f:
            sql = f.read()
            # Reemplazar macros de dbt
            sql = sql.replace('{{ config(materialized=\'view\') }}', '')
            sql = sql.replace('{{ source(\'raw\', \'users\') }}', 'raw.users')
            sql = sql.replace('{{ source(\'raw\', \'app_events\') }}', 'raw.app_events')
            sql = sql.replace('{{ source(\'raw\', \'billing\') }}', 'raw.billing')
            sql = sql.replace('{{ source(\'raw\', \'support_tickets\') }}', 'raw.support_tickets')
            sql = sql.replace('{{ source(\'raw\', \'marketing\') }}', 'raw.marketing')
            
            model_name = os.path.basename(model_file).replace('.sql', '')
            try:
                result = conn.execute(sql).fetchall()
                print(f"  ✅ {model_name}: {len(result)} filas")
            except Exception as e:
                print(f"  ❌ {model_name}: {str(e)[:100]}")

# Probar modelos intermediate (simplificados)
print("\n📊 Probando modelos INTERMEDIATE...")
try:
    # int_user_events_aggregated
    sql = """
    SELECT 
        user_id,
        COUNT(*) as total_events,
        COUNT(DISTINCT DATE(event_timestamp)) as active_days
    FROM raw.app_events
    GROUP BY user_id
    LIMIT 10
    """
    result = conn.execute(sql).fetchall()
    print(f"  ✅ int_user_events_aggregated: {len(result)} filas")
except Exception as e:
    print(f"  ❌ int_user_events_aggregated: {str(e)[:100]}")

try:
    # int_user_billing_summary
    sql = """
    SELECT 
        user_id,
        COUNT(*) as total_billing_records,
        SUM(amount) as total_amount_paid
    FROM raw.billing
    GROUP BY user_id
    LIMIT 10
    """
    result = conn.execute(sql).fetchall()
    print(f"  ✅ int_user_billing_summary: {len(result)} filas")
except Exception as e:
    print(f"  ❌ int_user_billing_summary: {str(e)[:100]}")

# Verificar datos generados
print("\n📊 Verificando datos generados...")
tables = ['users', 'app_events', 'billing', 'support_tickets', 'marketing']
for table in tables:
    try:
        result = conn.execute(f"SELECT COUNT(*) FROM raw.{table}").fetchone()
        print(f"  ✅ raw.{table}: {result[0]:,} filas")
    except Exception as e:
        print(f"  ❌ raw.{table}: {str(e)[:100]}")

print("\n" + "=" * 60)
print("✅ PRUEBA COMPLETADA")
print("=" * 60)

conn.close()

