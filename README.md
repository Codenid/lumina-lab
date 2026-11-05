# RetailSmart — GCP paso a paso

Este paquete permite avanzar infraestructura sin esperar a cerrar los 23 issues.
Ejecútalo en **Google Cloud Shell**. Cada comando levanta o verifica una parte;
no existe un script que ejecute todo automáticamente. No requiere Terraform,
Kubernetes ni instalar herramientas en Windows.

**Alcance real:** recorrido académico Pub/Sub → Dataflow → GCS Silver; Bronze
independiente; carga manual de Silver a BigQuery Gold. Incluye creación opcional
de Workflows, Dataproc y definición de Storage Transfer. No es la implementación
completa de los 23 issues ni de todas las funciones de la vista 08. Consulta
`docs/ALCANCE.md`: Cloud Run, Looker, catálogo, forecast y orquestación funcional
siguen pendientes. Un entorno creado no significa un caso de negocio terminado.

Basado en el ZIP base RetailSmart_Codex_Proyecto disponible el 3 de noviembre de
2026 y el reporte de RS-009 proporcionado. No se tuvo acceso al código actual
modificado durante RS-009. Se incluye contrato original y mapeo de arquitectura.

## 1. Preparar (solo una vez)

Abre Cloud Shell desde tu proyecto GCP. Sube el ZIP con el menú del terminal
(⋮ → Upload). Después:

```bash
unzip RetailSmart_GCP_Paso_a_Paso.zip
cd RetailSmart_GCP_Paso_a_Paso
cp config.env.example config.env
nano config.env
```

Cambia `PROJECT_ID` por el ID real del proyecto (no el nombre visible).
Mantén inicialmente `REGION=us-central1`, `PREFIX=rsdemo` y `DEMO_RUN_ID=demo001`.
Guarda con Ctrl+O, Enter y sal con Ctrl+X.

Usa un proyecto académico con facturación habilitada. La cuenta que ejecuta los
scripts debe poder habilitar APIs, crear recursos y asignar los permisos que
aparecen en 03. No se concede Owner/Editor ni se generan claves. Una política
organizacional o cuota puede impedir estos comandos: no se oculta ese error.

Por defecto se crean recursos con prefijo `rsdemo` para no alterar los existentes
del proyecto original. No son un segundo proyecto. Puede haber costo si dejas jobs
anteriores activos: inspecciona Dataflow antes de iniciar otra demo.

## 2. Ejecutar uno por uno y observar

No pegues toda la tabla como un único comando: ejecuta cada fila y verifica.

| Orden | Comando | Resultado esperado / dónde mirar |
|---|---|---|
| 00 | `bash scripts/00_verificar_acceso.sh` | Cuenta, proyecto, facturación y red. Si Compute API está deshabilitada, ejecutar 01 y repetir 00. |
| 01 | `bash scripts/01_habilitar_apis.sh` | APIs y agente Pub/Sub. Consola → APIs y servicios. |
| 02 | `bash scripts/02_crear_storage.sh` | Cinco buckets: Landing, Bronze, Silver, artefactos y modelos. Cloud Storage → Buckets. |
| 03 | `bash scripts/03_crear_identidad_y_permisos.sh` | Cuenta worker y permisos acotados. IAM → Cuentas de servicio. |
| 04 | `bash scripts/04_crear_bigquery.sh` | Datasets/tablas Bronze, Silver y Gold; permisos del agente Pub/Sub. BigQuery → Explorador. |
| 05 | `bash scripts/05_crear_topicos_y_suscripciones.sh` | Tópicos y suscripciones Dataflow, GCS legado y BigQuery Bronze. Requiere 04. |
| 06 | `bash scripts/06_preparar_python.sh` | Entorno Python y Beam instalados. Todavía no inicia un job. |
| 07 | `bash scripts/07_iniciar_dataflow.sh` | Job Dataflow; grafo LeerPubSub → ValidarNormalizar → SilverEventWriter. Espera RUNNING antes de 08. |
| 08 | `bash scripts/08_publicar_evento.sh` | Un evento publicado; se conserva el contenido en `state/demo001/evento.json`. |
| 09 | `bash scripts/09_verificar_silver_y_bronze.sh` | Lee y compara contenido exacto Silver; busca el mismo evento en archivos Bronze. |
| 10 | `bash scripts/10_materializar_gold.sh` | Tabla de eventos y tabla de insights por tipo en BigQuery. Paso manual, no pipeline continuo Gold. |
| 11 | `bash scripts/11_cancelar_dataflow.sh` | Cancelación y consulta de estado terminal. Ejecuta también si falló un paso desde 07. |
| 12 | `bash scripts/12_ver_estado.sh` | Inventario: recursos y estado de jobs/tablas; no modifica datos. |
| 13 | `bash scripts/13_generar_evidencia.sh` | Resumen verificable para adjuntar al issue después de 09 y 11. No cierra GitHub. |

**Primer objetivo:** ejecuta 01, 02, 03, 04 y 05; mira los recursos en consola. Ya habrás
avanzado infraestructura sin depender del procesamiento de RS-009. Continúa
con 06 a 09 para probar el recorrido y termina siempre con 11.

## 3. Qué pasa con un evento

Pub/Sub entrega una copia a cada suscripción:

- `rsdemo-bronze`: exporta el mensaje sin normalizar a GCS Bronze, en archivos por lote.
- `rsdemo-dataflow`: Dataflow valida el JSON y escribe un objeto Silver por evento.

Silver: `gs://PROJECT_ID-rsdemo-silver/eventos/demo/demo001/evt-demo001.json`.
Bronze: `gs://PROJECT_ID-rsdemo-bronze/streaming/…jsonl`.

La exportación Bronze usa lotes de 60 segundos; no se promete que el archivo esté
visible exactamente en ese tiempo. Si Silver existe y Bronze aún no, espera unos
minutos y repite 09. No consumas manualmente la suscripción de Dataflow.

La demo escribe JSON en Silver aunque el mapeo base prevé también Parquet. Este
cambio de formato necesita registrarse al integrar al proyecto. El opcional 21
sí produce Parquet con Spark. Escribir un objeto por evento evita ventanas y
finalización de archivos agrupados, pero es solo para volumen mínimo académico.

No se agregan dependencias nuevas a la arquitectura: todos los scripts se ejecutan
manualmente desde Cloud Shell. El CLI de BigQuery carga Silver en 10; no se afirma
que esto sustituya los procesadores definidos en RS-010/011.

## 4. Costos y repetición

- 01–05 crean recursos base; no arrancan Dataflow, Workflows ni Dataproc.
- Buckets, objetos, solicitudes Pub/Sub y consultas BigQuery pueden generar cargos.
- Desde 07, Dataflow genera costo aunque no reciba mensajes. Usa 11 al terminar.
- 11 conserva datos y no elimina recursos; CANCELLING no equivale a CANCELLED.
- Las consultas Gold tienen límite de 10 MB procesados; la facturación mínima de
  BigQuery puede aplicar igualmente.
- 02–05 comprueban campos relevantes al reejecutar. Si detectan divergencia, paran.
  No auditan todas las políticas avanzadas de recursos existentes.
- Para otra ejecución cambia `DEMO_RUN_ID=demo002`, sin cambiar `PREFIX`. Cancela
  primero el job anterior. 07 evita relanzar si ya registró un job de esa ejecución.
- 08 conserva el mismo JSON si se vuelve a publicar: permite verificar reintentos.
- 10 reemplaza solo las tablas de esta demo, identificadas por su DEMO_RUN_ID.

## 5. Si falla

Detente en el primer error y copia el mensaje completo. No recrees todo.

| Síntoma | Acción concreta |
|---|---|
| `PERMISSION_DENIED` | Revisar cuenta activa y operación denegada. No se interpreta como recurso inexistente. |
| Red `default` no existe | Configurar NETWORK con una red de laboratorio existente y conectividad; no se crea una red empresarial automáticamente. |
| RUNNING pero sin Silver | Dataflow → Job → Worker logs; buscar EVENTO_VALIDO, SILVER_OK y errores del SDK. Verificar permisos del worker y dependencias. Ejecutar 11 si abandonas. |
| No hay log EVENTO_VALIDO | Verificar suscripción, job y publicación; no hacer pull manual de la suscripción. |
| Silver existe, Bronze no | Pub/Sub → suscripción Bronze → estado/permisos; esperar exportación y repetir 09. |
| Falló después de lanzar, sin ID guardado | Revisar Jobs en consola antes de relanzar. Cancelar allí el job correspondiente y conservar su ID. |
| Job sigue CANCELLING | Consultar consola y repetir 11; no afirmar que dejó de generar costo. |
| Error de dependencias en 06 | Conservar error de pip y versión de Python; no probar versiones al azar. |

## 6. Verificación local

```bash
bash scripts/verificar_local.sh
```

Se verificaron sintaxis Bash, compilación Python y 10 pruebas de contrato,
serialización estable, idempotencia, bloqueo ante divergencias/permisos y
comparación de contenido. **No se ejecutaron estos scripts contra GCP**, ni se
instaló Beam en el entorno de entrega; el job real requiere validación en tu
proyecto. Los opcionales tampoco se desplegaron.

## 7. Extensiones opcionales

No son necesarias para demostrar RS-009. Consulta `docs/ALCANCE.md` antes de
activarlas. Workflows y Dataproc requieren más tiempo, cuotas y costo que el
recorrido principal. No ejecutes todos los scripts por su número sin revisar su
alcance: para la prueba Spark el orden es **22 → 21**.
