#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="$(<"$BASE_DIR/../host.sh")"
HOSTS_FILE="${NEUP_DEV_HOSTS_FILE:-${WINDIR:-/c/Windows}/System32/drivers/etc/hosts}"
read -r -p "Map ${DOMAIN} locally and create a cleanup job to remove it automatically in 8 hours? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { printf 'Cancelled.\n'; exit 0; }
grep -Fqx "127.0.0.1 ${DOMAIN}" "$HOSTS_FILE" 2>/dev/null || printf '127.0.0.1 %s\n' "$DOMAIN" >> "$HOSTS_FILE"
"$BASE_DIR/createCronJob.sh"
printf 'Enabled %s.\n' "$DOMAIN"
