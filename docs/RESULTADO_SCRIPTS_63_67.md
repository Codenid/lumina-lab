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
| 66 — rutas | 0 | HTTP 404 antes del contenedor: la revisión no registró la solicitud; rutas de negocio no verificadas |
| 67 — evidencia final | 1 | Estado, revisión e IAM consultados en GCP; cierre parcial registrado |

## Servicio

ready=True
service=luminalab-insights-api
url=https://luminalab-insights-api-pwwhgvpura-uc.a.run.app
revision=luminalab-insights-api-r8d18faca07
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
- Logs de solicitudes: 0 solicitudes HTTP y 0 registros de aplicación observados en la revisión
- No se declara éxito funcional: la solicitud no produjo una respuesta de aplicación corroborada por logs.

## Intentos de corrección

- Intento 1: tráfico reafirmado al 100% en la revisión anterior; `/healthz` continuó en HTTP 404.
- Intento 2: revisión `luminalab-insights-api-r8d18faca07` creada con logging de entrada y tráfico 100%; `/healthz` continuó en HTTP 404 sin aparecer en los logs de la revisión.

## Identidades y permisos

- Runtime: `luminalab-api@lumina-lab-513704.iam.gserviceaccount.com`; BigQuery Job User en el proyecto y Data Viewer limitado a cinco tablas Gold.
- Invoker del servicio privado: `winstonflores30@gmail.com`, en IAM del servicio.
- Build: `259275898660-compute@developer.gserviceaccount.com`; Cloud Run Builder y Artifact Registry Writer acotado al repositorio.
- APIs habilitadas: Cloud Run, Cloud Build, Artifact Registry y Cloud Storage.

Evidencia local: `state/demo001/EVIDENCIA_API_RETAILSMART.md`.
El grupo 63–67 sigue incompleto. El reporting puede preparar vistas Gold de forma independiente; la API no se considera validada hasta resolver el HTTP 404.
