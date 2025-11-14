# GitHub Actions Workflows

Este proyecto incluye workflows de CI/CD automatizados para garantizar la calidad del código y los datos.

## Workflows Disponibles

### 1. CI (Continuous Integration)
**Archivo:** `.github/workflows/ci.yml`

**Cuándo se ejecuta:**
- Push a ramas `main`, `master`, o `develop`
- Pull requests a estas ramas
- Manualmente (workflow_dispatch)

**Qué hace:**
1. ✅ Instala dependencias Python
2. ✅ Genera datos de prueba
3. ✅ Ejecuta `dbt deps`
4. ✅ Compila modelos dbt
5. ✅ Ejecuta `dbt run` (construye todos los modelos)
6. ✅ Ejecuta `dbt test` (valida tests de calidad)
7. ✅ Ejecuta `dbt snapshot`
8. ✅ Genera documentación dbt
9. ✅ Verifica calidad de datos
10. ✅ Sube artefactos para descarga

### 2. Lint
**Archivo:** `.github/workflows/lint.yml`

**Cuándo se ejecuta:**
- Push a ramas principales
- Pull requests

**Qué hace:**
- ✅ Valida sintaxis SQL
- ✅ Verifica que los modelos dbt sean parseables
- ✅ Detecta errores de sintaxis antes del merge

### 3. Docs
**Archivo:** `.github/workflows/docs.yml`

**Cuándo se ejecuta:**
- Manualmente (workflow_dispatch)
- Diariamente a las 2 AM UTC (schedule)

**Qué hace:**
- ✅ Genera documentación completa de dbt
- ✅ Sube documentación como artefacto
- ✅ Útil para mantener docs actualizadas

## Cómo Usar

### Ver Estado de Workflows
1. Ve a la pestaña "Actions" en GitHub
2. Selecciona el workflow que quieres ver
3. Revisa los logs de ejecución

### Ejecutar Manualmente
1. Ve a "Actions" → Selecciona el workflow
2. Click en "Run workflow"
3. Selecciona la rama y ejecuta

### Descargar Artefactos
1. Ve a la ejecución del workflow
2. Scroll hasta "Artifacts"
3. Descarga los archivos generados

## Badges de Estado

Puedes agregar badges a tu README principal:

```markdown
![CI](https://github.com/tu-usuario/tu-repo/workflows/CI%20-%20Churn%20Prediction/badge.svg)
```

## Troubleshooting

### Workflow falla en `dbt run`
- Verifica que los datos se generaron correctamente
- Revisa los logs para ver qué modelo falló
- Asegúrate de que `profiles.yml` esté configurado

### Workflow falla en `dbt test`
- Revisa qué test específico falló
- Verifica los datos de prueba
- Ajusta los tests si es necesario

### Workflow es lento
- Los workflows pueden tardar 5-10 minutos
- Considera usar `dbt build` en lugar de `dbt run` + `dbt test` separados

