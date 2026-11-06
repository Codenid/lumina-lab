# Lumina Lab — arquitectura de datos reproducible en GCP

Este repositorio aprovisiona y demuestra, mediante scripts Bash idempotentes,
una plataforma académica de datos en GCP: ingesta batch y streaming, capas
Bronze/Silver/Gold en BigQuery, Workflows, Dataproc, Cloud Run, gobierno,
seguridad, auditoría y observabilidad.

Los scripts crean o verifican recursos existentes. Si encuentran una
configuración divergente o un error de permisos, se detienen: no borran datos
ni amplían permisos de forma implícita.

## Antes de ejecutar

Estas son las únicas acciones manuales necesarias. No se pueden automatizar de
forma segura desde el repositorio porque dependen de tu cuenta y organización:

1. Crea o selecciona un proyecto GCP con facturación habilitada.
2. Instala Google Cloud CLI, Python 3.10+ y autentica la cuenta:

   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. La cuenta debe poder habilitar APIs, crear recursos y administrar los IAM
   mínimos que los scripts asignan. Una política de organización, cuota o falta
   de permisos se informa como error y debe resolverse fuera del script.
4. Copia y completa la configuración local, que nunca se versiona:

   ```bash
   cp config.env.example config.env
   ```

   Define un `PROJECT_ID` existente, una `REGION`, una red existente en
   `NETWORK`, un `PREFIX` exclusivo y un `DEMO_RUN_ID` nuevo.

## Secuencia reproducible

Valida primero que el repositorio contiene todo el recorrido:

```bash
bash scripts/00_runbook.sh
```

Después ejecuta, en orden, los grupos declarados en
[`config/runbook.json`](config/runbook.json). Cada script comunica su resultado
en GCP y conserva los marcadores y evidencias del intento bajo
`state/<DEMO_RUN_ID>/`, que está excluido de Git.

```bash
bash scripts/00_verificar_acceso.sh
# Continúa 01, 02, ..., 83 respetando config/runbook.json.
```

El bloque `07 → 11` y el bloque `45 → 48` inician Dataflow temporalmente. No
avances sin que el job esté `RUNNING`, y ejecuta siempre el paso de cierre
(`11` o `48`) incluso si falla la validación. Los pasos `20–23` habilitan
Workflows, Storage Transfer y Dataproc; Dataproc genera cómputo y se
autoelimina según su configuración. El script `90` **no es parte del runbook**:
es una eliminación manual opcional de cómputo.

## Costos y seguridad

El repositorio crea recursos que pueden facturar: almacenamiento, BigQuery,
Pub/Sub, Dataflow, Workflows, Dataproc, Cloud Run y Monitoring. Revisa cuotas,
presupuesto y políticas de tu proyecto antes de ejecutar. No subas `config.env`,
`state/`, `.venv/` ni artefactos locales; ya están cubiertos por `.gitignore`.

## Validación local

```bash
bash scripts/verificar_local.sh
for script in scripts/*.sh; do bash -n "$script"; done
```

Las pruebas locales validan contratos, idempotencia y sintaxis. No sustituyen
las verificaciones reales que hacen los scripts contra GCP.

## Documentación que acompaña el despliegue

- [`docs/ALCANCE.md`](docs/ALCANCE.md): alcance, decisiones y exclusiones.
- [`docs/CASOS_USO.md`](docs/CASOS_USO.md): los cuatro casos de uso.
- [`docs/CONTROL_SCRIPTS.md`](docs/CONTROL_SCRIPTS.md): orden, dependencias y
  cierre de cada grupo.
- [`docs/view08-gcp-mapping.csv`](docs/view08-gcp-mapping.csv): mapeo desde
  ArchiMate a GCP.

Looker y una aplicación externa de consumo no se aprovisionan en este
repositorio: las vistas Gold quedan disponibles para integrarlas posteriormente.
