#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_TYPE="$("$BASE_DIR/identify.sh")"
case "$DEVICE_TYPE" in
    macOS) PLATFORM_DIR="$BASE_DIR/macOs" ;;
    linux) PLATFORM_DIR="$BASE_DIR/linux" ;;
    windows) PLATFORM_DIR="$BASE_DIR/windows" ;;
    *) printf 'Unsupported device type.\n' >&2; exit 1 ;;
esac
case "${1:-}" in
    enable) exec "$BASE_DIR/enable.dev.sh" ;;
    disable) exec "$BASE_DIR/disable.dev.sh" ;;
    status) printf 'Domain status: %s\n' "$("$PLATFORM_DIR/check.sh")" ;;
    help)
        printf 'Usage:\n'
        printf '  ./index enable   Enable the local domain mapping\n'
        printf '  ./index disable  Disable the local domain mapping\n'
        printf '  ./index status   Show the domain status\n'
        printf '  ./index help     Show this help message\n'
        ;;
    *) printf 'Error: a command is required. For help, enter: ./index help\n' >&2; exit 2 ;;
esac
