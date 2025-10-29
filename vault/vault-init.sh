#!/usr/bin/env sh
set -e

# ============================
# ✅ Configuration de base
# ============================

# S'assurer que la CLI "vault" est bien appelée
VAULT=${VAULT:-vault}

# Définir une adresse par défaut si non fournie
export VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200}

INIT_FILE=/vault/init.txt
UNSEAL_KEY_FILE=/vault/unseal.key
ROOT_TOKEN_FILE=/vault/root.token

echo "🚀 Script d’initialisation Vault lancé..."

# ============================
# ⏳ Attente que Vault soit accessible
# ============================

echo "⏳ Attente que Vault soit accessible..."
while true; do
  STATUS_JSON=$($VAULT status -format=json 2>/dev/null || true)
  echo "$STATUS_JSON" | grep -q '"sealed"' && break
  echo "Vault pas encore prêt..."
  sleep 2
done
echo "✅ Vault répond à l’API HTTP."


# # ============================
# # 🛠 Initialisation si nécessaire
# # ============================

if ! $VAULT status -format=json 2>/dev/null | grep -q '"initialized":true'; then
  echo "🛠 Initialisation de Vault (1 clé)..."
  $VAULT operator init -key-shares=1 -key-threshold=1 > "$INIT_FILE"

  grep 'Unseal Key 1:' "$INIT_FILE" | awk '{print $NF}' > "$UNSEAL_KEY_FILE"
  grep 'Initial Root Token:' "$INIT_FILE" | awk '{print $NF}' > "$ROOT_TOKEN_FILE"

  echo "🔑 Fichiers générés :"
  echo " - Unseal key : $UNSEAL_KEY_FILE"
  echo " - Root token : $ROOT_TOKEN_FILE"
else
  echo "ℹ️ Vault est déjà initialisé."
fi

# # ============================
# # 🔓 Déverrouillage
# # ============================

UNSEAL_KEY=$(cat "$UNSEAL_KEY_FILE" 2>/dev/null || true)
if [ -n "$UNSEAL_KEY" ]; then
  echo "🔓 Déverrouillage de Vault..."
  $VAULT operator unseal "$UNSEAL_KEY" || true
else
  echo "⚠️ Clé de déverrouillage introuvable — impossible d’unsealer."
fi

# # ============================
# # 🔐 Connexion Root
# # ============================

ROOT_TOKEN=$(cat "$ROOT_TOKEN_FILE" 2>/dev/null || true)
if [ -n "$ROOT_TOKEN" ]; then
  echo "🔑 Connexion avec le root token..."
  $VAULT login "$ROOT_TOKEN" >/dev/null 2>&1 || true
else
  echo "⚠️ Aucun root token disponible."
fi

# # ============================
# # 💾 Secrets initiaux (optionnel)
# # ============================

echo "💾 Ajout de secrets initiaux..."
$VAULT kv put secret/backend \
  JWT_SECRET="SuperSecretJWT" \
  DATABASE_URL="file:/app/data/database.sqlite" \
  SQLITE_ENCRYPTION_KEY="MaCleChiffrementSQLite123" || true

echo "✅ Initialisation terminée."

