#!/usr/bin/env bash
set -e

VAULT=${VAULT:-vault}
INIT_SCRIPT=/vault/vault-init.sh

# Corriger VAULT_ADDR si nécessaire
if [ "$VAULT_ADDR" = "http://0.0.0.0:8200" ]; then
  export VAULT_ADDR="http://127.0.0.1:8200"
fi

# Lancer Vault en arrière-plan
$VAULT server -config=/vault/config/config.hcl &
VAULT_PID=$!

echo "⏳ Attente que Vault écoute..."
count=0
timeout=120
until $VAULT status > /dev/null 2>&1; do
  sleep 2
  count=$((count+2))
  echo "Vault pas encore prêt..."
  if [ $count -ge $timeout ]; then
    echo "❌ Timeout : Vault n'a pas démarré"
    kill $VAULT_PID
    exit 1
  fi
done

echo "✅ Vault est prêt, lancement de l'init script..."
sh $INIT_SCRIPT

# Rester au premier plan pour que Docker garde le conteneur actif
wait $VAULT_PID
