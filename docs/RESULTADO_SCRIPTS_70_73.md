# Resultado del grupo 70–73 — Gobierno y Knowledge Catalog

Proyecto: `lumina-lab-513704`
Región: `us-central1`
Resultado: **COMPLETADO**

| Script | Estado | Resultado |
|---|---:|---|
| 70 | 1 | Permisos, tres datasets, inventario y entradas automáticas verificados |
| 71 | 1 | Dataplex y Data Lineage habilitados; agente Dataplex y rol roles/dataplex.serviceAgent verificados |
| 72 | 1 | Aspect overview aplicado/verificado en 44 activos; metadata previa divergente se preserva |
| 73 | 1 | Linaje BigQuery verificado: 4/4 pares source→vista |

## Catálogo

Preflight previo a habilitar APIs:
project=lumina-lab-513704
project_number=259275898660
region=us-central1
account=winstonflores30@gmail.com
asset_count=44
dataplex_api=enabled
datalineage_api=disabled
Estado posterior del API:
dataplex_api=enabled
datalineage_api=enabled
project=lumina-lab-513704
project_number=259275898660
account=winstonflores30@gmail.com
automatic_lineage=enabled
assets=44
overviews_added=44
aspect=dataplex-types.global.overview

## Linaje

- cu01_riesgo_quiebre_despacho	reporting_riesgo_quiebre	VERIFICADO
- cu02_plan_reposicion	reporting_plan_reposicion	VERIFICADO
- cu03_kpis_operativos	reporting_kpis_operativos	VERIFICADO
- cu04_alertas_mantenimiento	reporting_alertas_mantenimiento	VERIFICADO

## Alcance y costo

- Se catalogaron activos BigQuery Bronze, Silver y Gold existentes; no se creó Lake, bucket, dataset ni tabla de negocio.
- Las descripciones se guardan en el aspecto system overview y los aspectos técnicos/schema existentes se conservan.
- Data Lineage queda habilitado para capturar transformaciones BigQuery futuras.
- La captura automática puede generar cargos variables por procesamiento de linaje; la consulta de vínculos no se cobra por consulta.

No se añadieron roles IAM al usuario ejecutor; se aplicó roles/dataplex.serviceAgent solo al agente de servicio de Dataplex.
Evidencia detallada: `state/demo001/governance_catalog/` y `state/demo001/governance_lineage/`.
