# Capturas reales de GCP

Esta carpeta contiene evidencia operativa, no diagramas ni imágenes simuladas.
Cada captura debe mostrar el proyecto correcto, el servicio, el recurso y la
señal que permite validar la capacidad. Ocultar secretos, tokens, correos
personales, IDs de sesión y payloads sensibles.

| Carpeta y archivo | Evidencia que debe mostrar |
|---|---|
| `01-fundacion/01-inventario-servicios.png` | APIs o inventario base de la plataforma |
| `01-fundacion/02-storage-buckets.png` | buckets Landing, Bronze, Artifacts y Models |
| `01-fundacion/03-bigquery-medallion.png` | datasets y tablas Bronze, Silver y Gold |
| `02-streaming/01-pubsub-topico-suscripciones.png` | tópico y suscripciones de las dos ramas |
| `02-streaming/02-dataflow-job.png` | job, región, worker y estado terminal |
| `02-streaming/03-bq-bronze-silver-evento.png` | misma correlación en Bronze y Silver |
| `03-insights/01-bq-insights-auditoria.png` | mismo `event_id` en Insights y auditoría |
| `04-batch/01-landing-transfer.png` | archivo y transferencia terminada |
| `04-batch/02-workflow-execution.png` | revisión, identidad y ejecución exitosa |
| `04-batch/03-bq-batch-mart.png` | batch trazable de Bronze hasta Mart |
| `05-forecast/01-features-predicciones-plan.png` | features, predicción, plan y artefacto |
| `06-consumo/01-cloud-run-servicio.png` | Cloud Run privado y revisión READY |
| `06-consumo/02-api-rutas.png` | HTTP 200 de las cuatro rutas de negocio |
| `06-consumo/03-bigquery-vistas.png` | vistas Gold y consulta con filas |
| `07-controles/01-gobierno-seguridad.png` | Dataplex/Lineage, KMS y Secret Manager |
| `07-controles/02-auditoria-observabilidad.png` | sink, Audit Store, métrica, alerta y SLO |

La ubicación exacta de cada captura y su criterio de aceptación están en el
informe técnico, secciones 4 a 10.
