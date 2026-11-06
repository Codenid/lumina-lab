# Resultado del grupo 74–78 — Seguridad

Proyecto: `lumina-lab-513704`
Región: `us-central1`
Resultado: **COMPLETADO**

| Script | Estado | Resultado |
|---|---:|---|
| 74 | 1 | Contrato, identidad, runtime y APIs KMS/Secret Manager/DLP verificados |
| 75 | 1 | Clave simétrica regional, primaria habilitada y rotación de 90 días; agente Secret Manager limitado a la clave |
| 76 | 1 | Secreto con réplica `us-central1`, CMEK y acceso del runtime limitado al secreto |
| 77 | 1 | Plantilla DLP regional y detección sintética verificadas sin persistir quotes |
| 78 | 1 | Estado final e IAM consultados nuevamente en GCP |

## Recursos

- KMS: `luminalab-security/secret-manager-cmek`, región `us-central1`.
- Secret Manager: `luminalab-runtime-credential`; réplica regional y CMEK.
- Consumidor autorizado: `luminalab-api@lumina-lab-513704.iam.gserviceaccount.com`, solo `roles/secretmanager.secretAccessor` sobre ese secreto.
- DLP inspect template: `luminalab-sensitive-data`, región `us-central1`.

No se almacenaron secretos en el repositorio ni se imprimió el valor generado. La prueba DLP usó datos sintéticos y guardó únicamente tipos, likelihood y ubicación de hallazgos.

## Fallos y correcciones

- Script 75, intento 1: `gcloud kms keys create` devolvió `INVALID_ARGUMENT: next_rotation_time is required if rotation_schedule is set.` El keyring se conservó y la clave no llegó a crearse. Se añadió una fecha RFC3339 explícita a 90 días; intento 2 verificado con estado `ENABLED` y `rotationPeriod=7776000s`.
- Script 77, intento 1: DLP devolvió HTTP 400 porque `inspectTemplateId` no es un parámetro de query válido. No se creó plantilla ni se inspeccionó contenido. Se corrigió el cuerpo REST para usar `templateId`; intento 2 detectó `EMAIL_ADDRESS`, `PHONE_NUMBER` y `CREDIT_CARD_NUMBER`.

## Validación local

`scripts/verificar_local.sh`: **14/14 pruebas OK**. También pasaron `bash -n`, validación JSON y `git diff --check`. `shellcheck` no estaba instalado en el entorno.

## Idempotencia

Los scripts distinguen `NOT_FOUND` de errores IAM/API, validan configuración antes de reutilizar recursos y no sobrescriben divergencias. El secreto solo recibe una versión nueva si no existe ninguna versión `ENABLED`; su valor nunca se guarda en archivos de estado.
