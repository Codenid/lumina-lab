#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
heading 'OPCIONAL — definir job de Storage Transfer, sin ejecutarlo'
gcloud services enable storagetransfer.googleapis.com
JOB="transferJobs/${PREFIX}-landing-bronze"
ensure "{\"transferSpec.gcsDataSource.bucketName\":\"$LANDING\",\"transferSpec.gcsDataSink.bucketName\":\"$BRONZE\",\"transferSpec.gcsDataSource.path\":\"batch/\",\"transferSpec.gcsDataSink.path\":\"batch/\"}" \
 gcloud transfer jobs describe "$JOB" --format=json ::: \
 gcloud transfer jobs create "gs://$LANDING/batch/" "gs://$BRONZE/batch/" --name="$JOB" \
 --description='RetailSmart demo: Landing a Bronze batch; pendiente permisos y primera ejecución' --do-not-run
 echo 'Job definido, NO validado. Antes de ejecutarlo: configurar permisos del agente Storage Transfer en ambos buckets según docs/ALCANCE.md.'
