#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="$(<"$BASE_DIR/../host.sh")"
HOSTS_FILE="${NEUP_DEV_HOSTS_FILE:-/etc/hosts}"
read -r -p "Disable ${DOMAIN} and remove its local mapping? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { printf 'Cancelled.\n'; exit 0; }
sudo sed -i.bak -e "/^127\.0\.0\.1 ${DOMAIN//./\.}$/d" "$HOSTS_FILE"
rm -f "${HOSTS_FILE}.bak"
"$BASE_DIR/createCronJob.sh" remove
printf 'Disabled %s.\n' "$DOMAIN"
