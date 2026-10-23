# Installation guide

**Supported operating systems: Windows 10 and Windows 11 desktop editions only.**

Memory Sentry has two entry points. Both paths ultimately require the Windows companion because a Spicetify Custom App cannot call the Win32 working-set APIs directly.

## Path A: standalone installer

For people who already know Memory Sentry and want the complete package:

1. Open the [official GitHub Releases page](https://github.com/yanlvl99/spicetify-memory-sentry/releases).
2. Download the complete ZIP and the adjacent SHA-256 checksum.
3. Verify the downloaded file against the checksum. A checksum validates file integrity, not the publisher's identity.
4. Close Spotify completely and extract the ZIP to a normal user-writable folder.
5. Run `Install.bat`; administrator privileges should not be required.
6. Read the setup output. If a prerequisite is missing, install it from its official vendor and restart the installer.
7. Open Spotify and confirm that Memory Sentry appears in the sidebar and reports a connected companion.
8. If the UI still reports no companion, use the setup guide and diagnostic logs. Do not repeatedly reinstall over an active Spotify process.

## Path B: Marketplace

For people who discover Memory Sentry in the Spicetify Marketplace:

1. Install the Custom App through Marketplace.
2. Open Memory Sentry inside Spotify.
3. If the companion is missing, the page explains that Marketplace installed only the UI. Select **Open official releases** to find the complete package or **Marketplace setup guide** to read these instructions.
4. Download the release ZIP, verify its checksum, close Spotify, and run `Install.bat`.
5. Reopen Spotify and select **Refresh** in Memory Sentry.

The app never silently installs or executes a native companion. The user remains in control of the download and installer.

## Current beta prerequisites

The 0.2.0 beta still uses a Node.js helper and requires Node.js 22+ with npm. The installer should direct users to https://nodejs.org/en/download if either executable is missing. Rust migration work is separate and experimental; do not replace the working Node helper until the Rust implementation passes parity, recovery, and Windows runtime tests.

## Supported and unsupported platforms

Supported: Windows 10 and Windows 11 desktop editions.

Not supported: macOS, Linux, Windows 7/8/8.1, Windows Server, or other platforms. The installer checks the operating system before making changes.

## Troubleshooting and removal

- If Spotify is open, close it completely before installing or updating.
- If the dashboard cannot connect, verify that the companion is running and inspect its local log file.
- If Windows shows an unsigned-app warning, verify the download source and SHA-256 and read the security documentation. Do not disable antivirus or follow instructions that bypass security controls.
- To remove the app, close Spotify and run `Uninstall.bat`. The uninstaller must attempt to restore saved working-set limits before deleting recovery data.
