# Alcance frente a la arquitectura original

La vista 08 contiene más componentes que el happy path. Se conserva el inventario
original `view08-gcp-mapping.csv` con los archimate_id y `view08-producers.csv`.
Esta entrega acelera el aprovisionamiento; no reemplaza el backlog ni certifica
la implementación de todos los elementos.

| Componente original | Qué entrega este paquete | Qué falta |
|---|---|---|
| Landing | Bucket en 02 | Seis archivos/productores reales o sintéticos batch |
| Bronze Layer | Tablas BigQuery `eventos_raw` y `*_raw` por dominio; Landing conserva archivos batch | Contratos completos actuales y gobierno |
| Silver Layer / Silver Eventos Curados | Tablas BigQuery normalizadas para pedidos, inventario, entregas y telemetría | Alinear formato con RS-002 actual; optimización no requerida para demo |
| Modelo de Demanda | Bucket de modelos en 02 | Entrenamiento y artefacto real |
| Tópico Eventos Retail | Tópico + suscripciones Bronze/Dataflow en 04 | Seis productores; aquí solo un fixture del contrato original |
| Tópico Insights Retail | Tópico creado en 04 | Publicación y consumo funcionales |
| Auditoría de Procesamiento | Tópico creado en 04 | Publicación/consumo de auditoría de negocio |
| Ingesta Streaming Dataflow | Job académico ejecutable con un worker en 07 | Ejecución real, evidencia e integración al repo actual |
| Procesamiento Tiempo Real Dataflow | No se implementa segundo job | RS-010; Gold de 10 es carga manual de demo |
| Gold Insights Retail | Dataset + tablas de demo en 05/10 | KPIs finales, actualización continua |
| Gold Operational Mart | No implementado | Integración streaming + batch RS-017 |
| Ingesta Batch / Storage Transfer Service | Job definible en 21, sin ejecutar | IAM del agente y primera transferencia verificada |
| Orquestación Batch / Workflows | Workflow opcional en 20 | Integración completa de negocio y permisos de ejecución RS-015 |
| Procesamiento Batch / Dataproc | Cluster opcional en 23 y job mínimo JSON → Parquet | Seis fuentes y transformaciones de negocio RS-014 |
| Entrenamiento Forecast / Scoring diario | Sin implementación | RS-016; no se presenta copia de archivos como ML |
| API RetailSmart Insights / Cloud Run | Sin implementación | API de negocio RS-018; evita desplegar un hello-world como falsa evidencia |
| Reporting / Looker | Sin aprovisionamiento | Instancia/licencia/conexión reales. No se sustituye por Looker Studio sin decisión explícita |
| Gobierno / Knowledge Catalog | Inventario CSV original conservado | Catálogo y linaje reales RS-021; inventario no equivale a catálogo desplegado |
| Seguridad IAM · KMS · DLP | Identidad y permisos IAM mínimos | Controles KMS/DLP RS-022 |
| Audit Store | Logs del worker disponibles en Cloud Logging | Auditoría de negocio y configuración Analytics declaradas en el modelo |

## Workflows opcional: 20

El script `scripts/20_opcional_crear_workflow.sh` despliega la definición
`config/workflows/rsdemo-batch.yaml` en Google Cloud Workflows. El workflow
verifica la materialización del Operational Mart mediante BigQuery y devuelve
el resultado de la ejecución. La definición no afirma que todos los procesos
batch existan solo por desplegar el recurso.

**Workflows cobra por ejecuciones y pasos, sin mantener un entorno de cómputo
continuo.** Eliminación manual, con confirmación del CLI:

```bash
bash scripts/90_eliminar_computo_opcional.sh TU_PROJECT_ID workflow
```

## Secuencia opcional: 20 → 21 → 22 → 23

21 define Storage Transfer con permisos limitados y `--do-not-run`. 22 copia el
fixture de la demo a Landing y Bronze. Esa copia es manual: no representa
Storage Transfer. 23 crea un cluster single-node y ejecuta Spark que
lee Bronze y escribe Silver Parquet. El archivo Bronze se verifica antes de
crear el cluster. Se requieren red, conectividad y cuotas Dataproc del proyecto.
El cluster configura autoeliminación por inactividad de 30 min y edad máxima de
2 h; verifica esos valores en consola. Al terminar puedes eliminarlo antes:

```bash
bash scripts/90_eliminar_computo_opcional.sh TU_PROJECT_ID spark
```

No se agregan permisos amplios ni reglas de firewall para resolver un fallo de
red automáticamente. Conservar el mensaje y corregir solo el requisito concreto.

## Storage Transfer opcional: 21

Crea la definición Landing/batch → Bronze/batch sin iniciarla (`--do-not-run`).
Antes de ejecutar hay que obtener la identidad real del agente de Storage Transfer
y concederle los permisos de origen/destino publicados por GCP. No se adivina una
cuenta de servicio ni se concede Storage Admin sobre el proyecto. No marcar esta
parte validada hasta transferir y leer el archivo destino.

## Siguiente bloque batch: 24–28

24 solicita una transferencia controlada y conserva la respuesta de la
operación. 25 despliega la definición vigente de Workflows. 26 ejecuta el
workflow con `DEMO_RUN_ID`. 27 verifica el destino Bronze y la última ejecución
del workflow. 28 genera la evidencia. Estos pasos no presentan el workflow
actual como una implementación completa de todas las transformaciones de
negocio; esa ampliación permanece pendiente.

## Integración con el proyecto actual

Este paquete es independiente, no un parche sobre código RS-009 que no pudimos
inspeccionar. Usa prefijo separado. Para reutilizar recursos existentes cambia
nombres y verifica configuración primero; no reemplaces buckets ni suscripciones
silenciosamente. El reporte de RS-009 tiene prioridad sobre el estado PLANNED de
los CSV de la versión base en lo que concierne a trabajo ya realizado.

La simplificación del usuario permite trabajar el recorrido mínimo, pero al
integrarlo hay que documentar la decisión de JSON por evento, el único fixture y
el Gold manual. No actualizar el modelo para fingir que funciones pendientes ya
están implementadas.

## Fuentes técnicas

- https://docs.cloud.google.com/pubsub/docs/create-cloudstorage-subscription
- https://docs.cloud.google.com/dataflow/docs/concepts/security-and-permissions
- https://docs.cloud.google.com/dataflow/docs/guides/stopping-a-pipeline
- https://beam.apache.org/get-started/downloads/ (Beam 2.77.0)
- https://beam.apache.org/documentation/sdks/python-dependencies/
- https://docs.cloud.google.com/bigquery/docs/loading-data-cloud-storage-json
- https://cloud.google.com/workflows/docs/create-workflow
- https://docs.cloud.google.com/sdk/gcloud/reference/dataproc/clusters/create
- https://docs.cloud.google.com/sdk/gcloud/reference/transfer/jobs/create
