# Neup Dev Domain

The `macOs` folder contains a macOS-only Bash tool that maps `dev.neupgroup.com` to `127.0.0.1`.

## Installation

```bash
cd apple
chmod +x index.sh enableDevDomain.sh disableDevDomain.sh createCronJob.sh
./index.sh enable
```

Enable requests administrator permission only when `/etc/hosts` must change. State is stored in `~/.neup-dev-domain/`; the LaunchAgent is `~/Library/LaunchAgents/com.neup.dev-domain-cleanup.plist`.

## Commands

```bash
./index.sh enable
./index.sh disable
./index.sh status
./index.sh purge
```

`disable` asks for confirmation. `purge` is safe to run repeatedly and removes only the exact line `127.0.0.1 dev.neupgroup.com`.

The LaunchAgent invokes the installed script using an absolute path every 86400 seconds. It checks the expiry timestamp and removes the mapping, expiry file, and its own plist after 15 days. Since launchd checks every 24 hours, cleanup may occur shortly after the 15-day expiry rather than at the exact second.

## Stored files

- `~/.neup-dev-domain/dev-domain.sh`
- `~/.neup-dev-domain/expiry`
- `~/.neup-dev-domain/cleanup.log`
- `~/.neup-dev-domain/error.log`
- `~/Library/LaunchAgents/com.neup.dev-domain-cleanup.plist`
