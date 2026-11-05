# Resultado del grupo 63–67 — API RetailSmart Insights

Fecha: 2026-11-05
Proyecto: `lumina-lab-513704`
Región: `us-central1`
Resultado del grupo: **PARCIAL**

| Script | Resultado | Evidencia |
|---|---:|---|
| 63 — preflight y APIs | 1 | Contrato, APIs, ubicación y cinco tablas Gold verificados |
| 64 — identidad y permisos | 1 | Job User, cinco grants Data Viewer por tabla y permisos de build verificados |
| 65 — despliegue | 1 | Cloud Run READY, privado y revisión registrada |
| 66 — rutas | 0 | HTTP 404 al invocar /healthz; causa no determinada; rutas de negocio no verificadas |
| 67 — evidencia final | 1 | Estado, revisión e IAM consultados en GCP; cierre parcial registrado |

## Servicio

ready=True
service=luminalab-insights-api
url=https://luminalab-insights-api-pwwhgvpura-uc.a.run.app
revision=luminalab-insights-api-ra77c199111
runtime_service_account=luminalab-api@lumina-lab-513704.iam.gserviceaccount.com
invoker=user:winstonflores30@gmail.com
authentication=private

## Rutas

- healthz=FALLIDA; curl: (22) The requested URL returned error: 404
- insights=NO_VERIFICADA
- kpis=NO_VERIFICADA
- inventory-plans=NO_VERIFICADA
- maintenance-risks=NO_VERIFICADA

- Acceso anónimo: HTTP 404.
- Invocación autenticada: curl: (22) The requested URL returned error: 404
- Logs de solicitudes: 0 entradas HTTP 404 para luminalab-insights-api-ra77c199111; filtro Cloud Logging devolvió []
- No se declara éxito funcional: la solicitud no produjo una respuesta de aplicación corroborada por logs.

## Identidades y permisos

- Runtime: `luminalab-api@lumina-lab-513704.iam.gserviceaccount.com`; BigQuery Job User en el proyecto y Data Viewer limitado a cinco tablas Gold.
- Invoker del servicio privado: `winstonflores30@gmail.com`, en IAM del servicio.
- Build: `259275898660-compute@developer.gserviceaccount.com`; Cloud Run Builder y Artifact Registry Writer acotado al repositorio.
- APIs habilitadas: Cloud Run, Cloud Build, Artifact Registry y Cloud Storage.

Evidencia local: `state/demo001/EVIDENCIA_API_RETAILSMART.md`.
El grupo 63–67 sigue incompleto. No ejecutar 68–71 hasta resolver el HTTP 404 y verificar las cuatro rutas.
