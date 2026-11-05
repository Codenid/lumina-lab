# Resultado del grupo 59–62 — Operational Mart

Fecha: 2026-11-05
Proyecto: `lumina-lab-513704`
Región/ubicación BigQuery: `us-central1`
Resultado: **COMPLETADO**

| Script | Resultado | Verificación real |
|---|---:|---|
| 59 — preflight | 1 | Ocho tablas de entrada, APIs, ubicación e identidad verificadas; permisos de lectura existentes |
| 60 — esquema | 1 | Cuatro columnas de trazabilidad agregadas de forma no destructiva; 14 columnas totales verificadas |
| 61 — integración y programación | 1 | MERGE ejecutado; configuración existente validada y reutilizada, frecuencia `every 6 hours` |
| 62 — refresco y validación | 1 | Transfer Run `SUCCEEDED`; conteo positivo en cada una de las ocho fuentes |

## Recursos y salidas

- Operational Mart: `lumina-lab-513704.luminalab_gold.operational_mart`.
- Scheduled query: `projects/259275898660/locations/us-central1/transferConfigs/6aed73be-0000-2cc2-895e-7474463f96ad`.
- Identidad efectiva de ejecución: `259275898660-compute@developer.gserviceaccount.com`.
- Transfer Run: `projects/259275898660/locations/us-central1/transferConfigs/6aed73be-0000-2cc2-895e-7474463f96ad/runs/6af2b841-0000-2a52-874f-c82add6fff8c`.
- Resultado terminal: `SUCCEEDED`.

| Dominio | Entidades verificadas |
|---|---:|
| `pedidos` | 3 |
| `inventario` | 2 |
| `entregas` | 2 |
| `benchmark_competidores` | 2 |
| `eventos_locales` | 2 |
| `redes_sociales` | 2 |
| `insights_streaming` | 2 |
| `procesamiento_auditoria` | 2 |

## Incidencias resueltas durante la ejecución

- El `bq show --transfer_config` local no acepta `--transfer_location`; se retiró esa bandera de los comandos `show`, manteniendo proyecto explícito y nombre completo del recurso.
- La respuesta de la configuración expone la cuenta efectiva bajo `ownerInfo.email`; la verificación ahora acepta ese campo y valida que coincida con la identidad del preflight.
- `bq ls --transfer_run` devuelve una lista JSON directamente y `bq query --format=prettyjson` devuelve una lista de filas. Se ajustó el parser para ambos formatos y se hizo que 62 reutilice el run reciente si falla una validación local, evitando lanzar duplicados.
- Hubo una primera verificación local fallida por formato JSON, corregida antes de cerrar el grupo. No se añadieron permisos IAM ni se creó una segunda configuración de refresco.

## Evidencia y pendientes

- Evidencia detallada del lote: `state/demo001/EVIDENCIA_OPERATIONAL_MART.md`.
- ID del run y estado terminal: `state/demo001/operational_mart_verified.txt`.
- No hay bloqueos pendientes para este grupo. La frecuencia programada quedó activa cada 6 horas.
- Siguiente grupo del runbook: **63–67 — API Cloud Run RetailSmart Insights (RS-018)**. No se ejecutó en este grupo.
