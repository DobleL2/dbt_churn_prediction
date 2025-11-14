"""
Script para generar datos de prueba para el proyecto de Churn Prediction
"""
import pandas as pd
import numpy as np
import duckdb
from datetime import datetime, timedelta
import os

# Configuración
np.random.seed(42)
n_users = 10000
output_db = 'churn_prediction.duckdb'

# Eliminar base de datos existente si existe
if os.path.exists(output_db):
    os.remove(output_db)

# Conectar a DuckDB
conn = duckdb.connect(output_db)

print("Generando datos de usuarios...")
# 1. raw.users
users = pd.DataFrame({
    "user_id": np.arange(1, n_users + 1),
    "email": [f"user{i}@mail.com" for i in range(n_users)],
    "signup_date": pd.to_datetime("2024-01-01") + pd.to_timedelta(np.random.randint(0, 365, n_users), "D"),
    "country": np.random.choice(["US", "UK", "CA", "MX", "BR", "AR", "ES"], n_users),
    "plan_type": np.random.choice(["free", "pro", "premium"], n_users, p=[0.5, 0.3, 0.2]),
    "status": np.random.choice(["active", "deactivated"], n_users, p=[0.85, 0.15])
})

users["churn_date"] = users.apply(
    lambda row: row["signup_date"] + pd.to_timedelta(np.random.randint(30, 300), "D") 
    if row["status"] == "deactivated" else None, 
    axis=1
)

# Convertir churn_date a string para evitar problemas con None
users["churn_date"] = users["churn_date"].astype(str).replace('NaT', None)

conn.execute("CREATE SCHEMA IF NOT EXISTS raw")
conn.execute("""
    CREATE TABLE raw.users (
        user_id INTEGER,
        email VARCHAR,
        signup_date DATE,
        country VARCHAR,
        plan_type VARCHAR,
        status VARCHAR,
        churn_date DATE
    )
""")
conn.execute("INSERT INTO raw.users SELECT * FROM users")

print("Generando eventos de aplicación...")
# 2. raw.app_events
events = []
for user_id in users['user_id']:
    days_active = np.random.randint(20, 180)
    start_date = pd.to_datetime("2024-06-01")
    for d in range(days_active):
        date = start_date + pd.to_timedelta(d, "D")
        num_events = np.random.randint(1, 10)
        for _ in range(num_events):
            events.append([
                len(events) + 1,
                user_id,
                date + pd.to_timedelta(np.random.randint(0, 1440), "m"),
                np.random.choice(["login", "view", "click", "feature_use"])
            ])

events_df = pd.DataFrame(events, columns=["event_id", "user_id", "event_timestamp", "event_type"])

conn.execute("""
    CREATE TABLE raw.app_events (
        event_id INTEGER,
        user_id INTEGER,
        event_timestamp TIMESTAMP,
        event_type VARCHAR
    )
""")
conn.execute("INSERT INTO raw.app_events SELECT * FROM events_df")

print("Generando datos de facturación...")
# 3. raw.billing
billing_records = []
for user_id in users['user_id']:
    user = users[users['user_id'] == user_id].iloc[0]
    if user['plan_type'] != 'free':
        # Generar pagos mensuales desde signup hasta churn o fecha actual
        end_date = pd.to_datetime(user['churn_date']) if pd.notna(user['churn_date']) else pd.to_datetime("2024-12-31")
        current_date = user['signup_date']
        
        plan_prices = {'pro': 29.99, 'premium': 99.99}
        price = plan_prices.get(user['plan_type'], 0)
        
        while current_date <= end_date:
            billing_records.append([
                len(billing_records) + 1,
                user_id,
                current_date,
                price,
                np.random.choice(['success', 'failed', 'pending'], p=[0.9, 0.08, 0.02])
            ])
            current_date = current_date + pd.DateOffset(months=1)

billing_df = pd.DataFrame(billing_records, columns=["billing_id", "user_id", "billing_date", "amount", "status"])

conn.execute("""
    CREATE TABLE raw.billing (
        billing_id INTEGER,
        user_id INTEGER,
        billing_date DATE,
        amount DECIMAL(10,2),
        status VARCHAR
    )
""")
if len(billing_df) > 0:
    conn.execute("INSERT INTO raw.billing SELECT * FROM billing_df")

print("Generando tickets de soporte...")
# 4. raw.support_tickets
support_tickets = []
for user_id in users['user_id'].sample(frac=0.3):  # 30% de usuarios tienen tickets
    num_tickets = np.random.randint(1, 5)
    user = users[users['user_id'] == user_id].iloc[0]
    start_date = user['signup_date']
    end_date = pd.to_datetime(user['churn_date']) if pd.notna(user['churn_date']) else pd.to_datetime("2024-12-31")
    
    for _ in range(num_tickets):
        ticket_date = start_date + pd.to_timedelta(np.random.randint(0, (end_date - start_date).days), "D")
        support_tickets.append([
            len(support_tickets) + 1,
            user_id,
            ticket_date,
            np.random.choice(['technical', 'billing', 'feature_request', 'bug']),
            np.random.choice(['open', 'resolved', 'closed'], p=[0.2, 0.7, 0.1])
        ])

support_df = pd.DataFrame(support_tickets, columns=["ticket_id", "user_id", "created_date", "ticket_type", "status"])

conn.execute("""
    CREATE TABLE raw.support_tickets (
        ticket_id INTEGER,
        user_id INTEGER,
        created_date DATE,
        ticket_type VARCHAR,
        status VARCHAR
    )
""")
if len(support_df) > 0:
    conn.execute("INSERT INTO raw.support_tickets SELECT * FROM support_df")

print("Generando datos de marketing...")
# 5. raw.marketing
marketing_campaigns = []
campaign_types = ['acquisition', 'retention', 'upsell']
for user_id in users['user_id']:
    user = users[users['user_id'] == user_id].iloc[0]
    num_campaigns = np.random.randint(0, 3)
    
    for _ in range(num_campaigns):
        campaign_date = user['signup_date'] + pd.to_timedelta(np.random.randint(0, 180), "D")
        campaign_type = np.random.choice(campaign_types)
        marketing_campaigns.append([
            len(marketing_campaigns) + 1,
            user_id,
            campaign_date,
            campaign_type,
            np.random.choice(['email', 'push', 'sms']),
            np.random.choice([True, False], p=[0.4, 0.6])  # opened/clicked
        ])

marketing_df = pd.DataFrame(marketing_campaigns, columns=["campaign_id", "user_id", "campaign_date", "campaign_type", "channel", "engaged"])

conn.execute("""
    CREATE TABLE raw.marketing (
        campaign_id INTEGER,
        user_id INTEGER,
        campaign_date DATE,
        campaign_type VARCHAR,
        channel VARCHAR,
        engaged BOOLEAN
    )
""")
if len(marketing_df) > 0:
    conn.execute("INSERT INTO raw.marketing SELECT * FROM marketing_df")

print(f"\n✅ Datos generados exitosamente!")
print(f"📊 Resumen:")
print(f"   - Usuarios: {len(users)}")
print(f"   - Eventos: {len(events_df)}")
print(f"   - Facturación: {len(billing_df)}")
print(f"   - Tickets: {len(support_df)}")
print(f"   - Marketing: {len(marketing_df)}")
print(f"\n💾 Base de datos guardada en: {output_db}")

conn.close()

