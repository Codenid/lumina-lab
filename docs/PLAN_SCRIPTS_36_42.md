# Plan de preparación — scripts 36–42

El grupo implementará Forecast, scoring y planificación diaria con Dataproc,
BigQuery y Cloud Storage, respetando el contrato `config/contracts/forecast.json`.

| Script | Función | Dependencia |
|---|---|---|
| 36 | Validar contrato, APIs, cuentas de servicio, tablas y bucket de modelos | 29, 30, 35 |
| 37 | Crear/verificar tabla de features | 36 |
| 38 | Generar features desde Silver/Gold | 37 |
| 39 | Entrenar baseline y guardar artefacto versionado | 38 |
| 40 | Ejecutar scoring con el artefacto validado | 39 |
| 41 | Materializar planificación diaria en Gold | 40 |
| 42 | Verificar predicciones, planificación y evidencia | 41 |

El modelo inicial será explícitamente un baseline `moving_average_7d`, no se
presentará como modelo productivo ni como forecast avanzado. Todos los scripts
deben validar permisos antes de mutar GCP, usar claves idempotentes y detenerse
ante divergencias.
