# Resultado de ejecución — scripts 54–58

Proyecto: `lumina-lab-513704`  
Región BigQuery: `us-central1`  
Bucket Landing: `gs://lumina-lab-513704-luminalab-landing`  
Lote: `batch-20261105-211629`

| Script | Resultado | Verificación GCP |
|---|---:|---|
| 54 | 1 | Contrato de seis productores, APIs, datasets, ubicación, bucket e IAM verificados. Cuenta activa `winstonflores30@gmail.com`; Workflow SA `259275898660-compute@developer.gserviceaccount.com`. |
| 55 | 1 | Seis objetos JSONL creados en `gs://lumina-lab-513704-luminalab-landing/batch/batch-20261105-211629/`. |
| 56 | 1 | Una fila por fuente confirmada en las seis tablas Bronze. |
| 57 | 1 | Seis dominios Silver y Gold CU01–CU03 más operational mart materializados. |
| 58 | 1 | Reconsulta confirmó 1 fila por fuente Bronze/Silver, 1 por cada Gold CU01–CU03 y 2 en operational mart. |

## Fuentes verificadas

| Fuente | Bronze | Silver |
|---|---:|---:|
| Pedidos | 1 | 1 |
| Inventario | 1 | 1 |
| Aplicación de almacenes / entregas | 1 | 1 |
| Benchmark competidores | 1 | 1 |
| Eventos locales | 1 | 1 |
| Redes sociales | 1 | 1 |

Gold: `cu01_riesgo_quiebre_despacho=1`, `cu02_plan_reposicion=1`,
`cu03_kpis_operativos=1`; `operational_mart=2`.

## Fallos e intentos

El primer intento de 57 falló al materializar CU01. El historial de BigQuery
registró:

```text
Query exceeded limit for bytes billed: 20971520.
31457280 or higher required.
```

Se elevó `maximum_bytes_billed` de 30 MiB a 100 MiB para las consultas del
script y se reintentó una vez. El segundo intento terminó con `SCRIPT 57: 1`.
Los MERGE por claves y la materialización por `batch_id` conservaron la
idempotencia.

No se añadieron permisos IAM: el preflight confirmó los permisos existentes.
Las ubicaciones de Bronze, Silver y Gold son `us-central1`.

## Pendiente

El grupo demuestra el flujo de seis fuentes con fixtures sintéticos. No deja
un calendario recurrente activo ni conecta productores externos para la llegada
automática de nuevos archivos. Esa automatización debe configurarse con el
calendario y el mecanismo de entrega acordados para los productores reales.

Evidencia por lote: `state/demo001/EVIDENCIA_BATCH_PRODUCTIVO.md`.
