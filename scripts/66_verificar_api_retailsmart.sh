#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
heading 'Paso 66 — invocar las cuatro rutas privadas contra datos Gold'
[[ -s "$ROOT/state/$DEMO_RUN_ID/api_deploy_ok.txt" ]] || { echo 'SCRIPT 66: 0 — dependencia: SCRIPT 65'; exit 1; }
URL="$(sed -n 's/^url=//p' "$ROOT/state/$DEMO_RUN_ID/api_deploy_ok.txt")"
[[ "$URL" == https://* ]] || { echo "SCRIPT 66: 0 — URL Cloud Run inválida: $URL"; exit 1; }
TOKEN="$(gcloud auth print-identity-token)"
[[ -n "$TOKEN" ]] || { echo 'SCRIPT 66: 0 — no se pudo obtener token de identidad para la cuenta activa'; exit 1; }
OUT="$ROOT/state/$DEMO_RUN_ID/api_responses"
mkdir -p "$OUT"

UNAUTH_STATUS="$(curl --silent --show-error -m 30 --output "$OUT/unauthenticated.txt" --write-out '%{http_code}' "$URL/healthz")"
[[ "$UNAUTH_STATUS" == 401 || "$UNAUTH_STATUS" == 403 || "$UNAUTH_STATUS" == 404 ]] || { echo "SCRIPT 66: 0 — ruta pública inesperada, HTTP $UNAUTH_STATUS"; cat "$OUT/unauthenticated.txt"; exit 1; }
printf 'unauthenticated_http=%s\n' "$UNAUTH_STATUS" > "$OUT/status.txt"

for route in healthz insights kpis inventory-plans maintenance-risks; do
  case "$route" in
    healthz) path='/healthz' ;;
    insights) path='/api/v1/insights?limit=5' ;;
    kpis) path='/api/v1/kpis?limit=5' ;;
    inventory-plans) path='/api/v1/inventory-plans?limit=5' ;;
    maintenance-risks) path='/api/v1/maintenance-risks?limit=5' ;;
  esac
  BODY="$OUT/$route.json"
  ERROR="$OUT/$route.error.txt"
  if ! HTTP_STATUS="$(curl --silent --show-error --fail -m 120 --header "Authorization: Bearer $TOKEN" --output "$BODY" --write-out '%{http_code}' "$URL$path" 2> "$ERROR")"; then
    echo "SCRIPT 66: 0 — fallo invocando $path"
    cat "$ERROR" >&2
    [[ -f "$BODY" ]] && cat "$BODY" >&2
    exit 1
  fi
  python3 - "$route" "$BODY" "$HTTP_STATUS" <<'PY'
import json,sys
route,path,status=sys.argv[1:]
data=json.load(open(path,encoding='utf-8'))
if status!='200': raise SystemExit(f'{route}: HTTP {status}')
if route=='healthz':
    if data.get('status')!='ok': raise SystemExit('healthz no respondió status=ok')
    print('healthz: HTTP 200')
elif route=='insights':
    a=data.get('counts',{}).get('streaming_insights',0)
    b=data.get('counts',{}).get('stockout_risks',0)
    if a<1 or b<1: raise SystemExit(f'insights sin datos: streaming={a}, stockout={b}')
    print(f'insights: HTTP 200; streaming={a}; stockout_risks={b}')
else:
    n=int(data.get('count',0))
    if n<1: raise SystemExit(f'{route} no devolvió datos')
    print(f'{route}: HTTP 200; filas={n}; tabla={data.get("source_table")}')
PY
  printf '%s_http=%s\n' "$route" "$HTTP_STATUS" >> "$OUT/status.txt"
done
echo "SCRIPT 66: 1 — cuatro rutas autorizadas responden con datos; acceso anónimo rechazado (HTTP $UNAUTH_STATUS)"
