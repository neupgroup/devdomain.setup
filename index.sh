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
if [[ "$("$PLATFORM_DIR/check.sh")" == enabled ]]; then
    exec "$BASE_DIR/disable.dev.sh"
else
    exec "$BASE_DIR/enable.dev.sh"
fi
