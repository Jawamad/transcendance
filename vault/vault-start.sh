#!/usr/bin/env sh
# start-vault.sh
set -e

VAULT=${VAULT:-vault}

vault server -config=/vault/config/config.hcl &  # lance Vault
VAULT_PID=$!

# echo "⏳ Attente que Vault soit accessible..."
# while true; do
#   STATUS_JSON=$($VAULT status -format=json 2>/dev/null || true)
#   echo "$STATUS_JSON" | grep -q '"sealed"' && break
#   echo "Vault pas encore prêt..."
#   sleep 2
# done
# echo "✅ Vault répond à l’API HTTP."

sh /vault/vault-init.sh

wait $VAULT_PID  # garder Vault comme PID1
