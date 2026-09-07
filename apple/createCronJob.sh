#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-create}" in
    create|enable) exec "$SCRIPT_DIR/index.sh" create-cron-job ;;
    remove|disable) exec "$SCRIPT_DIR/index.sh" remove-cron-job ;;
    *) printf 'Usage: %s {create|remove}\n' "$0" >&2; exit 2 ;;
esac
