# Resultado de ejecución — scripts 06–19

Fecha: 2026-11-05  
Proyecto: `lumina-lab-513704`  
Región: `us-central1`  
Ejecución: `demo001`

## Resumen

Los scripts 06–19 terminaron correctamente y fueron verificados en GCP. El job de Dataflow utilizado fue único y quedó cancelado antes de finalizar la ejecución. Se verificó el flujo Pub/Sub → Dataflow → Silver, la copia independiente en Bronze, la materialización Gold y los cuatro casos de uso batch.

## Estado por script

| Script | Estado | Evidencia / resultado |
|---|---|---|
| 06 | Ejecutado y verificado | Beam 2.77.0 preparado en el entorno virtual. |
| 07 | Ejecutado y verificado | Job `luminalab-silver-demo001`, ID `2026-11-04_21_25_41-10391633870505275148`, llegó a `RUNNING`; un único worker y autoscaling deshabilitado. |
| 08 | Ejecutado y verificado | Evento `evt-demo001` publicado en `luminalab-eventos-retail`. |
| 09 | Ejecutado y verificado | Bronze: 2 filas; Silver: 1 fila. Se detectó una coincidencia adicional en Bronze para el mismo `event_id`, pendiente de deduplicación funcional. |
| 10 | Ejecutado y verificado | Gold streaming materializado en `eventos_demo001` e `insights_demo001`. |
| 11 | Ejecutado y verificado | Dataflow confirmado en estado terminal `JOB_STATE_CANCELLED`. |
| 12 | Ejecutado y verificado | Estado de jobs, suscripciones y datasets revisado en el proyecto. |
| 13 | Ejecutado y verificado | Evidencia `state/demo001/EVIDENCIA_RS009.md`; Bronze, Silver y Gold contienen datos y Dataflow está cancelado. |
| 14 | Ejecutado y verificado | Fixtures JSONL generados para pedidos, inventario, entregas y telemetría. |
| 15 | Ejecutado y verificado | Cuatro dominios cargados en tablas Bronze BigQuery. |
| 16 | Ejecutado y verificado | Cuatro dominios curados en tablas Silver; segunda ejecución idempotente sin filas adicionales. |
| 17 | Ejecutado y verificado | CU01–CU04 materializados en Gold; evidencia `state/demo001/gold_casos_ok.txt`. |
| 18 | Ejecutado y verificado | `luminalab_gold.operational_mart` creado y poblado; evidencia `state/demo001/mart_ok.txt`. |
| 19 | Ejecutado y verificado | Las cinco tablas verificadas con filas: CU01, CU02, CU03, CU04 y `operational_mart`. |

## Recursos y evidencias

- Dataflow: `luminalab-silver-demo001` quedó `CANCELLED`.
- Bronze y Silver: `state/demo001/bigquery_verificacion.json`.
- Gold streaming: `state/demo001/gold_ok.txt` y `state/demo001/EVIDENCIA_RS009.md`.
- Casos de uso: `state/demo001/casos_uso_verificados.md`.
- Marcadores batch: `state/demo001/silver_batch_ok.txt`, `gold_casos_ok.txt` y `mart_ok.txt`.

## Correcciones aplicadas durante la ejecución

- Ajuste del parámetro `project`/`silver_table` del lanzamiento Dataflow.
- Aumento de los límites de bytes facturables de las consultas batch al límite requerido por BigQuery.
- Uso de columnas explícitas al insertar registros Bronze, conservando la idempotencia.

## Pendientes

- Revisar la deduplicación de la rama Bronze Pub/Sub: se observaron 2 filas para el evento `evt-demo001` mientras Silver produjo 1 fila.
- Los scripts opcionales 20–23 y los scripts de eliminación no fueron ejecutados.
- No se publicaron cambios en GitHub durante esta ejecución.
