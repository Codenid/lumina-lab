# Control de scripts y arquitectura

Proyecto: `lumina-lab-513704`  
Región: `us-central1`  
Última actualización: 2026-11-05

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

## Siguiente grupo recomendado

El siguiente grupo es **RS-010/RS-011: segundo procesamiento streaming e Insights Retail**.
Debe implementarse antes de API, Looker y gobierno porque esos consumidores necesitan
un producto Gold de Insights estable.

| Scripts propuestos | Objetivo | Estado |
|---|---|---:|
| 43 | Contrato y preflight de permisos del segundo flujo Dataflow | 1 |
| 44 | Tablas Gold de Insights y auditoría | 1 |
| 45 | Crear/verificar el segundo job Dataflow | 1 |
| 46 | Publicar evento válido de Insights | 1 |
| 47 | Verificar Insights, auditoría y deduplicación | 1 |
| 48 | Generar evidencia del flujo en tiempo real | 1 |

## Pendientes posteriores

| Grupo | Scripts propuestos | Arquitectura pendiente |
|---|---|---|
| Orquestación completa | 49–53 | Workflows debe ejecutar Bronze → Silver → Gold → mart, no solo consultar el mart. |
| Batch productivo | 54–58 | Seis fuentes y transformaciones RS-014 verificadas; automatización recurrente de nuevas llegadas sigue pendiente. |
| Operational Mart productivo | 59–62 | Integrar continuamente streaming y batch RS-017. |
| API | 63–67 | Servicio Cloud Run RetailSmart Insights RS-018. |
| Reporting | 68–71 | Modelo, conexión y dashboards Looker. |
| Gobierno | 72–75 | Dataplex/Knowledge Catalog, metadatos y linaje RS-021. |
| Seguridad | 76–80 | KMS, DLP, secretos y controles refinados RS-022. |
| Auditoría y observabilidad | 81–85 | Audit Store, métricas, alertas y SLOs. |

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
