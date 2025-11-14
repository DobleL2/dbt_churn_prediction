# Instrucciones para dbt docs con DuckDB

## Problema Común

Si ves el error:
```
Could not find adapter type duckdb!
```

## Solución

### 1. Verificar que dbt-duckdb esté instalado

```bash
# Activar tu entorno virtual
source .venv/bin/activate  # En macOS/Linux
# o
.venv\Scripts\activate  # En Windows

# Verificar instalación
pip list | grep dbt-duckdb

# Si no está instalado:
pip install dbt-duckdb
```

### 2. Verificar que el perfil esté en la ubicación correcta

dbt busca el archivo `profiles.yml` en:
- `~/.dbt/profiles.yml` (ubicación por defecto)
- O usar `--profiles-dir .` para usar el archivo local

### 3. Generar y servir docs correctamente

```bash
# Opción 1: Usar profiles.yml local
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .

# Opción 2: Copiar profiles.yml a ~/.dbt/
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml
dbt docs generate
dbt docs serve
```

### 4. Si el problema persiste

Asegúrate de que el adaptador esté correctamente instalado:

```bash
# Reinstalar dbt-duckdb
pip uninstall dbt-duckdb
pip install dbt-duckdb

# Verificar que dbt puede encontrar el adaptador
dbt debug --profiles-dir .
```

### 5. Verificar versión de dbt-duckdb

```bash
dbt --version
# Debería mostrar: Registered adapter: duckdb=X.X.X
```

## Comando Completo Recomendado

```bash
# Desde el directorio del proyecto
cd proyecto_1_churn_prediction

# Activar entorno virtual
source .venv/bin/activate

# Generar docs
dbt docs generate --profiles-dir .

# Servir docs (se abrirá en http://localhost:8080)
dbt docs serve --profiles-dir .
```

## Nota Importante

El comando `dbt docs serve` necesita acceso al adaptador para generar el linaje dinámicamente. Asegúrate de que:
1. El entorno virtual esté activado
2. dbt-duckdb esté instalado en ese entorno
3. El archivo profiles.yml sea accesible

