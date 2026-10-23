# Troubleshooting

Memory Sentry supports Windows 10 and Windows 11 desktop editions only. These steps apply to the experimental Rust companion.

## Dashboard shows "connection unavailable"

The installer launches the companion automatically and waits for its authenticated local API to respond. The dashboard displays an HTTP/API error where available. For failures that happen before the API starts, inspect:

\`%LOCALAPPDATA%\\SpicetifyMemorySentry\\logs\\startup.log\`

For runtime events after the API starts, inspect \`helper.log\` in the same \`logs\` folder. These logs stay on the PC and are not uploaded. If the startup log says the API port is already in use, close the other program using port 38472 and launch Memory Sentry again.

Marketplace installs the dashboard only. Download the official Memory Sentry Setup executable from https://github.com/yanlvl99/spicetify-memory-sentry/releases and verify its SHA-256 file. Check the diagnostic before repeatedly reinstalling.

## Setup says Spotify is running

Close Spotify from its own menu and make sure all Spotify.exe processes have exited. Setup refuses to replace files while Spotify is active.

## Setup says Spicetify was not found

Install Spicetify CLI for the same Windows user account that runs Spotify. Reopen your terminal/session so PATH changes apply, then retry Setup. Setup does not silently download and execute Spicetify on the user's behalf.

## Setup refuses a legacy migration

A previous version may have working-set-backup.json containing original Win32 limits. Setup stops its matching old Node helper and tries the old helper's restore command before deleting legacy files. If Node.js 22+ is missing, install it temporarily from https://nodejs.org/en/download and rerun setup. If any limit cannot be restored, keep the recovery files and contact support; do not delete the backup or force the upgrade.

## Spotify takes a moment to respond after being restored

A working-set limit controls which memory pages may remain resident; restoring the old limit does not guarantee that every page is immediately resident again. Page faults can delay the interface. Disable automatic optimization in the dashboard if the trade-off is worse than the RAM saving on your system, and share the local log plus the restore-time measurements when reporting the issue.

## Uninstall stops because recovery failed

This is a deliberate safety stop. Close Spotify and retry uninstall. If the companion is missing but recovery records remain, reinstall the matching release so it can read the backup and restore the recorded settings. Do not manually delete working-set-backup.tsv, working-set-backup.previous, or legacy working-set-backup.json.

## Windows SmartScreen or antivirus warning

A new unsigned executable can show a warning even when its source is open. Verify the download is from the official repository and compare SHA-256. Never disable Defender/SmartScreen as an installation step. If you think a detection is a false positive, report the file hash and detection name on the project issue tracker.

## Logs

After uninstall, diagnostic logs that existed are copied to:

%LOCALAPPDATA%\\MemorySentry\\logs

The helper does not upload logs or metrics. Review the logs for personal file paths before attaching them to a public issue.
