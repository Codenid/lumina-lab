# Resultado del grupo 79–83 — Auditoría y observabilidad

Proyecto: `lumina-lab-513704`
Región: `us-central1`
Resultado: **COMPLETADO**

| Script | Estado | Resultado |
|---|---:|---|
| 79 | 1 | APIs, Cloud Run y dataset Audit Store verificados |
| 80 | 1 | Sink de Cloud Logging, IAM del writer y evento sintético enviados |
| 81 | 1 | Métrica basada en logs y alert policy habilitadas |
| 82 | 1 | Servicio Cloud Monitoring y SLO de disponibilidad del 99% verificados |
| 83 | 1 | Evento encontrado en Audit Store y recursos consultados nuevamente |

## Recursos

- Audit Store: `lumina-lab-513704.luminalab_audit`.
- Sink: `luminalab-audit-sink`; evento de prueba: `obs-demo001`.
- Métrica: `logging.googleapis.com/user/luminalab_api_errors`.
- Alert policy habilitada y SLO de disponibilidad 99% sobre ventana móvil de 24 horas.

No se creó cómputo persistente ni se modificaron datos de negocio.

## Correcciones realizadas

Inicialmente faltaba `roles/logging.logWriter` para el writer identity del sink. Se aplicó únicamente ese binding a nivel de proyecto; el permiso de BigQuery permaneció limitado al dataset `luminalab_audit`. Después, el script 80 se ejecutó idempotentemente y el 83 verificó el evento con conteo 1.

El script 83 también se corrigió para manejar la salida vacía de `bq ls` durante la propagación y para generar Markdown sin ejecutar las comillas invertidas como comandos.
