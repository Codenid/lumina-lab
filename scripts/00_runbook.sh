#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/common.sh"
heading 'Runbook — ejecución controlada de scripts pendientes'
RUN_STATE="$ROOT/state/$DEMO_RUN_ID/runbook.json"
mkdir -p "$(dirname "$RUN_STATE")"
if [[ ! -f "$RUN_STATE" ]]; then printf '{"status":"STARTED","results":[]}\n' > "$RUN_STATE"; fi

python3 - "$ROOT/config/runbook.json" "$ROOT/scripts" <<'PY'
import json, pathlib, sys
manifest=json.load(open(sys.argv[1])); scripts=pathlib.Path(sys.argv[2])
for group in manifest['groups']:
    for number in group['scripts']:
        matches=sorted(scripts.glob(f'{number}_*.sh'))
        if not matches:
            print(f'SCRIPT {number}: 0')
            print(f'Dependencia faltante: script {number} no existe todavía.')
            print('Runbook detenido en el primer 0.')
            raise SystemExit(1)
        print(f'SCRIPT {number}: disponible')
print('Todos los scripts pendientes están disponibles; ejecución GCP no iniciada por este preflight.')
PY
