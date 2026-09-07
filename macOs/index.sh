#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; DOMAIN="$(<"$BASE_DIR/../host.sh")"; HOSTS_ENTRY="127.0.0.1 ${DOMAIN}"; LABEL="com.neup.dev-domain-cleanup"; INTERVAL_SECONDS=28800
DATA_DIR="${NEUP_DEV_DOMAIN_HOME:-${HOME}/.neup-dev-domain}"
INSTALLED_SCRIPT="${DATA_DIR}/dev-domain.sh"; EXPIRY_FILE="${DATA_DIR}/expiry"; CLEANUP_LOG="${DATA_DIR}/cleanup.log"; ERROR_LOG="${DATA_DIR}/error.log"
PLIST="${NEUP_DEV_DOMAIN_LAUNCH_AGENTS:-${HOME}/Library/LaunchAgents}/${LABEL}.plist"; HOSTS_FILE="${NEUP_DEV_DOMAIN_HOSTS_FILE:-/etc/hosts}"; LAUNCHCTL="${NEUP_DEV_DOMAIN_LAUNCHCTL:-/bin/launchctl}"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
require_macos() { [[ "${NEUP_DEV_TEST_MODE:-0}" == 1 || "$(uname -s)" == Darwin ]] || die 'This tool only runs on macOS.'; }
has_entry() { [[ -f "$HOSTS_FILE" ]] && awk -v entry="$HOSTS_ENTRY" '$0 == entry { found=1 } END { exit !found }' "$HOSTS_FILE"; }
flush_dns() { [[ "${NEUP_DEV_TEST_MODE:-0}" == 1 ]] || { sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder 2>/dev/null || true; }; }
add_entry() { has_entry && return 0; if [[ "${NEUP_DEV_TEST_MODE:-0}" == 1 ]]; then printf '%s\n' "$HOSTS_ENTRY" >> "$HOSTS_FILE"; else printf '%s\n' "$HOSTS_ENTRY" | sudo tee -a "$HOSTS_FILE" >/dev/null; fi; }
remove_entry() { [[ -f "$HOSTS_FILE" ]] || return 0; if [[ "${NEUP_DEV_TEST_MODE:-0}" == 1 ]]; then sed -i.bak -e "/^${HOSTS_ENTRY//./\.}$/d" "$HOSTS_FILE"; rm -f "${HOSTS_FILE}.bak"; else sudo sed -i '' -e "/^${HOSTS_ENTRY//./\.}$/d" "$HOSTS_FILE"; fi; }

create_cron_job() {
    mkdir -p "$(dirname "$PLIST")"
    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>Label</key><string>${LABEL}</string><key>ProgramArguments</key><array><string>${INSTALLED_SCRIPT}</string><string>purge</string></array><key>StartInterval</key><integer>${INTERVAL_SECONDS}</integer><key>StandardOutPath</key><string>${CLEANUP_LOG}</string><key>StandardErrorPath</key><string>${ERROR_LOG}</string></dict></plist>
EOF
    "$LAUNCHCTL" unload "$PLIST" >/dev/null 2>&1 || true; "$LAUNCHCTL" load "$PLIST"
}
remove_cron_job() { [[ -f "$PLIST" ]] && "$LAUNCHCTL" unload "$PLIST" >/dev/null 2>&1 || true; rm -f "$PLIST"; }
time_string() { date -r "$1" '+%Y-%m-%d %H:%M:%S %Z'; }

enable() {
    require_macos
    read -r -p "Map ${DOMAIN} locally and create a cleanup job? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { printf 'Cancelled.\n'; return; }
    mkdir -p "$DATA_DIR"; cp "$BASE_DIR/index.sh" "$INSTALLED_SCRIPT"; chmod 700 "$INSTALLED_SCRIPT"; add_entry
    local now expiry; now="$(date +%s)"; expiry=$((now + 15 * 24 * 60 * 60)); printf '%s\n' "$expiry" > "$EXPIRY_FILE"; chmod 600 "$EXPIRY_FILE"
    create_cron_job; flush_dns; printf 'Activated: %s\nExpires: %s\n' "$(time_string "$now")" "$(time_string "$expiry")"
}
disable() { require_macos; read -r -p "Disable ${DOMAIN} and remove its local mapping? [y/N] " answer; [[ "$answer" =~ ^[Yy]$ ]] || { printf 'Cancelled.\n'; return; }; remove_entry; rm -f "$EXPIRY_FILE"; remove_cron_job; flush_dns; printf 'Disabled %s.\n' "$DOMAIN"; }
purge() { require_macos; [[ -f "$EXPIRY_FILE" ]] || return 0; local expiry now; expiry="$(<"$EXPIRY_FILE")"; [[ "$expiry" =~ ^[0-9]+$ ]] || die 'Invalid expiry timestamp.'; now="$(date +%s)"; (( now >= expiry )) || return 0; remove_entry; rm -f "$EXPIRY_FILE"; remove_cron_job; flush_dns; printf 'Purged expired domain mapping.\n'; }
status() { require_macos; local enabled=no mapped=no loaded=no plist_exists=no activation='not set' expiry='not set' expiry_epoch; if [[ -f "$EXPIRY_FILE" ]]; then enabled=yes; expiry_epoch="$(<"$EXPIRY_FILE")"; activation="$(time_string "$((expiry_epoch - 15 * 24 * 60 * 60))")"; expiry="$(time_string "$expiry_epoch")"; fi; has_entry && mapped=yes || true; if [[ -f "$PLIST" ]]; then plist_exists=yes; "$LAUNCHCTL" list 2>/dev/null | grep -Fq "$LABEL" && loaded=yes || true; fi; printf 'Enabled: %s\nHosts mapping: %s\nActivation: %s\nExpiry: %s\nLaunchd plist: %s\nLaunchd loaded: %s\nCleanup interval: every 8 hours\n' "$enabled" "$mapped" "$activation" "$expiry" "$plist_exists" "$loaded"; }

case "${1:-}" in enable) enable ;; disable) disable ;; status) status ;; purge) purge ;; create-cron-job) require_macos; create_cron_job ;; remove-cron-job) require_macos; remove_cron_job ;; *) printf 'Usage: %s {enable|disable|status|purge}\n' "$0" >&2; exit 2 ;; esac
