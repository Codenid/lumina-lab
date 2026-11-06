# Control de scripts y arquitectura

Proyecto: `lumina-lab-513704`  
Región: `us-central1`  
Última actualización: 2026-11-06

## Regla de estado

- `1`: script existente, ejecutado y verificado.
- `0`: script ejecutado y fallido.
- `PENDIENTE`: script todavía no creado o no ejecutado.

## Scripts existentes

| Rango | Grupo | Estado |
|---|---|---:|
| 00–05 | Acceso, APIs, Storage, IAM, BigQuery y Pub/Sub | 1 |
| 06–13 | Streaming Dataflow, Bronze/Silver, Gold y evidencia | 1 |
| 14–19 | Fixtures batch, Bronze, Silver, Gold, mart y casos de uso | 1 |
| 20–23 | Workflows, Storage Transfer, batch y Dataproc demo | 1 |
| 24–28 | Transferencia real, Workflow y evidencia batch | 1 |
| 29 | Preflight de permisos batch | 1 |
| 30–35 | Contratos y tres dominios batch adicionales | 1 |
| 36–42 | Forecast baseline, scoring y planificación CU02 | 1 |
| 90 | Eliminación del clúster Dataproc | 1 |

## Siguiente grupo pendiente

El siguiente grupo pendiente es **70–73: Gobierno y catálogo (RS-021)**.
El Operational Mart ya integra las seis fuentes batch y las dos fuentes streaming.

| Scripts propuestos | Objetivo | Estado |
|---|---|---:|
| 43 | Contrato y preflight de permisos del segundo flujo Dataflow | 1 |
| 44 | Tablas Gold de Insights y auditoría | 1 |
| 45 | Crear/verificar el segundo job Dataflow | 1 |
| 46 | Publicar evento válido de Insights | 1 |
| 47 | Verificar Insights, auditoría y deduplicación | 1 |
| 48 | Generar evidencia del flujo en tiempo real | 1 |

## Pendientes posteriores

| Grupo | Scripts propuestos | Arquitectura pendiente | Estado |
|---|---|---|---|
| Orquestación completa | 49–53 | Workflows debe ejecutar Bronze → Silver → Gold → mart, no solo consultar el mart. | 1 |
| Batch productivo | 54–58 | Seis fuentes y transformaciones RS-014 verificadas; automatización recurrente de nuevas llegadas sigue pendiente. | 1 |
| Operational Mart productivo | 59–62 | Integrar continuamente streaming y batch RS-017. | 1 |
| API | 63–67 | Cloud Run READY y privado; cuatro rutas funcionales responden con datos; `/healthz` no es requisito. | 1 |
| Vistas para reporting | 68–69 | Cuatro vistas BigQuery Gold verificadas; aplicación consumidora fuera del alcance actual. | 1 |
| Gobierno | 70–73 | Dataplex/Knowledge Catalog, metadatos y linaje RS-021. | PENDIENTE |
| Seguridad | 74–78 | KMS, DLP, secretos y controles refinados RS-022. | PENDIENTE |
| Auditoría y observabilidad | 79–83 | Audit Store, métricas, alertas y SLOs. | PENDIENTE |

## Grupo 49–53 ejecutado

| Script | Estado | Evidencia |
|---|---:|---|
| 49 | 1 | DCL y ACL verificados en Bronze/Silver/Gold; Job User conservado |
| 50 | 1 | Workflow ACTIVE, revisión `000004-cc2` |
| 51 | 1 | Ejecución `f3c43fad-6107-4258-8a2f-be259a2d4fde` |
| 52 | 1 | Workflow SUCCEEDED; operational_mart=2 |
| 53 | 1 | `state/demo001/EVIDENCIA_WORKFLOW_BATCH.md` |

Los rangos pendientes son planificación; no representan scripts existentes ni
componentes desplegados. Cada grupo debe comenzar con contrato y preflight de
permisos, y cada script debe terminar con un resultado binario `1` o `0`.

## Grupo 54–58 ejecutado

| Script | Estado | Evidencia |
|---|---:|---|
| 54 | 1 | Contrato, identidad, APIs, ACLs y ubicación `us-central1` verificados |
| 55 | 1 | Seis archivos publicados y verificados en Landing |
| 56 | 1 | Una fila por fuente cargada y verificada en Bronze |
| 57 | 1 | Seis dominios curados; Gold CU01–CU03 y mart materializados; segundo intento tras ajustar límite de bytes |
| 58 | 1 | Conteos confirmados en Bronze, Silver, Gold y mart; reporte de evidencia guardado |

ID de lote: `batch-20261105-211629`. La carga recurrente de nuevos archivos
requiere acordar su calendario y conectar los productores batch reales; este
grupo verificó el recorrido con datos sintéticos.

## Grupo 59–62 ejecutado

| Script | Estado | Evidencia |
|---|---:|---|
| 59 | 1 | Contrato, ocho tablas, APIs, ubicación e identidad; permisos de lectura verificados |
| 60 | 1 | Esquema del mart ampliado sin eliminar datos; 14 columnas verificadas |
| 61 | 1 | MERGE de integración y scheduled query cada 6 horas; identidad efectiva verificada |
| 62 | 1 | Transfer Run `SUCCEEDED`; ocho dominios con filas validados en BigQuery |

Scheduled query: `projects/259275898660/locations/us-central1/transferConfigs/6aed73be-0000-2cc2-895e-7474463f96ad`.
Transfer Run: `projects/259275898660/locations/us-central1/transferConfigs/6aed73be-0000-2cc2-895e-7474463f96ad/runs/6af2b841-0000-2a52-874f-c82add6fff8c`.
Informe: `docs/RESULTADO_SCRIPTS_59_62.md`; evidencia del lote: `state/demo001/EVIDENCIA_OPERATIONAL_MART.md`.

## Grupo 63–67 — API RetailSmart Insights

| Script | Estado | Evidencia |
|---|---:|---|
| 63 | 1 | Preflight, APIs, contrato y tablas Gold verificados |
| 64 | 1 | Runtime, acceso por tabla y permisos mínimos de build verificados |
| 65 | 1 | Servicio Cloud Run privado y revisión desplegada verificados |
| 66 | 1 | Cloud Run READY y revisión esperada confirmados; cuatro rutas autenticadas devuelven datos; anónimo HTTP 403 |
| 67 | 1 | Estado final e IAM consultados en GCP; cierre completo documentado |

Servicio: `luminalab-insights-api`, región `us-central1`; revisión
`luminalab-insights-api-r8d18faca07`. `/healthz` no se usa como criterio de
aceptación: el chequeo técnico confirma servicio/revisión READY y la validación
funcional consulta las cuatro rutas de negocio. Evidencia:
`docs/RESULTADO_SCRIPTS_63_67.md`; detalle del intento en
`state/demo001/api_validation_20261106T005130Z/`.

## Grupo 68–69 — Vistas BigQuery de reporting

| Script | Estado | Evidencia |
|---|---:|---|
| 68 | 1 | Contrato, ubicación y cuatro fuentes Gold verificados; preflight no habilita servicios externos |
| 69 | 1 | Cuatro vistas BigQuery creadas y consultadas |

El grupo queda cerrado dentro del alcance acordado: Looker sale de la
implementación y su API está deshabilitada. Las vistas quedan listas para una
aplicación externa opcional futura. Evidencia: `docs/RESULTADO_SCRIPTS_68_69.md`.
El siguiente grupo secuencial pendiente es **70–73 — gobierno y catálogo**.

## Recomendación opcional posterior a todos los grupos

Evaluar una aplicación externa demo que consuma las vistas Gold y muestre riesgo
de quiebre, reposición, KPIs operativos y mantenimiento. No forma parte del
runbook actual. Looker queda solo como recomendación alternativa; no se crearán
scripts Looker ni se aprovisionarán instancias en este recorrido.
