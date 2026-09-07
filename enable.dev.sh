#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "$("$BASE_DIR/identify.sh")" in
    macOS) exec "$BASE_DIR/macOs/enableDevDomain.sh" ;;
    linux) exec "$BASE_DIR/linux/enableDevDomain.sh" ;;
    windows) exec "$BASE_DIR/windows/enableDevDomain.sh" ;;
    *) printf 'Unsupported device type.\n' >&2; exit 1 ;;
esac
