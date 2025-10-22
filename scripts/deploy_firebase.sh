#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
PROJECT_ID="${PROJECT_ID:-interufmt-7861a}"   # export PROJECT_ID=meu-projeto se quiser mudar
CHANNEL="${CHANNEL:-live}"                     # "live" para produção; qualquer outro nome cria preview
BUILD_DIR="${BUILD_DIR:-build/web}"

# ===== Funções util =====
has_cmd() { command -v "$1" >/dev/null 2>&1; }

die() { echo "❌ $*" >&2; exit 1; }

log() { echo -e "\n==> $*\n"; }

# ===== Pré-checagens =====
# Garante que as variáveis para o build web existam
: "${SUPABASE_URL:?A variável SUPABASE_URL não está definida.}"
: "${SUPABASE_ANON_KEY:?A variável SUPABASE_ANON_KEY não está definida.}"

has_cmd flutter || die "Flutter não encontrado no PATH."
has_cmd firebase || { log "firebase-tools não encontrado. Instalando..."; npm i -g firebase-tools; }

# ===== Build Flutter Web =====
log "Construindo Flutter Web…"
flutter clean >/dev/null || true
flutter pub get
flutter build web \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

# ===== firebase.json mínimo (se não existir) =====
if [[ ! -f "firebase.json" ]]; then
  log "Criando firebase.json (SPA + public=${BUILD_DIR})…"
  cat > firebase.json <<'JSON'
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json","**/.*","**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
JSON
fi

# Ajusta o "public" se você trocou BUILD_DIR
if [[ "${BUILD_DIR}" != "build/web" ]]; then
  # requer jq para editar; se não tiver jq, pula (mas o deploy ainda funciona com build/web)
  if has_cmd jq; then
    TMP_JSON="$(mktemp)"
    jq --arg pub "${BUILD_DIR}" '.hosting.public = $pub' firebase.json > "$TMP_JSON" && mv "$TMP_JSON" firebase.json
  else
    log "jq não encontrado; mantendo public=build/web no firebase.json"
  fi
fi

# ===== Projeto =====
log "Usando projeto: ${PROJECT_ID}"
firebase use "${PROJECT_ID}" >/dev/null 2>&1 || true

# ===== Deploy =====
if [[ "${CHANNEL}" == "live" ]]; then
  log "Fazendo deploy para PRODUÇÃO (Hosting live)…"
  firebase deploy --only hosting --project "${PROJECT_ID}"
else
  log "Fazendo deploy PREVIEW no canal \"${CHANNEL}\" (expira em 7 dias)…"
  firebase hosting:channel:deploy "${CHANNEL}" --project "${PROJECT_ID}" --expires 7d
fi

log "✅ Deploy finalizado."



# chmod +x ./scripts/deploy_firebase.sh

# firebase login

# ./scripts/deploy_firebase.sh

# PROJECT_ID=interufmt-7861a ./scripts/deploy_firebase.sh       
# PROJECT_ID=interufmt-7861a CHANNEL=preview-branch ./scripts/deploy_firebase.sh
