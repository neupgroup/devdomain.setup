#!/usr/bin/env sh

# Identify the host operating system in a shell-independent way.
# The result is printed to stdout so callers can use:
#   device_type="$(./index.sh)"

set -eu

os_name="$(uname -s 2>/dev/null || printf '%s' "")"

case "$os_name" in
    Darwin)
        device_type="apple"
        ;;

    Linux)
        device_type="linux"
        ;;

    MINGW*|MSYS*|CYGWIN*)
        device_type="windows"
        ;;

    *)
        # Some Windows shell environments do not provide a useful uname.
        case "${OS:-}" in
            Windows_NT)
                device_type="windows"
                ;;
            *)
                printf 'Unsupported operating system: %s\n' "${os_name:-unknown}" >&2
                exit 1
                ;;
        esac
        ;;
esac

printf '%s\n' "$device_type"
