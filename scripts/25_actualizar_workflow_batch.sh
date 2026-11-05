#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
heading 'Paso 25 — desplegar la definición vigente de Workflows'
WORKFLOW_NAME="${WORKFLOW_NAME:-${PREFIX}-batch}"
WORKFLOW_FILE="$ROOT/config/workflows/batch.yaml"
[[ -f "$WORKFLOW_FILE" ]] || { echo "Falta $WORKFLOW_FILE"; exit 1; }
gcloud workflows deploy "$WORKFLOW_NAME" --project="$PROJECT_ID" --location="$REGION" \
  --source="$WORKFLOW_FILE" --description='RetailSmart: orquestación batch Bronze-Silver-Gold'
gcloud workflows describe "$WORKFLOW_NAME" --project="$PROJECT_ID" --location="$REGION" \
  --format='table(name,state,revisionId)'
printf 'Workflow desplegado: %s\n' "$WORKFLOW_NAME" > "$ROOT/state/$DEMO_RUN_ID/workflow_deployed.txt"
