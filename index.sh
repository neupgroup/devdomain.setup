#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="$(<"$BASE_DIR/host.sh")"
DEVICE_TYPE="$("$BASE_DIR/identify.sh")"

case "$DEVICE_TYPE" in
    macOS|linux) HOSTS_FILE="${NEUP_DEV_HOSTS_FILE:-/etc/hosts}" ;;
    windows) HOSTS_FILE="${NEUP_DEV_HOSTS_FILE:-${WINDIR:-/c/Windows}/System32/drivers/etc/hosts}" ;;
    *) printf 'Unsupported device type.\n' >&2; exit 1 ;;
esac

if [[ -f "$HOSTS_FILE" ]] && grep -Fqx "127.0.0.1 ${DOMAIN}" "$HOSTS_FILE"; then
    exec "$BASE_DIR/disable.dev.sh"
else
    exec "$BASE_DIR/enable.dev.sh"
fi
