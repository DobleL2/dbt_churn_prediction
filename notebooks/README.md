# Notebooks ML - Churn Prediction

## Nota Importante sobre Esquemas en DuckDB

DuckDB crea los esquemas con el prefijo `main_` cuando se especifican esquemas personalizados en dbt. Por lo tanto:

- `marts` → `main_marts`
- `staging` → `main_staging`
- `intermediate` → `main_intermediate`

## Uso del Notebook

1. **Asegúrate de haber ejecutado dbt:**
```bash
dbt run --profiles-dir .
```

2. **Ejecuta el notebook:**
```bash
jupyter notebook notebooks/churn_prediction_model.ipynb
```

3. **Si ves errores de "Table does not exist":**
   - Verifica que hayas ejecutado `dbt run`
   - Verifica el esquema correcto usando:
   ```python
   import duckdb
   conn = duckdb.connect('churn_prediction.duckdb')
   schemas = conn.execute("SELECT schema_name FROM information_schema.schemata").fetchall()
   print(schemas)
   ```

## Alternativa: Usar esquema por defecto

Si prefieres usar el esquema `main` directamente, puedes modificar `dbt_project.yml` para no especificar esquemas personalizados, pero esto no es recomendado para proyectos grandes.

