# Troubleshooting

Memory Sentry supports Windows 10 and Windows 11 desktop editions only. These steps apply to the experimental Rust companion.

## Dashboard shows "connection unavailable"

The dashboard shows the detailed connection error. The launcher creates `%LOCALAPPDATA%\SpicetifyMemorySentry\logs\startup.log` before reading settings, so early configuration failures should now be recorded too.

If the log is missing, open PowerShell and run:

```powershell
& "$env:LOCALAPPDATA\SpicetifyMemorySentry\MemorySentry.exe" --launch
Get-Content "$env:LOCALAPPDATA\SpicetifyMemorySentry\logs\startup.log" -Tail 40
```

The first command prints a direct error if the launcher cannot initialize; the second shows local startup diagnostics if the file was created. If the executable itself is missing, repair the installation using the official setup executable. For runtime events after the API starts, inspect `helper.log` in the same `logs` folder. These logs stay on the PC and are not uploaded. A "port already in use" error means another process is listening on port 38472. An "Invalid local token" error indicates that the dashboard and companion were configured with different tokens; rerun the official installer to configure both together.
## Uninstall while Spotify is open

The uninstaller asks the native companion to restore the original Windows working-set limits and exit, removes its current-user startup registration, then removes the Custom App from Spicetify and runs \`spicetify apply\`. That lets Spicetify refresh Spotify as part of removing the app; you should not need to close Spotify manually for a normal uninstall. If the companion cannot confirm recovery or its process will not exit, uninstall stops and preserves the recovery files instead of deleting them.

## Setup says Spotify is running

For a new installation or upgrade, setup still requires Spotify to be closed while files are replaced. This check is separate from uninstall.

## Setup says Spicetify was not found

Install Spicetify CLI for the same Windows user account that runs Spotify. Reopen your terminal/session so PATH changes apply, then retry Setup. Setup does not silently download and execute Spicetify on the user's behalf.

## Setup refuses a legacy migration

A previous version may have working-set-backup.json containing original Win32 limits. Setup stops its matching old Node helper and tries the old helper's restore command before deleting legacy files. If Node.js 22+ is missing, install it temporarily from https://nodejs.org/en/download and rerun setup. If any limit cannot be restored, keep the recovery files and contact support; do not delete the backup or force the upgrade.

## Spotify takes a moment to respond after being restored

A working-set limit controls which memory pages may remain resident; restoring the old limit does not guarantee that every page is immediately resident again. Page faults can delay the interface. Disable automatic optimization in the dashboard if the trade-off is worse than the RAM saving on your system, and share the local log plus the restore-time measurements when reporting the issue.

## Uninstall stops because recovery failed

This is a deliberate safety stop. Retry uninstall after reviewing the error. If the companion is missing but recovery records remain, reinstall the matching release so it can read the backup and restore the recorded settings. Do not manually delete working-set-backup.tsv, working-set-backup.previous, or legacy working-set-backup.json.

## Windows SmartScreen or antivirus warning

A new unsigned executable can show a warning even when its source is open. Verify the download is from the official repository and compare SHA-256. Never disable Defender/SmartScreen as an installation step. If you think a detection is a false positive, report the file hash and detection name on the project issue tracker.

## Logs

After uninstall, diagnostic logs that existed are copied to:

%LOCALAPPDATA%\\MemorySentry\\logs

The helper does not upload logs or metrics. Review the logs for personal file paths before attaching them to a public issue.
