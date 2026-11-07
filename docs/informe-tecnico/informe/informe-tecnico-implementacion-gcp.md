# Lumina Retail | Informe de implementación y validación de la plataforma de datos

**Cliente:** RetailSmart Global · **Iniciativa:** Lumina Retail · **Entrega:** Implementación técnica P2 · **Plataforma:** Google Cloud

> **Control documental.** Este informe registra la implementación documentada en el repositorio, las verificaciones requeridas y las brechas de evidencia. Una configuración descrita en código no equivale por sí misma a un recurso desplegado ni a una prueba exitosa. Las figuras grises identifican capturas pendientes de reemplazo; **no constituyen evidencias de ejecución**.

**Continuidad con P1:** [Informe de arquitectura presentado](https://github.com/Codenid/lumina-retail-data-platform/blob/main/docs/report/Lumina_Retail_Informe.pdf). Se conserva su definición de negocio: *anticipar la demanda, optimizar el inventario y acelerar la entrega*. Lumina observa, integra, analiza, predice y recomienda; los sistemas operacionales mantienen la ejecución de pedidos, reservas, pagos y despachos.

**Decisión evolucionada:** P1 describía Bronze y Silver en Cloud Storage/Parquet; P2 implementa las capas lógicas **Bronze, Silver y Gold en BigQuery** y mantiene **Cloud Storage para Landing, staging y artefactos**. Esta diferencia es intencional y debe registrarse como evolución arquitectónica, sin atribuir mejoras de rendimiento no medidas.

## Índice

1. [Resumen ejecutivo](#1-resumen-ejecutivo)
2. [Contexto empresarial y objetivos](#2-contexto-empresarial-y-objetivos)
3. [Arquitectura de solución](#3-arquitectura-de-solucion)
4. [Fuentes, contratos y arquitectura de datos](#4-fuentes-contratos-y-arquitectura-de-datos)
5. [Implementación de pipelines streaming](#5-implementacion-de-pipelines-streaming)
6. [Implementación de pipelines batch](#6-implementacion-de-pipelines-batch)
7. [Transformación, calidad e integración](#7-transformacion-calidad-e-integracion)
8. [Modelado analítico y productos Gold](#8-modelado-analitico-y-productos-gold)
9. [Exposición y consumo de datos](#9-exposicion-y-consumo-de-datos)
10. [Seguridad, gobierno y observabilidad](#10-seguridad-gobierno-y-observabilidad)
11. [Validación end-to-end y resultados](#11-validacion-endtoend-y-resultados)
12. [Conclusiones y hoja de evolución](#12-conclusiones-y-hoja-de-evolucion)

**Anexos:** [A. Inventario GCP](#anexo-a-inventario-de-recursos-gcp) · [B. Contratos Pub/Sub](#anexo-b-contratos-pubsub) · [C. Contratos API](#anexo-c-contratos-api) · [D. Diccionario de datos](#anexo-d-diccionario-de-datos) · [E. Metadatos y linaje](#anexo-e-metadatos-y-linaje) · [F. Contratos batch](#anexo-f-contratos-batch) · [G. Productos Gold](#anexo-g-productos-analiticos-gold) · [H. Seguridad y operación](#anexo-h-seguridad-y-operacion) · [I. Pruebas y evidencias](#anexo-i-pruebas-y-evidencias) · [J. Referencias](#anexo-j-referencias-y-artefactos).


---

## 1. Resumen ejecutivo

![Miniportada técnica 1: Microprocesador central conecta tienda, almacén, distribución y analítica.](../assets/miniportadas/01-resumen-ejecutivo.svg)

*Ilustración editorial técnica en blanco y negro. Microprocesador central conecta tienda, almacén, distribución y analítica.*

### Decisión ejecutiva y alcance

RetailSmart Global necesita transformar señales fragmentadas de pedidos, inventario, logística y telemetría en información trazable para decisiones operativas. Lumina Retail implementa una plataforma analítica desacoplada de los sistemas transaccionales. El objetivo de esta entrega es demostrar **pipelines funcionales de transformación, procesamiento híbrido batch/streaming y modelado analítico**, no repetir el diseño conceptual P1.

| Compromiso | Materialización técnica | Criterio de aceptación |
|---|---|---|
| Procesamiento continuo | Pub/Sub → Apache Beam/Dataflow → BigQuery Silver/Gold | Correlación del mismo `event_id` entre entrada, curación y salida |
| Procesamiento por lotes | Landing → BigQuery Bronze/Silver/Gold, orquestado con Workflows | `batch_id` y conteos conciliados en cada etapa |
| Integración de datos | Normalización, reglas de calidad y joins por claves sustentadas | Evidencia SQL y resultado antes/después |
| Analítica | Productos Gold, Operational Mart, vistas | Esquemas, granularidad y consultas reproducibles |

**Límites:** productores empresariales, Looker y aplicaciones consumidoras externas no se aprovisionan como parte de esta implementación. El forecast es un baseline complementario, no una afirmación de precisión productiva. No se presentan beneficios operativos medidos sin línea base ni resultados verificables.

**Estado de aceptación:** condicionado a pruebas y capturas identificadas en el capítulo 11; la disponibilidad de scripts no reemplaza las ejecuciones reales.


---

## 2. Contexto empresarial y objetivos

![Miniportada técnica 2: Servidores aislados que convergen hacia una red común.](../assets/miniportadas/02-contexto-objetivos.svg)

*Ilustración editorial técnica en blanco y negro. Servidores aislados que convergen hacia una red común.*

### Continuidad del diagnóstico P1

La arquitectura responde a cinco problemas documentados: riesgo de quiebre de stock, desalineación geográfica del inventario, saturación operativa, comportamiento fragmentado del cliente y riesgo de fallas de activos. La plataforma habilita cuatro verticales de análisis y recomendación, sin convertirse en sistema transaccional de registro.

| Necesidad | Señal o producto de datos | Dependencia |
|---|---|---|
| Anticipar quiebre | CU01 riesgo de quiebre | pedidos, inventario, SKU, tienda |
| Planificar reposición | CU02 plan de reposición | histórico, stock, predicción |
| Evaluar operación | CU03 KPIs operativos | pedidos, entregas, periodos |
| Priorizar mantenimiento | CU04 alertas de mantenimiento | telemetría y activos |

### Alcance P2

El criterio de evaluación prioriza: (1) código de limpieza, enriquecimiento y cruce de fuentes; (2) transformación streaming y batch ejecutable; (3) estructuras analíticas consolidadas. Las capacidades de gobierno, API y forecast se describen como soporte y evolución, sin competir con la demostración de los tres criterios anteriores.

**Hipótesis de valor:** integrar datos con trazabilidad permite decisiones más oportunas. **Validación requerida:** medir tiempo de disponibilidad del dato, completitud, duplicados y conciliación por escenario. No se equiparan estimaciones de P1 con resultados de P2.


---

## 3. Arquitectura de solución

![Miniportada técnica 3: Centro de datos modular conectado con servicios cloud.](../assets/miniportadas/03-arquitectura-solucion.svg)

*Ilustración editorial técnica en blanco y negro. Centro de datos modular conectado con servicios cloud.*

### Arquitectura de referencia y arquitectura implementada

![Vista ArchiMate completa](../assets/arquitectura/arquitectura-archimate.svg)

La vista anterior es una **referencia de arquitectura**, no una captura de recursos aprovisionados. Los siete recorridos incrementales deben exportarse del modelo ArchiMate; no se sustituirán por imágenes sintéticas.

| Decisión | P1 | P2 | Consecuencia / verificación |
|---|---|---|---|
| Bronze y Silver | Cloud Storage / Parquet | BigQuery | SQL unificado y menor complejidad de acceso; revisar costos de almacenamiento/consulta |
| Landing | Cloud Storage | Cloud Storage | Conservación de archivos de entrada y URI de origen |
| Mensajería | Pub/Sub | Pub/Sub | Suscripciones independientes para raw y procesamiento |
| Streaming | Beam/Dataflow | Beam/Dataflow | Separación de transporte, validación y escritura |
| Batch | Procesamiento por lotes | Workflows + SQL / cómputo opcional | Orquestación explícita; Dataproc efímero si corresponde |
| Exposición | Productos analíticos | BigQuery Gold + Cloud Run privado | Lectura IAM y API sin consumidor externo aprovisionado |

**Principio de operación:** el estado RUNNING de Dataflow no acredita que el evento haya llegado a Silver. De forma equivalente, crear una ejecución de Workflow no demuestra que los datos se hayan materializado. Cada capacidad requiere evidencia de datos y estado terminal.

**Evidencia EV-ARC-01 — Inventario de servicios GCP**

![PENDIENTE: Inventario de servicios GCP](../assets/evidencia/01-fundacion/01-inventario-servicios.svg)

*Archivo: `01-fundacion/01-inventario-servicios.png`. Captura real pendiente. **Debe mostrar:** proyecto, región, recursos reales y estado. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 4. Fuentes, contratos y arquitectura de datos

![Miniportada técnica 4: Sensores, archivos, terminales y bases de datos convergen.](../assets/miniportadas/04-fuentes-contratos.svg)

*Ilustración editorial técnica en blanco y negro. Sensores, archivos, terminales y bases de datos convergen.*

### Fuentes y correspondencia

| Familia | Fuente de referencia P1 | Uso en P2 | Precaución |
|---|---|---|---|
| Comercio | theLook, Olist, UCI | histórico, catálogo, baseline | No unir IDs de datasets públicos sin correspondencia validada |
| Operación | pedidos, inventario, entregas | cargas batch | Diferenciar entidad transaccional y snapshot |
| Entorno | benchmark, eventos locales, redes sociales | enriquecimiento batch | Conservar fuente y vigencia |
| Telemetría | eventos sintéticos controlados | streaming | No confundir simulación con operación real |

### Contrato lógico de evento

`schema_version`, `simulation_id`, `scenario_id`, `producer_id`, `source_system`, `event_type`, `event_id`, `occurred_at`, `emitted_at`, `trace_id` y `payload` conforman el envelope documentado. La validación física de tipo, obligatoriedad y compatibilidad depende del contrato versionado por productor; ver anexo B.

### Medallion físico

| Capa | Servicio P2 | Responsabilidad |
|---|---|---|
| Landing | Cloud Storage | archivos batch, URI y staging |
| Bronze | BigQuery | raw Pub/Sub, JSON, metadata y lotes |
| Silver | BigQuery | entidades tipadas, normalizadas, con calidad |
| Gold | BigQuery | CU01–CU04, predicciones, Mart y vistas |

**Metadatos mínimos:** identificador de evento/lote, origen, tiempos de negocio e ingesta, versión de esquema, estado de calidad y referencia de ejecución. El diccionario físico debe derivarse de DDL y consultas reales, no de ejemplos narrativos.

**Evidencia EV-DAT-01 — Buckets de Landing y artefactos**

![PENDIENTE: Buckets de Landing y artefactos](../assets/evidencia/01-fundacion/02-storage-buckets.svg)

*Archivo: `01-fundacion/02-storage-buckets.png`. Captura real pendiente. **Debe mostrar:** ubicación, nombres y políticas de acceso sin exponer secretos. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-DAT-02 — Datasets Bronze, Silver y Gold**

![PENDIENTE: Datasets Bronze, Silver y Gold](../assets/evidencia/01-fundacion/03-bigquery-medallion.svg)

*Archivo: `01-fundacion/03-bigquery-medallion.png`. Captura real pendiente. **Debe mostrar:** datasets reales, tablas y región. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 5. Implementación de pipelines streaming

![Miniportada técnica 5: Flujo continuo de paquetes por circuitos y procesadores.](../assets/miniportadas/05-streaming.svg)

*Ilustración editorial técnica en blanco y negro. Flujo continuo de paquetes por circuitos y procesadores.*

### Bifurcación del tópico de entrada

La publicación se entrega a dos suscripciones independientes: una persiste el raw hacia BigQuery Bronze y otra alimenta el procesamiento Apache Beam/Dataflow hacia Silver. El consumidor debe preservar `event_id`, `message_id`, `publish_time` y los atributos pertinentes. La transformación de `order_created` produce la entidad Silver de pedidos cuando satisface las reglas.

| Etapa | Entrada | Operación | Salida / control |
|---|---|---|---|
| Publicación | JSON de evento | Validación contractual de origen | `event_id` y `messageId` |
| Raw | Suscripción BigQuery | Persistencia del mensaje | `Bronze.eventos_raw_pubsub` |
| Curación | Suscripción Dataflow | Parseo, validación, tipado, filtro | `Silver.pedidos` |
| Negocio | Silver | Reglas y materialización | Productos Gold pertinentes |
| Cierre | Dataflow job | Cancelación explícita | `job_id`, estado terminal |

**Prueba funcional mínima:** publicar un evento único; consultar Bronze y Silver filtrando por el mismo `event_id`; verificar `order_id`, calidad y campos normalizados; conservar el ID del job y su cierre. Los duplicados y eventos tardíos requieren criterios explícitos de idempotencia y vigencia.

### Insights y auditoría

El segundo tópico y su Dataflow producen `Gold.insights_streaming` y `Gold.procesamiento_auditoria`. Se exige la misma correlación en ambas. Si no se observa `EVENTO_RECIBIDO` o `INSIGHT_GENERADO`, registrar el caso como no verificado, aunque el job esté RUNNING.

**Evidencia EV-STR-01 — Tópico y suscripciones**

![PENDIENTE: Tópico y suscripciones](../assets/evidencia/02-streaming/01-pubsub-topico-suscripciones.svg)

*Archivo: `02-streaming/01-pubsub-topico-suscripciones.png`. Captura real pendiente. **Debe mostrar:** nombre del tópico y ramas independientes de raw y Dataflow. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-STR-02 — Ejecución Dataflow**

![PENDIENTE: Ejecución Dataflow](../assets/evidencia/02-streaming/02-dataflow-job.svg)

*Archivo: `02-streaming/02-dataflow-job.png`. Captura real pendiente. **Debe mostrar:** job, región, worker y estado terminal. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-STR-03 — Evento correlacionado Bronze/Silver**

![PENDIENTE: Evento correlacionado Bronze/Silver](../assets/evidencia/02-streaming/03-bq-bronze-silver-evento.svg)

*Archivo: `02-streaming/03-bq-bronze-silver-evento.png`. Captura real pendiente. **Debe mostrar:** mismo event_id y order_id en las consultas. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-STR-04 — Insights y auditoría**

![PENDIENTE: Insights y auditoría](../assets/evidencia/03-insights/01-bq-insights-auditoria.svg)

*Archivo: `03-insights/01-bq-insights-auditoria.png`. Captura real pendiente. **Debe mostrar:** mismo event_id en ambas tablas Gold. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 6. Implementación de pipelines batch

![Miniportada técnica 6: Racks de cómputo procesan grandes lotes en paralelo.](../assets/miniportadas/06-batch.svg)

*Ilustración editorial técnica en blanco y negro. Racks de cómputo procesan grandes lotes en paralelo.*

### Recorrido de procesamiento por lotes

Los archivos ingresan a Cloud Storage Landing. Bronze conserva procedencia, `batch_id`, URI, fila y controles de validez; Silver normaliza entidades; Gold publica agregaciones y Operational Mart. Workflows coordina dependencias y estados; no reemplaza por sí mismo el procesamiento SQL o Spark.

| Dominio | Tabla Bronze | Tabla Silver | Clave de negocio declarada |
|---|---|---|---|
| Pedidos | pedidos_raw | pedidos | order_id + order_line_id |
| Inventario | inventario_raw | inventario | snapshot_id |
| Entregas | entregas_raw | entregas | delivery_id |
| Competidores | benchmark_competidores_raw | benchmark_competidores | benchmark_id |
| Eventos locales | eventos_locales_raw | eventos_locales | local_event_id |
| Redes sociales | redes_sociales_raw | redes_sociales | post_id |

### Control de lote

1. Identificar archivo, fecha de extracción, `batch_id`, hash y volumen.
2. Cargar Bronze conservando registro fuente y metadatos.
3. Aplicar normalización, control de claves y rechazos a Silver.
4. Publicar Gold solo con reglas de completitud y granularidad verificadas.
5. Conciliar conteos, nulos y duplicados; registrar estado de Workflow.

**Cómputo opcional:** Storage Transfer se evidencia solo cuando la transferencia termina; Dataproc/Spark es demostración de cómputo efímero con autoeliminación y no debe describirse como clúster permanente.

**Evidencia EV-BAT-01 — Landing y transferencia**

![PENDIENTE: Landing y transferencia](../assets/evidencia/04-batch/01-landing-transfer.svg)

*Archivo: `04-batch/01-landing-transfer.png`. Captura real pendiente. **Debe mostrar:** objeto fuente, trabajo y transferencia completada. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-BAT-02 — Ejecución Workflows**

![PENDIENTE: Ejecución Workflows](../assets/evidencia/04-batch/02-workflow-execution.svg)

*Archivo: `04-batch/02-workflow-execution.png`. Captura real pendiente. **Debe mostrar:** revisión, cuenta y ejecución SUCCEEDED. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-BAT-03 — Recorrido batch a Mart**

![PENDIENTE: Recorrido batch a Mart](../assets/evidencia/04-batch/03-bq-batch-mart.svg)

*Archivo: `04-batch/03-bq-batch-mart.png`. Captura real pendiente. **Debe mostrar:** mismo batch_id en Bronze, Silver, Gold y Mart. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 7. Transformación, calidad e integración

![Miniportada técnica 7: Filtros, validadores y engranajes depuran datos.](../assets/miniportadas/07-transformacion-calidad.svg)

*Ilustración editorial técnica en blanco y negro. Filtros, validadores y engranajes depuran datos.*

### Reglas de transformación verificables

| Regla | Ejemplo de entrada | Salida esperada | Comprobación |
|---|---|---|---|
| Tipado | cantidad como texto | cantidad numérica o rechazo | tipo físico y error |
| Normalización | identificador con espacios | clave canónica | comparación origen/destino |
| Integridad | pedido sin identificador | registro rechazado o marcado | conteo por calidad |
| Duplicidad | mismo event_id repetido | efecto controlado | consulta por event_id |
| Temporalidad | evento tardío | vigencia registrada | occurred_at vs emitted_at |
| Enriquecimiento | SKU y ubicación válidos | atributos asociados | join sustentado |
| Agregación | múltiples líneas por pedido | métrica a grano declarado | conciliación de importes |

Estas reglas son **criterios de documentación y validación**, no afirmaciones de que cada una ya se ejecutó en el código. La matriz final debe señalar función/SQL real, archivo, prueba y resultado. Un ejemplo no sustituye la evidencia de una transformación implementada.

### Cruce de fuentes heterogéneas

No se debe unir Olist, UCI y theLook por coincidencia casual de IDs. Las correspondencias entre SKU, producto, tienda y tiempo necesitan un mapa de equivalencias versionado o permanecer como dominios separados. Antes de unir ventas con múltiples eventos se agrega al grano compatible para evitar multiplicación de unidades e importes.

### Indicadores de calidad

| Métrica | Fórmula | Interpretación |
|---|---|---|
| Completitud | campos obligatorios presentes / filas recibidas | calidad de origen |
| Duplicidad | claves repetidas / filas recibidas | idempotencia y control |
| Rechazos | filas inválidas / filas recibidas | incumplimiento contractual |
| Conciliación | filas aceptadas + rechazadas vs recibidas | integridad del lote |
| Oportunidad | tiempo de disponibilidad - occurred_at | latencia real |

**Prueba P2:** registrar para al menos un evento y un lote las entradas, reglas, salidas y consultas antes/después, junto con el identificador de ejecución. No declarar porcentajes sin datos medidos.


---

## 8. Modelado analítico y productos Gold

![Miniportada técnica 8: Base de datos central con relaciones y gráficos analíticos.](../assets/miniportadas/08-modelado-gold.svg)

*Ilustración editorial técnica en blanco y negro. Base de datos central con relaciones y gráficos analíticos.*

### Modelo analítico y granularidad

| Producto Gold | Grano de consulta propuesto/documentado | Uso |
|---|---|---|
| cu01_riesgo_quiebre_despacho | escenario, SKU y tienda | riesgo y recomendación |
| cu02_plan_reposicion | escenario, SKU, almacén y fecha | planificación |
| cu03_kpis_operativos | escenario, periodo y canal | operación y SLA |
| cu04_alertas_mantenimiento | escenario, activo, sensor y almacén | mantenimiento |
| operational_mart | entity_type, entity_id, ingestion_mode, source_domain | integración transversal |

**Modelo dimensional:** identificar hechos, dimensiones, claves y relaciones físicas solo cuando el DDL y las consultas lo demuestren. El nombre Gold no implica automáticamente un esquema estrella. Se documentará el grano real de cada tabla, particiones, clustering, campos de medida y política de actualización.

### Forecast como capacidad complementaria

`moving_average_7d_baseline` demuestra la cadena `forecast_features` → `forecast_predictions` → `cu02_plan_reposicion`; el artefacto se conserva en el bucket Models bajo `forecast/DEMO_RUN_ID/MODEL_VERSION/model.json`. No se presenta como modelo predictivo final ni se infiere calidad sin evaluación.

### Vistas de reporting

Las vistas deben explicitar columnas, filtros, fuentes Gold y vigencia. El consumidor externo BI permanece fuera del alcance de aprovisionamiento.

**Evidencia EV-GOL-01 — Forecast, predicción y reposición**

![PENDIENTE: Forecast, predicción y reposición](../assets/evidencia/05-forecast/01-features-predicciones-plan.svg)

*Archivo: `05-forecast/01-features-predicciones-plan.png`. Captura real pendiente. **Debe mostrar:** identificador de corrida en features, predicción, plan y artefacto. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-GOL-02 — Vistas analíticas Gold**

![PENDIENTE: Vistas analíticas Gold](../assets/evidencia/06-consumo/03-bigquery-vistas.svg)

*Archivo: `06-consumo/03-bigquery-vistas.png`. Captura real pendiente. **Debe mostrar:** vistas y consultas con resultados. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 9. Exposición y consumo de datos

![Miniportada técnica 9: Gateway API conecta servicios, terminales y paneles.](../assets/miniportadas/09-consumo-api.svg)

*Ilustración editorial técnica en blanco y negro. Gateway API conecta servicios, terminales y paneles.*

### Contratos de consumo

Cloud Run expone una API privada con autenticación IAM, mínimo cero instancias, máximo dos y límite documentado de 100 filas por solicitud. Los consumidores externos no forman parte del despliegue. Una respuesta de `/healthz` no demuestra la funcionalidad de las rutas de negocio.

| Endpoint | Fuente | Función | Aceptación |
|---|---|---|---|
| `/api/v1/insights` | insights_streaming / CU01 | señales y riesgo | HTTP 200 autenticado y esquema válido |
| `/api/v1/kpis` | CU03 | indicadores | datos Gold consultables |
| `/api/v1/inventory-plans` | CU02 | reposición | respuesta y filtros válidos |
| `/api/v1/maintenance-risks` | CU04 | mantenimiento | respuesta y filtros válidos |

El anexo C documenta cada contrato de forma resumida y exige verificar métodos, parámetros, tipos, estados y estructura exacta en el código fuente antes de declararlos definitivos.

**Evidencia EV-API-01 — Servicio Cloud Run privado**

![PENDIENTE: Servicio Cloud Run privado](../assets/evidencia/06-consumo/01-cloud-run-servicio.svg)

*Archivo: `06-consumo/01-cloud-run-servicio.png`. Captura real pendiente. **Debe mostrar:** revisión READY, región, identidad y autenticación. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-API-02 — Respuestas de negocio**

![PENDIENTE: Respuestas de negocio](../assets/evidencia/06-consumo/02-api-rutas.svg)

*Archivo: `06-consumo/02-api-rutas.png`. Captura real pendiente. **Debe mostrar:** HTTP 200 autenticado de las cuatro rutas. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 10. Seguridad, gobierno y observabilidad

![Miniportada técnica 10: Núcleo de datos protegido con escudo, sensores y monitores.](../assets/miniportadas/10-seguridad-observabilidad.svg)

*Ilustración editorial técnica en blanco y negro. Núcleo de datos protegido con escudo, sensores y monitores.*

### Controles transversales

| Dominio | Componentes previstos/documentados | Evidencia que acredita |
|---|---|---|
| Gobierno | Dataplex y Data Lineage | activos y relaciones entre fuentes y vistas |
| Identidades | IAM por servicio | permisos mínimos worker, workflow y API |
| Cifrado | KMS y Secret Manager | claves, secreto protegido y referencias sin revelar valores |
| Protección | plantilla DLP regional | configuración de detectores EMAIL, PHONE, CARD |
| Auditoría | Logging sink y BigQuery Audit Store | registro de prueba consultable |
| Observabilidad | Monitoring, alertas y SLO | métrica, política, objetivo y estado |

**Precaución:** configuración de política, métrica o sink no acredita por sí sola que un evento de auditoría haya llegado. La evidencia debe mostrar el recorrido y el resultado. El objetivo de disponibilidad 99 % es un objetivo de diseño, no una medición de servicio.

**Evidencia EV-SEC-01 — Gobierno y cifrado**

![PENDIENTE: Gobierno y cifrado](../assets/evidencia/07-controles/01-gobierno-seguridad.svg)

*Archivo: `07-controles/01-gobierno-seguridad.png`. Captura real pendiente. **Debe mostrar:** Dataplex/Lineage, KMS y Secret Manager sin secretos. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*

**Evidencia EV-SEC-02 — Auditoría y monitoreo**

![PENDIENTE: Auditoría y monitoreo](../assets/evidencia/07-controles/02-auditoria-observabilidad.svg)

*Archivo: `07-controles/02-auditoria-observabilidad.png`. Captura real pendiente. **Debe mostrar:** sink, Audit Store, métrica, alerta y SLO. **Lectura:** esta figura se reemplazará por la captura del recurso real, sin modificar el nombre del archivo; hasta entonces no acredita funcionamiento.*



---

## 11. Validación end-to-end y resultados

![Miniportada técnica 11: Circuito de pruebas con instrumentos y verificaciones.](../assets/miniportadas/11-validacion-e2e.svg)

*Ilustración editorial técnica en blanco y negro. Circuito de pruebas con instrumentos y verificaciones.*

### Matriz de aceptación P2

| Prueba | Entrada | Validación | Evidencia | Estado documental |
|---|---|---|---|---|
| P2-STR-01 | order_created | mismo event_id Bronze/Silver | EV-STR-03 | Pendiente de captura verificada |
| P2-STR-02 | evento Insight | mismo event_id en dos Gold | EV-STR-04 | Pendiente de captura verificada |
| P2-BAT-01 | archivo batch | Bronze → Silver → Gold/Mart | EV-BAT-03 | Pendiente de captura verificada |
| P2-TRF-01 | datos con defectos | tipado, rechazo y deduplicación | SQL y resultado antes/después | Pendiente de vincular prueba real |
| P2-INT-01 | fuentes heterogéneas | joins por clave sustentada | SQL y resultado integrado | Pendiente de vincular prueba real |
| P2-MOD-01 | producto Gold | grano, medidas y consulta | EV-GOL-02 | Pendiente de captura verificada |
| P2-API-01 | llamada autenticada | HTTP 200 y respuesta válida | EV-API-02 | Pendiente de captura verificada |

**Estados permitidos:** diseñado, codificado, desplegado, ejecutado, verificado, bloqueado y no verificado. No confundir `RUNNING` con `VERIFICADO`; conservar `DEMO_RUN_ID`, `event_id`, `batch_id`, `job_id`, fecha y región en cada acta.

### Procedimiento reproducible

1. Preparar `config.env` desde `config.env.example`, sin versionar secretos.
2. Ejecutar `bash automatizacion/scripts/00_runbook.sh` para validar inventario local; **no crea recursos**.
3. Ejecutar grupos conforme a `automatizacion/configuracion/runbook.json`.
4. Registrar IDs de recursos, ejecuciones, consultas, conteos y errores.
5. Cancelar los jobs Dataflow de demostración y verificar estado terminal.
6. No ejecutar el script 90 de eliminación como parte del recorrido estándar.

Las figuras SVG grises señalan el archivo PNG real esperado y son **placeholders**, no pruebas. Antes de entrega formal al cliente, sustituirlas y actualizar la matriz con el resultado observado.


---

## 12. Conclusiones y hoja de evolución

![Miniportada técnica 12: Infraestructura modular preparada para ampliarse.](../assets/miniportadas/12-evolucion.svg)

*Ilustración editorial técnica en blanco y negro. Infraestructura modular preparada para ampliarse.*

### Resultado documental y límites

La arquitectura P2 concreta la evolución del diseño P1 hacia un procesamiento híbrido sobre BigQuery Medallion, con componentes para ingesta, curación, productos Gold, API y controles. La demostración de éxito debe apoyarse en consultas y pruebas de datos, no en el inventario de servicios.

**Decisiones pendientes de operación productiva:** cuotas, costos, retención, escalamiento, SLAs, gobernanza de contratos, monitoreo de calidad, consumidores externos y dimensionamiento. No se extrapolan resultados de una demo con un worker a campañas masivas.

### Próxima evolución recomendada

Priorizar (1) cerrar trazabilidad streaming y batch con evidencias; (2) consolidar diccionarios físicos y contratos versionados; (3) automatizar pruebas de calidad y conciliación; (4) medir latencia/costo bajo escenarios controlados; (5) incorporar consumidores externos con contratos independientes. La comparación P1/P2 quedará documentada en el registro de decisiones arquitectónicas.

---

## Anexo A. Inventario de recursos GCP

**Regla:** inventariar recursos realmente aprovisionados con nombre físico, proyecto, región, estado, identidad, contrato y evidencia. Las categorías siguientes proceden del diseño/documentación; su existencia en GCP debe comprobarse con inventario de solo lectura.

| Servicio | Recurso/función documentada | Contrato o metadatos | Evidencia |
|---|---|---|---|
| Cloud Storage | Landing, raw técnico, staging, artifacts, models | bucket, región, URI, lifecycle | EV-DAT-01 |
| BigQuery | datasets Bronze, Silver, Gold; Audit Store | DDL, particiones, labels, tablas | EV-DAT-02 |
| Pub/Sub | eventos-retail, insights-retail y suscripciones | esquema, atributos, ack, delivery | EV-STR-01 |
| Dataflow | pipeline Silver y pipeline Insights | job, worker, región, logs | EV-STR-02 |
| Workflows | orquestación batch | definición, revisión, ejecución | EV-BAT-02 |
| Storage Transfer | transferencia de lotes | job, fuente, destino, estado | EV-BAT-01 |
| Dataproc | cómputo Spark efímero, cuando se ejecute | job, cluster, autoeliminación | acta de ejecución |
| Cloud Run | API privada | revisión, IAM, endpoints | EV-API-01 |
| Dataplex / Lineage | catálogo y linaje | activos, vínculos | EV-SEC-01 |
| IAM | service accounts y roles | miembros y bindings | EV-SEC-01 |
| KMS / Secret Manager | cifrado y secreto | clave, versión, política | EV-SEC-01 |
| Sensitive Data Protection (DLP) | plantilla de inspección | tipos y región | EV-SEC-01 |
| Logging / Monitoring | sink, métrica, alerta, SLO | filtros, destino, objetivo | EV-SEC-02 |

## Anexo B. Contratos Pub/Sub

| Tópico / mensaje | Productor / consumidor | Identificadores | Validación requerida |
|---|---|---|---|
| eventos-retail | productor de eventos → Bronze y Dataflow | event_id, schema_version, trace_id | envelope, tipo, tiempos, payload, compatibilidad |
| insights-retail | emisor de Insights → Dataflow Gold | event_id, scenario_id | formato, deduplicación, destinos Gold |

**Envelope común documentado:** `schema_version`, `simulation_id`, `scenario_id`, `producer_id`, `source_system`, `event_type`, `event_id`, `occurred_at`, `emitted_at`, `trace_id`, `payload`. El payload es **polimórfico**: cada `event_type` necesita su contrato propio. No inferir atributos obligatorios sin verificar la implementación.

**Ficha por contrato:** nombre y versión, productor, consumidores, tópico/suscripción, esquema físico, campos obligatorios, ejemplos sintéticos, reglas de calidad, tratamiento de error, reintento, idempotencia y retención configurada. La suscripción BigQuery raw y la suscripción pull de Dataflow se documentan separadamente.

## Anexo C. Contratos API

| Ruta | Método | Autenticación | Fuente | Respuesta y errores |
|---|---|---|---|---|
| `/api/v1/insights` | verificar en código | IAM privada | insights_streaming/CU01 | JSON y errores: verificar implementación |
| `/api/v1/kpis` | verificar en código | IAM privada | CU03 | JSON y errores: verificar implementación |
| `/api/v1/inventory-plans` | verificar en código | IAM privada | CU02 | JSON y errores: verificar implementación |
| `/api/v1/maintenance-risks` | verificar en código | IAM privada | CU04 | JSON y errores: verificar implementación |

**Campos contractuales a extraer del código:** verbo HTTP, parámetros de consulta y sus tipos, valores por defecto, filtros, límite máximo de 100 filas documentado, paginación si existe, forma exacta del JSON, códigos de error y roles de invocación. **No se inventan** respuestas de ejemplo ni códigos no verificados.

## Anexo D. Diccionario de datos

**Ficha obligatoria por cada tabla física:** dataset, nombre, descripción, grano, origen, clave natural/técnica, partición, clustering, retención, propietario, fecha de actualización y DDL versionado. Cada columna deberá incluir **nombre, tipo BigQuery, modo NULLABLE/REQUIRED/REPEATED, descripción, transformación, fuente, sensibilidad y regla de calidad**. La tabla siguiente es un índice de dominios, no sustituye el diccionario completo.

| Dataset lógico | Tablas / familias identificadas | Grano y clave a contrastar |
|---|---|---|
| Bronze | eventos_raw_pubsub, pedidos_raw, inventario_raw, entregas_raw, benchmark_competidores_raw, eventos_locales_raw, redes_sociales_raw | mensaje/archivo/fila; claves raw |
| Silver | pedidos, inventario, entregas, benchmark_competidores, eventos_locales, redes_sociales | order_id + order_line_id; snapshot_id; delivery_id; otras claves del capítulo 6 |
| Gold | insights_streaming, procesamiento_auditoria, cu01_riesgo_quiebre_despacho, cu02_plan_reposicion, cu03_kpis_operativos, cu04_alertas_mantenimiento | evento o grano de negocio declarado |
| Gold | operational_mart, forecast_features, forecast_predictions, vistas de reporting | entidad, escenario, periodo y versión |

**No conformidad abierta:** para documentar *todos* los campos físicos sin omisiones es imprescindible extraer el esquema efectivo/DDL de cada tabla del repositorio o de `INFORMATION_SCHEMA.COLUMNS`. No se completan tipos, nulabilidad o particiones mediante suposiciones.

## Anexo E. Metadatos y linaje

| Metadato | Nivel | Propósito |
|---|---|---|
| event_id, trace_id, message_id | evento | correlación Pub/Sub → Bronze → Silver → Gold |
| occurred_at, emitted_at, publish_time | evento | oportunidad y orden temporal |
| batch_id, source_uri, source_row_number, hash | lote/fila | reproceso y conciliación |
| scenario_id, simulation_id, DEMO_RUN_ID | prueba | aislar recorridos |
| job_id, execution_id, training_run_id | cómputo | auditoría de ejecución |
| schema_version, model_version | contrato/modelo | compatibilidad y reproducibilidad |
| quality_status | registro | aceptación o rechazo |

Registrar linaje **fuente → tópico/archivo → Bronze → transformación → Silver → Gold → vista/API**. Donde Dataplex/Lineage no ofrezca vínculo físico, mantener linaje documentado como tal y no simular una captura automática.

## Anexo F. Contratos batch

| Dominio | Contrato mínimo | Clave de conciliación |
|---|---|---|
| pedidos | formato, columnas, fecha de extracción, cantidades y moneda | order_id + order_line_id |
| inventario | SKU, ubicación, snapshot y cantidades | snapshot_id |
| entregas | entrega, estado, fechas y ubicación | delivery_id |
| benchmark_competidores | fuente, producto, precio, fecha y moneda | benchmark_id |
| eventos_locales | evento, ubicación, fecha y categoría | local_event_id |
| redes_sociales | publicación, fuente, fecha y señal | post_id |

La obligatoriedad, los tipos y los formatos se tomarán del parser/DDL real; las columnas descritas son **familias semánticas**, no un esquema físico confirmado. Adjuntar URI de ejemplo sintético, política de errores y frecuencia por fuente cuando estén definidas.

## Anexo G. Productos analíticos Gold

| Producto | Consumidor | Validación |
|---|---|---|
| CU01 riesgo de quiebre | Insights/API | correlación escenario, SKU y tienda |
| CU02 reposición | API/planificación | escenario, SKU, almacén, fecha y versión |
| CU03 KPIs | API/reporting | periodo, canal y métricas reconciliadas |
| CU04 mantenimiento | API/operación | activo, sensor, severidad y tiempo |
| Operational Mart | consultas transversales | fuente, modo de ingesta y entidad |
| Forecast features/predictions | CU02 | versión, horizonte, training_run_id |

Cada producto requiere DDL, grano, claves, medidas, consulta SQL, periodicidad, reglas de actualización y evidencia de al menos una fila de prueba. Evitar afirmar un esquema estrella si el modelo físico no lo implementa.

## Anexo H. Seguridad y operación

Documentar identidades worker/workflow/API, permisos IAM efectivos, región de KMS, referencias Secret Manager, configuración DLP, Logging sink, Audit Store, métricas y SLO. Distinguir **configuración declarada**, **despliegue** y **prueba de funcionamiento**. No incluir secretos ni tokens. El SLO de disponibilidad 99 % es objetivo, no cumplimiento medido.

## Anexo I. Pruebas y evidencias

Los placeholders grises de `../assets/evidencia/` identifican el archivo que deberá reemplazarse por una captura auténtica. **No son evidencia de aceptación**. Cada caso debe registrar: identificador, objetivo, precondiciones, entrada, comandos/SQL, resultado esperado, resultado observado, captura, fecha, entorno y conclusión. Priorizar pruebas P2-STR, P2-BAT, P2-TRF, P2-INT y P2-MOD.

## Anexo J. Referencias y artefactos

- [P1 — Informe de Arquitectura](https://github.com/Codenid/lumina-retail-data-platform/blob/main/docs/report/Lumina_Retail_Informe.pdf).
- `automatizacion/configuracion/runbook.json` y `automatizacion/scripts/00_runbook.sh`.
- `docs/operacion/runbooks/` para verificadores y operación.
- `soluciones/` para pipelines, API y productos desplegables.
- `../assets/arquitectura/` para ArchiMate; `../assets/miniportadas/` para ilustraciones; `../assets/evidencia/` para capturas.

**Pendiente de cierre documental:** reconciliar este inventario con los archivos de contratos, DDL y la lista efectiva de recursos GCP. Cualquier recurso no verificado debe aparecer explícitamente como tal; ningún recurso real debe omitirse del inventario final.
