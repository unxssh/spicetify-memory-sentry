# Memory Sentry for Spotify Desktop

**Windows 10 and Windows 11 desktop editions only.** Memory Sentry is an experimental open-source companion for Spotify Desktop and Spicetify. When Spotify is minimized or hidden, it adaptively changes eligible child-process working-set ceilings, protects audio-service processes, and attempts to restore original limits when Spotify becomes visible.

> **0.3.0 experimental release — use cautiously.** Working-set limits can cause extra page faults and delay Spotify's UI recovery. This project is not a substitute for Windows memory management and does not guarantee a specific RAM saving. CI build and policy tests pass, but the full real-desktop Windows 10/11 audio, recovery, and restore-latency test matrix remains incomplete; do not treat this build as stable.

## Choose your installation path

### Path A — standalone installer (recommended)

1. Open the [official GitHub Releases page](https://github.com/yanlvl99/spicetify-memory-sentry/releases).
2. Download the Memory Sentry Setup executable and its SHA-256 checksum from the release assets.
3. Verify the checksum before running the setup program.
4. Close Spotify completely and run Setup as your normal Windows user. Do not run it as Administrator.
5. Follow the installer prompts. It checks Windows and Spicetify, installs the native companion, registers the Custom App and configures current-user startup.
6. Reopen Spotify and select Memory Sentry from the sidebar.

The Inno Setup installer is per-user and does not require a machine-wide MSI installation. A signed binary is not available yet, so Windows SmartScreen or antivirus may still show a reputation warning. A checksum verifies file integrity; it does not prove the publisher's identity.

### Path B — Spicetify Marketplace

1. Install the Custom App from Marketplace.
2. Open it inside Spotify.
3. If the companion is missing, the page explains that Marketplace installs the dashboard only and offers the official releases page and a setup guide.
4. Download the complete official setup program, close Spotify and run the installer.
5. Reopen Spotify and select Memory Sentry from the sidebar. Use Refresh to confirm that the native companion connected.

Installing only the Marketplace Custom App does not enable native memory optimization. A Custom App cannot silently install or execute an arbitrary Windows program, so the user deliberately downloads and runs the signed-off package.

## What the adaptive policy does

The current policy keeps an individual working-set ceiling for each eligible Spotify process:

- Starting ceilings: main process 36 MB; GPU and renderer 28 MB; utility/helper 24 MB; crash handler 16 MB.
- If one process uses at least 10% of one logical processor for six seconds, its ceiling can increase by 8 MB.
- If CPU remains at or below 3% and the working set stays at least 6 MB below its ceiling for ten seconds, the ceiling can decrease by 4 MB.
- Changes have an eight-second cooldown. The global policy range is 12–64 MB, with a 24 MB floor for the main process and lower floors for background processes.
- Audio-service processes are excluded. The policy runs after the configured hide/minimize delay. The helper saves original Windows limits before changing them and attempts to restore them when Spotify becomes visible.

CPU is estimated from process-time deltas and expressed as a percentage of one logical processor, capped at 100% per process. High CPU is only a heuristic; it does not prove that a process needs more memory. Working-set MB is resident RAM, not private committed memory, and summed working sets can double-count shared pages.

## Requirements

- Windows 10 or Windows 11 desktop edition, x64.
- Spotify Desktop and Spicetify CLI installed for the same Windows user.
- The official setup program contains the Rust native companion. A global Node.js installation is not required for new installations.
- When migrating a legacy Node.js installation with an outstanding recovery file, setup may request Node.js 22+ temporarily to run the old helper's restore command. If legacy recovery cannot be verified, setup stops and preserves the backup instead of deleting it.

macOS, Linux, Windows 7/8/8.1, Windows Server and ARM64 Windows are not supported by this release.

## Installed components and safety

- Custom App: %APPDATA%\spicetify\CustomApps\SpicetifyMemorySentry
- Native companion, settings and recovery state: %LOCALAPPDATA%\SpicetifyMemorySentry
- User startup registration: HKCU\Software\Microsoft\Windows\CurrentVersion\Run
- Logs: %LOCALAPPDATA%\MemorySentry\logs after uninstall

The companion runs as a separate per-user process under the current Windows user, exposes its dashboard API only on 127.0.0.1, requires a random per-install token, validates the Spotify HTTPS origin and loopback Host header, and does not upload telemetry. It checks the process creation timestamp before changing or restoring limits, persists recovery data before applying a cap, and stops upgrade/uninstall if a limit cannot be safely restored.

## Upgrade and uninstall

Close Spotify before updating or uninstalling. Setup attempts to restore the old helper's limits before replacing it, stages new files, and rolls back to the previous file set if registration fails. Windows Settings → Apps → Installed apps → Memory Sentry → Uninstall runs a pre-uninstall recovery check. If recovery fails or recovery records exist while the executable is missing, uninstallation stops and preserves data. Do not manually delete recovery files to bypass an error.

## Build from source

Install the stable Rust toolchain and Inno Setup 6. From the repository root, run cargo test with manifest path native/rust/Cargo.toml and --locked, then cargo build --release for target x86_64-pc-windows-msvc. A complete setup also needs the Custom App and docs staged as described in installer/inno/MemorySentry.iss. GitHub Actions builds the setup program, source/package ZIP and SHA-256 files. CI compilation is not the same as an actual Spotify/audio/restore test on a Windows 10/11 desktop.

## Open source, license and antivirus notices

Source and release packaging are public under GPL-3.0. The helper emits no remote telemetry and does not read playlists, track names, listening history or Spotify credentials. The installer does not disable Defender, SmartScreen, the firewall or execution-policy controls.

**No unsigned release can guarantee zero SmartScreen or antivirus warnings.** A new Rust executable can still trigger warnings due to publisher/file reputation. Do not bypass security warnings blindly. Verify the download source and SHA-256, inspect the open source, and report suspected false positives with the specific file hash.

See PRIVACY.md, SECURITY.md, docs/INSTALLATION.md, docs/TROUBLESHOOTING.md and docs/RUST-MIGRATION.md.
