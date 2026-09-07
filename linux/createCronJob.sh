#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="$(<"$BASE_DIR/../host.sh")"
CRON_MARKER="# neup-dev-domain-${DOMAIN}"
CRON_LINE="0 0 * * * ${BASE_DIR}/createCronJob.sh purge ${CRON_MARKER}"
case "${1:-create}" in
    create|enable) (crontab -l 2>/dev/null | grep -vF "$CRON_MARKER" || true; printf '%s\n' "$CRON_LINE") | crontab - ;;
    remove|disable) (crontab -l 2>/dev/null | grep -vF "$CRON_MARKER" || true) | crontab - ;;
    purge) ;;
    *) printf 'Usage: %s {create|remove}\n' "$0" >&2; exit 2 ;;
esac
