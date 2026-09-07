#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="$(<"$BASE_DIR/../host.sh")"
TASK_NAME="Neup Dev Domain Cleanup - ${DOMAIN}"
case "${1:-create}" in
    create|enable) schtasks.exe /Create /SC HOURLY /MO 8 /TN "$TASK_NAME" /TR "\"$BASE_DIR/createCronJob.sh\" purge" /F ;;
    remove|disable) schtasks.exe /Delete /TN "$TASK_NAME" /F 2>/dev/null || true ;;
    purge) ;;
    *) printf 'Usage: %s {create|remove}\n' "$0" >&2; exit 2 ;;
esac
