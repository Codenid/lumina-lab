# Capturas reales de GCP

Esta carpeta contiene **plantillas SVG grises de evidencia pendiente**, no capturas reales. Cada archivo SVG señala el nombre del PNG que debe obtenerse en GCP. Las plantillas no acreditan despliegue, ejecución ni aceptación. En el levantamiento del 7 de noviembre de 2026, las 16 capturas quedaron BLOQUEADAS: Google Cloud Console respondió “Site Unavailable” y el entorno no dispone de `gcloud` ni `bq`. No se crearon PNG porque no se pudo observar el estado real de GCP. Cuando el acceso esté disponible, guardar cada captura como PNG del mismo nombre base y actualizar el vínculo en el Markdown.
Cada captura PNG definitiva debe mostrar el proyecto correcto, el servicio, el recurso y la
señal que permite validar la capacidad. Ocultar secretos, tokens, correos
personales, IDs de sesión y payloads sensibles.

| ID | Carpeta y archivo | Evidencia que debe mostrar | Estado 07-11-2026 |
|---|---|---|---|
| EV-ARC-01 | `01-fundacion/01-inventario-servicios.png` | APIs o inventario base de la plataforma | BLOQUEADO: consola GCP no disponible |
| EV-DAT-01 | `01-fundacion/02-storage-buckets.png` | buckets Landing, Bronze, Artifacts y Models | BLOQUEADO: consola GCP no disponible |
| EV-DAT-02 | `01-fundacion/03-bigquery-medallion.png` | datasets y tablas Bronze, Silver y Gold | BLOQUEADO: consola GCP no disponible |
| EV-STR-01 | `02-streaming/01-pubsub-topico-suscripciones.png` | tópico y suscripciones de las dos ramas | BLOQUEADO: consola GCP no disponible |
| EV-STR-02 | `02-streaming/02-dataflow-job.png` | job, región, worker y estado terminal | BLOQUEADO: consola GCP no disponible |
| EV-STR-03 | `02-streaming/03-bq-bronze-silver-evento.png` | misma correlación en Bronze y Silver | BLOQUEADO: consola GCP no disponible |
| EV-STR-04 | `03-insights/01-bq-insights-auditoria.png` | mismo `event_id` en Insights y auditoría | BLOQUEADO: consola GCP no disponible |
| EV-BAT-01 | `04-batch/01-landing-transfer.png` | archivo y transferencia terminada | BLOQUEADO: consola GCP no disponible |
| EV-BAT-02 | `04-batch/02-workflow-execution.png` | revisión, identidad y ejecución exitosa | BLOQUEADO: consola GCP no disponible |
| EV-BAT-03 | `04-batch/03-bq-batch-mart.png` | batch trazable de Bronze hasta Mart | BLOQUEADO: consola GCP no disponible |
| EV-GOL-01 | `05-forecast/01-features-predicciones-plan.png` | features, predicción, plan y artefacto | BLOQUEADO: consola GCP no disponible |
| EV-API-01 | `06-consumo/01-cloud-run-servicio.png` | Cloud Run privado y revisión READY | BLOQUEADO: consola GCP no disponible |
| EV-API-02 | `06-consumo/02-api-rutas.png` | HTTP 200 de las cuatro rutas de negocio | BLOQUEADO: consola GCP no disponible |
| EV-GOL-02 | `06-consumo/03-bigquery-vistas.png` | vistas Gold y consulta con filas | BLOQUEADO: consola GCP no disponible |
| EV-SEC-01 | `07-controles/01-gobierno-seguridad.png` | Dataplex/Lineage, KMS y Secret Manager | BLOQUEADO: consola GCP no disponible |
| EV-SEC-02 | `07-controles/02-auditoria-observabilidad.png` | sink, Audit Store, métrica, alerta y SLO | BLOQUEADO: consola GCP no disponible |

La ubicación exacta de cada captura y su criterio de aceptación están en el
informe técnico, secciones 4 a 10.
