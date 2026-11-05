# Informe final — scripts 20–23

Fecha: 2026-11-05  
Proyecto: `lumina-lab-513704`  
Región: `us-central1`  
Ejecución: `demo001`

## Estado

| Script | Estado | Evidencia |
|---|---|---|
| 20 — Workflows | Ejecutado y verificado | `luminalab-batch`, estado `ACTIVE`, revisión `000001-273`. |
| 21 — Storage Transfer | Ejecutado y verificado | Job `transferJobs/luminalab-landing-bronze`, estado `ENABLED`, configurado con `--do-not-run`. |
| 22 — preparación batch | Ejecutado y verificado | `evento.json` presente en Landing y Bronze. |
| 23 — Dataproc | Ejecutado y verificado | Job `b200c74c574f4f8da27c538d036db5fd`, estado `DONE`; salida Parquet en Silver. |
| 90 — eliminación Dataproc | Ejecutado y verificado | Clúster `luminalab-spark` eliminado; no quedan clústeres activos. |

## Correcciones aplicadas

- Storage Transfer obtiene el agente real del proyecto y aplica permisos limitados por bucket antes de crear el job.
- El script 21 verifica las políticas del agente y ejecuta `describe` después de crear el job.
- Dataproc en el script 23 muestra cada etapa, especifica el proyecto en los comandos y usa la zona `us-central1-a` para evitar la zona por defecto `us-east1-b`.
- Se conservan los errores de IAM, red o cuota; solo se trata `NOT_FOUND` como ausencia de recurso.

## Verificaciones finales

- Workflow: `ACTIVE`.
- Storage Transfer: `ENABLED`; no se ejecutó transferencia.
- Job Dataproc: `DONE`.
- Clúster Dataproc: eliminado.
- Salida Silver: `gs://lumina-lab-513704-luminalab-silver/batch/demo001/part-00000-5f06f1d9-3078-47e2-80cb-3e339bf89153-c000.snappy.parquet`.
- Pruebas locales: 10 pruebas aprobadas y sintaxis Bash validada para 21, 23 y 90.

## Pendientes

- Storage Transfer está definido, pero no se ha ejecutado ninguna transferencia real.
- Las correcciones y renumeración de los scripts 21 y 23 se publican con este cambio.
