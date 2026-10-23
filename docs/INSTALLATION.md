# Installation guide

**Supported operating systems: Windows 10 and Windows 11 desktop editions only (x64 desktop).**

Memory Sentry has two entry points. Both paths require the native Rust companion because a Spicetify Custom App cannot call Win32 working-set APIs directly.

## Path A — standalone installer

1. Open the official GitHub Releases page: https://github.com/yanlvl99/spicetify-memory-sentry/releases
2. Download the release named Memory Sentry Setup and its accompanying SHA-256 file.
3. Verify the downloaded setup executable against the checksum. A checksum confirms that the file matches the release asset; it does not establish the publisher's identity.
4. Run Setup as the same Windows user that runs Spotify and Spicetify. Do not use Run as administrator.
5. Read any preflight error. Setup checks Windows 10/11 and checks for Spicetify before changing installed files. It does not require Spotify to be manually closed.
6. Setup installs the companion, writes local settings, starts the local API, then runs `spicetify apply`. Spotify may restart automatically during apply.
7. Once Spotify returns, select Memory Sentry in the sidebar. The helper is also registered to start at login for the current user.

## Path B — Marketplace

1. Install Memory Sentry from the Spicetify Marketplace.
2. Open Memory Sentry inside Spotify.
3. When the helper is not connected, use Download official setup or Marketplace setup guide. Installing the Marketplace panel by itself cannot enable native memory control.
4. Download and verify the official Setup executable.
5. Run Setup as your normal user. Spicetify may restart Spotify during apply.
6. When Spotify returns, use Refresh to verify that the dashboard connects.

The Custom App does not download or execute native programs automatically. This is an intentional user-consent and security boundary.

## Upgrade from the Node.js preview

The Rust companion does not need a global Node.js installation for new installs. If a previous Node-based version has an outstanding working-set-backup.json, setup stops only the matching old Node helper, runs its restore command, verifies the exit code, and keeps recovery files if restoration fails. It may require Node.js 22+ temporarily for that migration. Never delete the backup manually to force an upgrade.

On upgrades, Setup asks the old companion to restore limits before replacing the previous folder. If recovery fails or a Memory Sentry process is still running, Setup stops and preserves recovery data. Setup starts the local API before calling `spicetify apply`, so the dashboard does not race the helper's startup.

## Uninstall

Use Windows Settings → Apps → Installed apps → Memory Sentry → Uninstall. The uninstaller runs a native pre-uninstall command without requiring Spotify to be manually closed; Spicetify apply may restart it. That command restores recorded working-set limits, removes the current-user startup entry and deregisters the Custom App. If restoration fails, the uninstaller stops before removing program files or recovery records.

Logs are preserved at %LOCALAPPDATA%\MemorySentry\logs when the application directory is removed. You can also run Uninstall.bat from the source/portable package, with the same recovery checks.

## Security and unsupported systems

The installer is per-user and should not request administrator privileges. It does not disable antivirus, SmartScreen, the firewall or Windows execution-policy protections. Unsigned setup files may still show reputation warnings; verify the source and SHA-256 instead of blindly bypassing warnings.

Supported: Windows 10 and Windows 11 desktop editions, x64.

Unsupported: Windows Server, Windows 7/8/8.1, macOS, Linux, and ARM64 Windows in this preview.

## Legacy/manual package

The source ZIP contains Install.bat, Uninstall.bat, installer/Install.ps1 and installer/Uninstall.ps1 for a per-user install without Inno Setup. Run the scripts from a complete ZIP whose root contains MemorySentry.exe and app/. The recommended route for most users is the standalone setup program from GitHub Releases.
