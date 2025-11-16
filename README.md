# 🚀 Data Warehouse + Feature Store para Churn Prediction

## 📌 Descripción

Este proyecto construye un **data warehouse analítico completo** utilizando dbt, con el objetivo de generar una tabla final de **features para predecir churn** en una empresa SaaS ficticia.

El enfoque replica el trabajo real de un **ML Engineer** y un **Data Engineer**, donde dbt se usa para construir un **pipeline de features diarias** que alimentan un modelo ML.

## 🏗️ Arquitectura

Este proyecto sigue la **arquitectura Medallion** (Bronze-Silver-Gold) con una capa intermedia:

```
raw (Bronze) → staging (Silver) → intermediate → marts (Gold)
```

- **Bronze (raw)**: Datos fuente originales sin procesar
- **Silver (staging)**: Datos limpios y estandarizados
- **Intermediate**: Transformaciones intermedias y agregaciones
- **Gold (marts)**: Datos finales listos para consumo/ML

## 🎯 Objetivos

- ✅ Construir un pipeline completo usando dbt (raw → staging → intermediate → marts)
- ✅ Implementar materializaciones (`view`, `table`, `incremental`)
- ✅ Crear modelos agregados y enriquecidos
- ✅ Implementar un **snapshot SCD Type 2** para la tabla de usuarios
- ✅ Generar una tabla **ML-ready** con más de 30 features por usuario
- ✅ Incluir tests automatizados y documentación completa
- ✅ CI/CD con GitHub Actions

## 📁 Estructura del Proyecto

```
proyecto_1_churn_prediction/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml          # CI/CD pipeline
│   │   ├── lint.yml        # Linting y validación
│   │   └── docs.yml        # Generación de documentación
│   └── README.md           # Documentación de workflows
├── models/
│   ├── staging/            # Modelos staging (Silver)
│   │   ├── stg_users.sql
│   │   ├── stg_app_events.sql
│   │   ├── stg_billing.sql
│   │   ├── stg_support_tickets.sql
│   │   ├── stg_marketing.sql
│   │   └── schema.yml      # Tests y documentación
│   ├── intermediate/       # Modelos intermedios
│   │   ├── int_user_events_aggregated.sql
│   │   ├── int_user_billing_summary.sql
│   │   ├── int_user_support_metrics.sql
│   │   └── int_user_engagement.sql
│   └── marts/              # Modelos finales (Gold)
│       ├── fct_churn_features.sql
│       └── schema.yml
├── snapshots/              # Snapshots SCD Type 2
│   ├── snap_users.sql
│   └── snap_users_scd2.sql
├── notebooks/              # Notebooks ML opcionales
│   └── churn_prediction_model.ipynb
├── dbt_project.yml         # Configuración del proyecto
├── profiles.yml            # Configuración de conexión
├── requirements.txt        # Dependencias Python
├── generate_data.py        # Script para generar datos
└── README.md               # Este archivo
```

## 🚀 Quick Start

### Prerrequisitos

- Python 3.8+
- dbt-core >= 1.7.0
- dbt-duckdb >= 1.7.0
- DuckDB >= 0.9.0

### Instalación

1. **Clonar el repositorio:**
```bash
git clone https://github.com/DobleL2/dbt_churn_prediction.git
cd dbt_churn_prediction
```

2. **Instalar dependencias:**
```bash
pip install -r requirements.txt
pip install dbt-core dbt-duckdb
```

3. **Generar datos de prueba:**
```bash
python generate_data.py
```

Esto creará una base de datos DuckDB (`churn_prediction.duckdb`) con:
- 10,000 usuarios
- ~5M eventos de aplicación
- ~33K registros de facturación
- ~7.5K tickets de soporte
- ~10K campañas de marketing

4. **Ejecutar el pipeline dbt:**
```bash
# Instalar dependencias de dbt
dbt deps --profiles-dir .

# Compilar modelos
dbt compile --profiles-dir .

# Ejecutar modelos
dbt run --profiles-dir .

# Ejecutar tests
dbt test --profiles-dir .

# Ejecutar snapshots
dbt snapshot --profiles-dir .

# Generar documentación
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

## 📊 Modelos Principales

### Staging (Silver Layer)

| Modelo | Descripción | Filas (ejemplo) |
|--------|-------------|-----------------|
| `stg_users` | Limpieza y estandarización de usuarios | 10,000 |
| `stg_app_events` | Eventos de aplicación normalizados | ~5M |
| `stg_billing` | Historial de pagos limpio | ~33K |
| `stg_support_tickets` | Tickets de soporte estandarizados | ~7.5K |
| `stg_marketing` | Campañas de marketing limpias | ~10K |

### Intermediate

| Modelo | Descripción |
|--------|-------------|
| `int_user_events_aggregated` | Agregaciones de eventos por usuario (total, días activos, tipos, etc.) |
| `int_user_billing_summary` | Resumen de facturación (pagos exitosos, monto total, tasa de éxito) |
| `int_user_support_metrics` | Métricas de soporte (tickets por tipo, tasa de resolución) |
| `int_user_engagement` | Vista consolidada de engagement del usuario |

### Marts (Gold Layer)

| Modelo | Descripción | Features |
|--------|-------------|----------|
| `fct_churn_features` | Tabla final ML-ready con features para churn prediction | **30+ features** |

**Features incluidas:**
- Time-based: días desde signup, meses, trimestre, día de semana
- Event-based: total eventos, días activos, tipos de eventos, ratios
- Billing: pagos totales, éxito, monto, frecuencia
- Support: tickets totales, por tipo, tasa de resolución
- Marketing: campañas recibidas, engagement rate
- Derived: activity rate, login ratio, click ratio
- Flags: plan type, país, indicadores de riesgo

### Snapshots

| Snapshot | Descripción |
|----------|-------------|
| `snap_users` | Snapshot temporal de usuarios |
| `snap_users_scd2` | Snapshot SCD Type 2 con historial de cambios |

## 🧪 Tests

El proyecto incluye tests automatizados para garantizar calidad de datos:

```bash
# Ejecutar todos los tests
dbt test --profiles-dir .

# Ejecutar tests de un modelo específico
dbt test --select stg_users --profiles-dir .

# Ejecutar tests de una fuente
dbt test --select source:raw --profiles-dir .
```

**Tipos de tests incluidos:**
- `unique`: Verifica unicidad de claves
- `not_null`: Verifica que campos requeridos no sean nulos
- `relationships`: Verifica integridad referencial
- `accepted_values`: Valida valores permitidos

## 📚 Documentación

### Generar documentación localmente:
```bash
# Importante: Usar --profiles-dir . para usar el profiles.yml local
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
# Abre http://localhost:8080
```

**Nota:** Si ves el error "Could not find adapter type duckdb!", asegúrate de:
1. Tener el entorno virtual activado
2. Tener `dbt-duckdb` instalado: `pip install dbt-duckdb`
3. Usar `--profiles-dir .` en los comandos

Ver más detalles en [`dbt_docs_instructions.md`](dbt_docs_instructions.md)

### Ver documentación en GitHub Actions:
1. Ve a la pestaña "Actions"
2. Ejecuta el workflow "Generate Docs"
3. Descarga el artefacto "dbt-docs"

## 🤖 Machine Learning

### Notebook ML Opcional

El proyecto incluye un notebook Jupyter para entrenar un modelo de churn:

```bash
# Instalar dependencias adicionales
pip install scikit-learn matplotlib seaborn jupyter

# Ejecutar notebook
jupyter notebook notebooks/churn_prediction_model.ipynb
```

El notebook:
- Carga features desde `fct_churn_features`
- Entrena un RandomForestClassifier
- Evalúa métricas (ROC-AUC, classification report)
- Visualiza importancia de features
- Genera confusion matrix

## 🔄 CI/CD con GitHub Actions

El proyecto incluye workflows automatizados:

### Workflows Disponibles

1. **CI Pipeline** (`.github/workflows/ci.yml`)
   - Se ejecuta en push/PR
   - Genera datos, ejecuta dbt, tests, snapshots
   - Valida calidad de datos

2. **Lint** (`.github/workflows/lint.yml`)
   - Valida sintaxis SQL
   - Verifica parseo de modelos dbt

3. **Docs** (`.github/workflows/docs.yml`)
   - Genera documentación automáticamente
   - Se ejecuta diariamente y manualmente

Ver más detalles en [`.github/README.md`](.github/README.md)

## 📈 Ejemplos de Uso

### Consultar features para un usuario:
```sql
SELECT 
    user_id,
    total_events,
    active_days,
    total_amount_paid,
    is_churned,
    activity_rate
FROM marts.fct_churn_features
WHERE user_id = 123;
```

### Analizar distribución de churn:
```sql
SELECT 
    plan_type,
    COUNT(*) as total_users,
    SUM(CASE WHEN is_churned THEN 1 ELSE 0 END) as churned_users,
    AVG(CASE WHEN is_churned THEN 1.0 ELSE 0.0 END) as churn_rate
FROM marts.fct_churn_features
GROUP BY plan_type;
```

### Ver historial de cambios (snapshot):
```sql
SELECT 
    user_id,
    dbt_valid_from,
    dbt_valid_to,
    status,
    plan_type
FROM snapshots.snap_users_scd2
WHERE user_id = 123
ORDER BY dbt_valid_from;
```

## 🐛 Troubleshooting

### Error: "ModuleNotFoundError: No module named 'duckdb'"
```bash
pip install duckdb
```

### Error: "dbt: command not found"
```bash
pip install dbt-core dbt-duckdb
```

### Error: "Database file not found"
```bash
# Regenerar datos
python generate_data.py
```

### Error en tests
```bash
# Ver detalles del error
dbt test --select <modelo> --verbose

# Ejecutar solo tests de staging
dbt test --select staging
```

## 📊 Métricas del Proyecto

- **Modelos totales**: 14
- **Tests**: 20+
- **Features ML**: 30+
- **Snapshots**: 2
- **Líneas de código SQL**: ~1,500+

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-feature`)
3. Commit tus cambios (`git commit -m 'Agregar nueva feature'`)
4. Push a la rama (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es para fines educativos y de demostración.

## 👤 Autor

**Luis**

---

## 📚 Recursos Adicionales

- [Documentación de dbt](https://docs.getdbt.com/)
- [DuckDB Documentation](https://duckdb.org/docs/)
- [Arquitectura Medallion](https://www.databricks.com/glossary/medallion-architecture)
