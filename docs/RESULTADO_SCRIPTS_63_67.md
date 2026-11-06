# Resultado del grupo 63–67 — API RetailSmart Insights

Fecha: 2026-11-05
Proyecto: `lumina-lab-513704`
Región: `us-central1`
Resultado del grupo: **COMPLETADO**

| Script | Resultado | Evidencia |
|---|---:|---|
| 63 — preflight y APIs | 1 | Contrato, APIs, ubicación y cinco tablas Gold verificados |
| 64 — identidad y permisos | 1 | Job User, cinco grants Data Viewer por tabla y permisos de build verificados |
| 65 — despliegue | 1 | Cloud Run READY, privado y revisión registrada |
| 66 — rutas | 1 | Cloud Run existe y está READY; cuatro rutas autenticadas devuelven datos |
| 67 — evidencia final | 1 | Estado, revisión e IAM consultados en GCP; cierre COMPLETADO registrado |

## Servicio

ready=True
service=luminalab-insights-api
url=https://luminalab-insights-api-pwwhgvpura-uc.a.run.app
revision=luminalab-insights-api-r8d18faca07
runtime_service_account=luminalab-api@lumina-lab-513704.iam.gserviceaccount.com
invoker=user:winstonflores30@gmail.com
authentication=private

## Rutas

- insights=streaming:2,stockout_risks:2
- kpis=rows:2,table:cu03_kpis_operativos
- inventory-plans=rows:4,table:cu02_plan_reposicion
- maintenance-risks=rows:1,table:cu04_alertas_mantenimiento

- Acceso anónimo: HTTP 403.
- Chequeo de existencia: servicio READY y revisión del intento contrastada.
- Logs de solicitudes: 16 solicitudes HTTP y 12 registros de aplicación observados en la revisión
- El grupo valida existencia/estado de Cloud Run y rutas funcionales; `/healthz` no es requisito ni regla de negocio.

## Identidades y permisos

- Runtime: `luminalab-api@lumina-lab-513704.iam.gserviceaccount.com`; BigQuery Job User en el proyecto y Data Viewer limitado a cinco tablas Gold.
- Invoker del servicio privado: `winstonflores30@gmail.com`, en IAM del servicio.
- Build: `259275898660-compute@developer.gserviceaccount.com`; Cloud Run Builder y Artifact Registry Writer acotado al repositorio.
- APIs habilitadas: Cloud Run, Cloud Build, Artifact Registry y Cloud Storage.

Evidencia local: `state/demo001/EVIDENCIA_API_RETAILSMART.md`.
El grupo 63–67 queda cerrado: servicio Cloud Run existente/READY y cuatro rutas funcionales verificadas.
