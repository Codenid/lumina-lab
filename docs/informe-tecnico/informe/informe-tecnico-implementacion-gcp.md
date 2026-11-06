# Informe técnico de implementación GCP

## 1. Propósito y criterio de lectura

Este informe describe la implementación interna de Lumina Retail en Google Cloud: cómo ingresan los datos, cómo se conservan y transforman, qué productos se publican y qué evidencia confirma cada capacidad.

No es una bitácora de despliegue. Cada sección responde cuatro preguntas:

1. Qué capacidad se habilitó.
2. Con qué servicios y configuración mínima.
3. Qué datos o contrato atraviesan la capacidad.
4. Qué captura o consulta demuestra que funciona.

Los productores y consumidores externos se representan como frontera de integración. No forman parte del aprovisionamiento. Looker y una aplicación externa de consumo siguen fuera de alcance.

## 2. Arquitectura de referencia y evidencia

La siguiente imagen es la arquitectura completa de componentes e integración. Los diagramas incrementales se reemplazarán por exportaciones SVG de ArchiMate para cada recorrido; no se usarán ilustraciones sintéticas.

![Arquitectura de referencia](../assets/arquitectura/arquitectura-archimate.svg)

> **Evidencia pendiente — inventario de plataforma**
> Insertar captura en: ../assets/evidencia/01-fundacion/01-inventario-servicios.png
> Debe mostrar proyecto, región y los servicios principales habilitados.

## 3. Convenciones de instalación

Los nombres se generan desde PROJECT_ID, REGION y PREFIX. DEMO_RUN_ID aísla cada recorrido de prueba y sus evidencias locales.

| Convención | Ejemplo lógico | Uso |
|---|---|---|
| Buckets | project-prefix-landing / bronze / artifacts / models | archivos de entrada, raw técnico, staging y artefactos |
| Datasets | prefix_bronze / prefix_silver / prefix_gold | modelo medallón en BigQuery |
| Tópicos | prefix-eventos-retail / prefix-insights-retail | entrada streaming e Insights |
| Identidades | prefix-worker / prefix-api | ejecución Dataflow y Cloud Run |
| Correlación | event_id, batch_id, scenario_id, trace_id | seguimiento end-to-end |

La automatización está en automatizacion/. Las soluciones desplegables están en soluciones/. Los scripts son idempotentes: validan recursos existentes y se detienen ante divergencias de configuración o permisos.

## 4. Fundación de datos: Landing, Bronze, Silver y Gold

### 4.1 Responsabilidad por capa

| Capa | Servicio | Contenido técnico | Resultado esperado |
|---|---|---|---|
| Landing | Cloud Storage | archivos batch recibidos | objeto fuente identificado por URI |
| Bronze | BigQuery | envelope raw, payload JSON y metadatos Pub/Sub; tablas raw batch | trazabilidad y reproceso |
| Silver | BigQuery | entidades tipadas, normalizadas y con estado de calidad | datos listos para reglas de negocio |
| Gold | BigQuery | casos de uso, Operational Mart, predicciones y vistas | productos de consulta |

Bronze y Silver son tablas BigQuery. Cloud Storage se utiliza para Landing, objetos raw técnicos, staging de Dataflow y artefactos de modelo; no sustituye las capas lógicas Bronze y Silver.

### 4.2 Contrato funcional del evento de entrada

El tópico de entrada recibe eventos JSON. No se documenta aquí el payload completo de cada productor; se documenta el envelope que permite procesarlo y correlacionarlo.

| Campo | Finalidad |
|---|---|
| schema_version | versión del contrato |
| simulation_id y scenario_id | aislamiento de simulación y caso de uso |
| producer_id y source_system | procedencia funcional y técnica |
| event_type | regla de enrutamiento, por ejemplo order_created |
| event_id | correlación entre Pub/Sub, Bronze, Silver, Insights y auditoría |
| occurred_at y emitted_at | momento de negocio y publicación |
| trace_id | trazabilidad entre componentes |
| payload | atributos específicos del evento |

Para pedidos, el payload incorpora como mínimo order_id, SKU o product_id, cantidad, tienda y/o almacén. Silver normaliza estos valores en la tabla pedidos.

> **SVG ArchiMate pendiente — recorrido 01: fundación y medallón**
> Archivo: ../assets/arquitectura/flujo-01-fundacion-medallion.svg

> **Evidencia pendiente — buckets técnicos**
> Archivo: ../assets/evidencia/01-fundacion/02-storage-buckets.png
> Debe mostrar Landing, Bronze, Artifacts y Models, su región y acceso uniforme.

> **Evidencia pendiente — datasets y tablas medallón**
> Archivo: ../assets/evidencia/01-fundacion/03-bigquery-medallion.png
> Debe mostrar los tres datasets y, como mínimo, eventos_raw_pubsub, pedidos y un producto Gold.

## 5. Recorrido streaming: evento a Silver y Gold

### 5.1 Diseño de la bifurcación

El tópico prefix-eventos-retail desacopla al productor del procesamiento. Dos suscripciones independientes reciben la misma publicación:

| Rama | Recurso | Propósito | Prueba esperada |
|---|---|---|---|
| Raw | suscripción BigQuery | persiste data, message_id, publish_time y atributos en Bronze | fila Bronze con event_id y message_id |
| Transformación | suscripción pull | entrega el mensaje al pipeline Apache Beam/Dataflow | fila Silver normalizada con la clave de negocio |

El pipeline valida el envelope, conserva la correlación y filtra las entidades aplicables. Para order_created escribe en Silver.pedidos. BigQuery materializa los productos Gold posteriores.

La demostración usa un único worker, autoscaling desactivado y cierre explícito del job. Un estado RUNNING no es prueba completa: la aceptación requiere el mismo event_id en Bronze y la entidad Silver correspondiente.

### 5.2 Secuencia de evidencia

| Hito | Dato a conservar | Dónde se observa |
|---|---|---|
| Publicación | event_id y messageId | salida del publicador o detalle Pub/Sub |
| Raw | event_id, message_id, publish_time | Bronze.eventos_raw_pubsub |
| Curación | order_id, quality_status | Silver.pedidos |
| Producto | scenario_id o clave de negocio | tabla Gold aplicable |
| Cierre | job_id y estado CANCELLED | Dataflow Jobs |

> **SVG ArchiMate pendiente — recorrido 02: streaming de pedidos**
> Archivo: ../assets/arquitectura/flujo-02-streaming-pedidos.svg
> Debe mostrar productor → Pub/Sub → ramas Bronze y Dataflow → Silver → Gold.

> **Evidencia pendiente — Pub/Sub**
> Archivo: ../assets/evidencia/02-streaming/01-pubsub-topico-suscripciones.png
> Debe mostrar el tópico de entrada y las suscripciones Dataflow, Bronze y Bronze BigQuery.

> **Evidencia pendiente — Dataflow**
> Archivo: ../assets/evidencia/02-streaming/02-dataflow-job.png
> Debe mostrar nombre del job, región, worker único y estado terminal del recorrido.

> **Evidencia pendiente — trazabilidad Bronze y Silver**
> Archivo: ../assets/evidencia/02-streaming/03-bq-bronze-silver-evento.png
> Debe mostrar consultas filtradas por un mismo event_id y el order_id correlacionado.

## 6. Recorrido streaming de Insights y auditoría

Un segundo tópico recibe eventos destinados a Insights. Su pipeline Dataflow escribe dos productos Gold de manera independiente:

| Tabla Gold | Clave de correlación | Datos funcionales |
|---|---|---|
| insights_streaming | event_id | tipo de insight, SKU, tienda, score, estado y fecha |
| procesamiento_auditoria | event_id | componente, estado, fecha observada y detalle |

La aceptación exige que el evento de prueba aparezca en ambas tablas. La cancelación correcta del job se reporta por separado y no convierte una validación de datos fallida en éxito.

> **SVG ArchiMate pendiente — recorrido 03: Insights y auditoría**
> Archivo: ../assets/arquitectura/flujo-03-insights-auditoria.svg
> Debe mostrar tópico Insights → Dataflow → dos tablas Gold → API/vistas.

> **Evidencia pendiente — correlación de Insights**
> Archivo: ../assets/evidencia/03-insights/01-bq-insights-auditoria.png
> Debe mostrar las dos tablas filtradas por el event_id de la prueba.

## 7. Recorrido batch: archivo a productos Gold

### 7.1 Entrada y curación

Las fuentes batch ingresan como archivos en Landing. La carga conserva origen, identificador de archivo, URI, número de fila, hash y estado de validez en Bronze. La curación escribe entidades Silver.

| Dominio | Fuente funcional | Bronze | Silver | Clave funcional |
|---|---|---|---|---|
| Pedidos | Sistema de Pedidos | pedidos_raw | pedidos | order_id + order_line_id |
| Inventario | ERP / Inventario | inventario_raw | inventario | snapshot_id |
| Entregas | Aplicación de Almacenes | entregas_raw | entregas | delivery_id |
| Competidores | Benchmark | benchmark_competidores_raw | benchmark_competidores | benchmark_id |
| Eventos locales | Agenda local | eventos_locales_raw | eventos_locales | local_event_id |
| Redes sociales | Plataforma social | redes_sociales_raw | redes_sociales | post_id |

### 7.2 Orquestación y cómputo efímero

Google Workflows coordina la secuencia Bronze → Silver → Gold → Operational Mart. Storage Transfer cubre la transferencia controlada cuando corresponde. Dataproc/Spark es una demostración técnica de cómputo efímero: no es un servicio permanente y su clúster se configura para autoeliminación.

> **SVG ArchiMate pendiente — recorrido 04: ingestión batch y orquestación**
> Archivo: ../assets/arquitectura/flujo-04-batch-orquestacion.svg
> Debe mostrar fuentes → Landing → Storage Transfer/carga → Bronze → Silver → Gold/Mart y el Workflow como control.

> **Evidencia pendiente — Landing y transferencia**
> Archivo: ../assets/evidencia/04-batch/01-landing-transfer.png
> Debe mostrar un objeto batch, el trabajo Storage Transfer y su estado. La creación del trabajo no prueba una transferencia.

> **Evidencia pendiente — Workflow**
> Archivo: ../assets/evidencia/04-batch/02-workflow-execution.png
> Debe mostrar revisión desplegada, cuenta de ejecución, ejecución SUCCEEDED e identificador de ejecución.

> **Evidencia pendiente — resultado batch**
> Archivo: ../assets/evidencia/04-batch/03-bq-batch-mart.png
> Debe mostrar Bronze, Silver, Gold y Operational Mart filtrados por batch_id o scenario_id.

## 8. Forecast y planificación de reposición

El forecast implementado utiliza el baseline moving_average_7d_baseline. No se presenta como modelo productivo final; demuestra el contrato de features, predicción, artefacto y decisión de reposición.

| Elemento | Ubicación | Campos o configuración clave |
|---|---|---|
| Features | Gold.forecast_features | SKU, almacén, fecha, demanda 7/28 días, inventario y reservado |
| Predicciones | Gold.forecast_predictions | fecha, horizonte, cantidad predicha, versión, training_run_id y estado |
| Artefacto | bucket Models | forecast/DEMO_RUN_ID/MODEL_VERSION/model.json |
| Plan | Gold.cu02_plan_reposicion | SKU, almacén, fecha, forecast_qty, recommended_qty y prioridad |

> **SVG ArchiMate pendiente — recorrido 05: forecast y reposición**
> Archivo: ../assets/arquitectura/flujo-05-forecast-reposicion.svg
> Debe mostrar Silver → features → baseline/artefacto → predicciones → CU02.

> **Evidencia pendiente — forecast completo**
> Archivo: ../assets/evidencia/05-forecast/01-features-predicciones-plan.png
> Debe mostrar training_run_id o scenario_id en features, predicciones y plan, más el objeto model.json.

## 9. Productos Gold, API y reporting

### 9.1 Productos de negocio

| Producto Gold | Finalidad | Claves de consulta |
|---|---|---|
| cu01_riesgo_quiebre_despacho | riesgo de quiebre y acción recomendada | scenario_id, SKU, tienda |
| cu02_plan_reposicion | plan de reposición | scenario_id, SKU, almacén, fecha |
| cu03_kpis_operativos | órdenes, unidades, costo y SLA | scenario_id, periodo, canal |
| cu04_alertas_mantenimiento | anomalía y severidad de activos | scenario_id, activo, sensor, almacén |
| operational_mart | integración de dominios batch y streaming | entity_type, entity_id, ingestion_mode, source_domain |

Las vistas de reporting exponen dimensiones y medidas de estos productos. El consumidor BI externo no se aprovisiona.

### 9.2 API privada

Cloud Run publica prefix-insights-api con autenticación IAM, mínimo cero instancias, máximo dos y límite de 100 filas por solicitud. La identidad runtime solo lee las tablas Gold declaradas en el contrato.

| Ruta | Fuente Gold | Uso |
|---|---|---|
| /api/v1/insights | insights_streaming y CU01 | Insights y riesgo de quiebre |
| /api/v1/kpis | CU03 | indicadores operativos |
| /api/v1/inventory-plans | CU02 | reposición |
| /api/v1/maintenance-risks | CU04 | mantenimiento |

> **SVG ArchiMate pendiente — recorrido 06: productos y consumo**
> Archivo: ../assets/arquitectura/flujo-06-gold-api-reporting.svg
> Debe mostrar productos Gold → vistas y Cloud Run → consumidor externo como frontera.

> **Evidencia pendiente — servicio Cloud Run**
> Archivo: ../assets/evidencia/06-consumo/01-cloud-run-servicio.png
> Debe mostrar servicio, región, revisión READY, identidad runtime y autenticación requerida.

> **Evidencia pendiente — respuesta autenticada**
> Archivo: ../assets/evidencia/06-consumo/02-api-rutas.png
> Debe mostrar HTTP 200 de las cuatro rutas de negocio. No usar /healthz como criterio de aceptación.

> **Evidencia pendiente — vistas Gold**
> Archivo: ../assets/evidencia/06-consumo/03-bigquery-vistas.png
> Debe mostrar las cuatro vistas y una consulta con filas.

## 10. Gobierno, seguridad, auditoría y observabilidad

| Control | Implementación | Evidencia funcional |
|---|---|---|
| Gobierno | Dataplex y Data Lineage | activos Bronze/Silver/Gold y vínculos Gold → vistas |
| Acceso | IAM por recurso e identidad | cuentas worker, workflow y API con permisos mínimos |
| Cifrado | KMS regional y secreto CMEK | keyring, clave habilitada y secreto protegido |
| Protección | plantilla DLP regional | tipos EMAIL, PHONE y CARD; sin quotes |
| Auditoría | Logging sink hacia BigQuery Audit Store | evento sintético recibido en Audit Store |
| Operación | métrica, alerta y SLO de API | métrica de errores, política y meta de disponibilidad 99 % |

> **SVG ArchiMate pendiente — recorrido 07: controles transversales**
> Archivo: ../assets/arquitectura/flujo-07-controles-transversales.svg
> Debe rodear los componentes internos con gobierno, seguridad, auditoría y observabilidad; no repetir el flujo de negocio.

> **Evidencia pendiente — gobierno y seguridad**
> Archivo: ../assets/evidencia/07-controles/01-gobierno-seguridad.png
> Debe mostrar Dataplex/Lineage y KMS/Secret Manager sin exponer secretos.

> **Evidencia pendiente — auditoría y operación**
> Archivo: ../assets/evidencia/07-controles/02-auditoria-observabilidad.png
> Debe mostrar sink, Audit Store, métrica, alerta y SLO.

## 11. Operación reproducible

1. Crear o seleccionar proyecto, facturación, red y cuotas compatibles.
2. Copiar config.env.example a config.env y completar proyecto, región, red, prefijo y DEMO_RUN_ID.
3. Ejecutar bash automatizacion/scripts/00_runbook.sh. Este paso valida inventario local; no crea recursos.
4. Ejecutar los grupos en el orden de automatizacion/configuracion/runbook.json.
5. Para cada flujo asíncrono, conservar ID de job o ejecución, correlación de datos y estado terminal.
6. Ejecutar siempre los cierres de Dataflow que correspondan. El script 90 permanece fuera de la secuencia porque elimina cómputo opcional.

Los runbooks de docs/operacion/runbooks/ contienen validación por consola, comandos CLI de solo lectura y verificadores automáticos ya existentes.

## 12. Índice de evidencia que debe acompañar la entrega

| Grupo | ArchiMate SVG | Capturas GCP requeridas |
|---|---|---|
| Fundación | flujo-01-fundacion-medallion.svg | inventario, buckets, BigQuery medallón |
| Streaming | flujo-02-streaming-pedidos.svg | Pub/Sub, Dataflow, correlación Bronze/Silver |
| Insights | flujo-03-insights-auditoria.svg | Insights y auditoría por event_id |
| Batch | flujo-04-batch-orquestacion.svg | Landing/Transfer, Workflow, Mart |
| Forecast | flujo-05-forecast-reposicion.svg | features, predicciones, plan y artefacto |
| Consumo | flujo-06-gold-api-reporting.svg | Cloud Run, rutas API y vistas |
| Controles | flujo-07-controles-transversales.svg | gobierno/seguridad y auditoría/operación |

Cada captura debe mostrar el proyecto correcto, el recurso consultado y una señal de aceptación. No incluir secretos, tokens, correos personales ni payloads sensibles.

## 13. Límites y siguiente evolución

- Conectar productores externos reales bajo contratos, SLA y frecuencia acordados.
- Definir retención, presupuesto, cuotas y alertas de operación productiva.
- Ajustar capacidad y escalamiento antes de usar datos productivos.
- Implementar consumidor externo o BI sobre las vistas Gold.
- Definir un contrato independiente antes de publicar eventos hacia consumidores externos.
