#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
heading 'OPCIONAL — cluster Dataproc single-node; genera costo hasta borrarlo'
[[ -s "$ROOT/state/$DEMO_RUN_ID/evento.json" ]] || { echo 'Ejecuta 08 y 22 primero.'; exit 1; }
gcloud storage objects describe "gs://$BRONZE/batch/$DEMO_RUN_ID/evento.json" --format='value(name)'
gcloud services enable dataproc.googleapis.com
SA="${PREFIX}-spark@${PROJECT_ID}.iam.gserviceaccount.com"
ensure "{\"email\":\"$SA\"}" gcloud iam service-accounts describe "$SA" --format=json ::: \
 gcloud iam service-accounts create "${PREFIX}-spark"
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SA" --role=roles/dataproc.worker --condition=None >/dev/null
for bucket in "$ARTIFACTS" "$BRONZE" "$SILVER" "$MODELS"; do
 gcloud storage buckets add-iam-policy-binding "gs://$bucket" --member="serviceAccount:$SA" --role=roles/storage.objectUser >/dev/null
done
ACCOUNT="$(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
if [[ "$ACCOUNT" == *.gserviceaccount.com ]]; then MEMBER="serviceAccount:$ACCOUNT"; else MEMBER="user:$ACCOUNT"; fi
gcloud iam service-accounts add-iam-policy-binding "$SA" --member="$MEMBER" --role=roles/iam.serviceAccountUser --condition=None >/dev/null
# Para la demo se usa una red EXISTENTE con conectividad requerida por Dataproc.
# No se crean reglas de firewall amplias. Si falla red/cuota, recoger error y detenerse.
ensure "{\"config.gceClusterConfig.serviceAccount\":\"$SA\"}" \
 gcloud dataproc clusters describe "${PREFIX}-spark" --region="$REGION" --format=json ::: \
 gcloud dataproc clusters create "${PREFIX}-spark" --region="$REGION" --single-node \
 --master-machine-type=e2-standard-4 --master-boot-disk-size=50 --image-version=2.2-debian12 \
 --network="$NETWORK" --service-account="$SA" --scopes=cloud-platform \
 --bucket="$ARTIFACTS" --temp-bucket="$ARTIFACTS" --max-idle=30m --max-age=2h
# El job verifica Spark -> Bronze -> Silver Parquet, usando el evento ya validado de esta demo.
gcloud dataproc jobs submit pyspark "$ROOT/python/batch_demo.py" --cluster="${PREFIX}-spark" --region="$REGION" -- \
 "gs://$BRONZE/batch/$DEMO_RUN_ID/evento.json" "gs://$SILVER/batch/$DEMO_RUN_ID/"
echo 'Requiere 22 primero para el archivo Bronze batch. Cluster con autoeliminación configurada.'
