#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="$(<"$BASE_DIR/../host.sh")"
HOSTS_FILE="${NEUP_DEV_HOSTS_FILE:-${WINDIR:-/c/Windows}/System32/drivers/etc/hosts}"
grep -Fqx "127.0.0.1 ${DOMAIN}" "$HOSTS_FILE" 2>/dev/null && printf 'enabled\n' || printf 'disabled\n'
