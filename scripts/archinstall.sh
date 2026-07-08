#!/usr/bin/env bash

# Arch install bootstrap — hosted at foo.mydomain.com
# Usage from the Arch live ISO:
#   bash <(curl -sL foo.mydomain.com)
set -euo pipefail

CONFIG_URL="https://raw.githubusercontent.com/coko7/archy-factory/main/archinstall/user_configuration.json"
# Optional: only set this if you're hosting credentials somewhere (NOT a public repo)
CREDS_URL=""

cd /root

echo ">>> Fetching archinstall configuration..."
curl -fsSL -o user_configuration.json "$CONFIG_URL"

ARGS=(--config /root/user_configuration.json)

if [[ -n "$CREDS_URL" ]]; then
  echo ">>> Fetching credentials..."
  curl -fsSL -o user_credentials.json "$CREDS_URL"
  ARGS+=(--creds /root/user_credentials.json)
fi

# Make sure archinstall is current (live ISOs can ship stale versions)
echo ">>> Updating archinstall..."
pacman -Sy --noconfirm archinstall || true

echo ">>> Launching archinstall..."
exec archinstall "${ARGS[@]}"
