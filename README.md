# Memory Sentry for Spotify Desktop

**Windows 10 and Windows 11 only. Adaptive, open-source working-set management for Spotify Desktop and Spicetify.** Memory Sentry reduces Spotify's resident memory while its window is minimized or hidden, then restores the original Windows working-set limits when Spotify becomes visible again.

> **Experimental software.** A lower resident working set can increase page faults and delay UI recovery. Back up important work, test against your own workload, and disable optimization if Spotify becomes unstable. Memory Sentry does not promise instant recovery or a specific RAM saving.

## How the adaptive policy works

Memory Sentry no longer exposes a manual per-process RAM cap. Instead, the companion maintains an independent ceiling for each eligible Spotify process:

- Role-based starting ceilings: main process 36 MB, GPU and renderer 28 MB, utility/helper 24 MB, crash handler 16 MB.
- If a process averages at least 10% of total logical CPU capacity for six seconds or longer, its ceiling may rise by 8 MB.
- If CPU remains at or below 3%, and the process stays at least 6 MB below its current ceiling for ten seconds, its ceiling may fall by 4 MB.
- Adjustments have an eight-second cooldown. The global safety range is 12–64 MB; each role has its own bounds. The main process keeps a 24 MB floor, while background renderers can shrink to 12 MB to balance RAM savings and window restoration.
- The dedicated Spotify audio-service process is always excluded.
- The policy runs only after the Spotify window has been minimized or hidden for the configured delay. Original native limits are restored when the window becomes visible.

CPU usage is estimated from consecutive Windows process snapshots and normalized by the number of logical processors. It is a heuristic, not a claim that CPU usage always means a process needs more memory. The adaptive policy is deliberately conservative and should be validated with real-world A/B tests.

## Why a separate companion process is required

A Spicetify Custom App runs JavaScript inside Spotify's UI and does not have direct access to the native Win32 APIs needed to adjust another process's working-set limits. The Windows companion uses Node.js plus Koffi to call those APIs, verifies the process creation identity before changing limits, and persists the original settings so they can be restored after failures or restarts.

The companion runs as the current user, does not request administrator privileges, and exposes its API only on `127.0.0.1`. Requests require a random per-install token, a Spotify HTTPS origin, and a local host header. The UI can open the official GitHub releases page when the companion is unavailable.

## Supported operating systems

Memory Sentry supports **Windows 10 and Windows 11 desktop editions only**. macOS, Linux, Windows 7/8/8.1, and Windows Server are not supported. The installer checks the OS before making changes.

## Choose your installation path

### Path A — standalone installer (recommended)

This is the simplest route for people who already know what Memory Sentry is.

1. Open [GitHub Releases](https://github.com/yanlvl99/spicetify-memory-sentry/releases).
2. Download the complete release ZIP and its SHA-256 checksum.
3. Verify that the checksum matches the downloaded archive.
4. Close Spotify and extract the ZIP.
5. Run `Install.bat` without administrator privileges and follow the prompts.
6. Reopen Spotify and confirm that Memory Sentry appears in the sidebar.

A complete installer release will bundle the supported companion and configure the dashboard. **Do not treat the Rust migration scaffold as a supported replacement yet.** Current 0.2.0 beta packages still use the Node.js companion and require Node.js 22+; the Rust port must pass Windows runtime and recovery tests before replacing it.

### Path B — install from Spicetify Marketplace

Marketplace is the discovery path for users browsing Custom Apps. It installs the dashboard, but it does not install arbitrary native Windows programs.

1. Install Memory Sentry from Marketplace like any other Custom App.
2. Open it in Spotify. If the companion is missing, the dashboard explains why and provides official download and setup-guide links.
3. Follow the official setup guide to obtain the complete release ZIP.
4. Close Spotify and run `Install.bat` from the extracted ZIP.
5. Reopen Spotify. Use **Refresh** to confirm that the local companion has connected.

Installing only the Marketplace Custom App is **not enough** for native memory optimization. Until an official release is published, the release page may not contain a complete downloadable package; do not advertise the Marketplace listing as ready for public users before that release is available and tested.

## Requirements for the current 0.2.0 beta

- Windows 10 or Windows 11 desktop edition.
- Spotify Desktop with Spicetify CLI installed.
- Node.js 22 or newer, including npm, for the current JavaScript companion. Get it from [nodejs.org](https://nodejs.org/en/download).
- Internet access during setup to retrieve the pinned Koffi dependency from the npm registry.

## Current install/update process

1. Close Spotify completely.
2. Extract the project/release ZIP.
3. Run `Install.bat` without administrator privileges.
4. Reopen Spotify and select **Memory Sentry** from the sidebar.

The installer places the Custom App under `%APPDATA%\spicetify\CustomApps\SpicetifyMemorySentry`, the companion under `%LOCALAPPDATA%\SpicetifyMemorySentry`, and a current-user startup launcher in the Startup folder. It stages dependencies before replacing an existing install and attempts to restore saved limits first.

To uninstall, close Spotify and run `Uninstall.bat`. The uninstaller attempts to restore saved Windows limits before removing the companion. Logs are preserved for troubleshooting.

## Diagnostics

The dashboard shows the current Spotify working-set estimate, process CPU estimates, current adaptive ceilings, page-fault deltas, and adjustment counts. These diagnostics are local only. A page-fault count includes soft and hard faults and is not equivalent to disk reads. Summed process working sets can double-count shared pages. The time required to restore Windows limits is not the same as the time required for Spotify's UI to become responsive.

See [docs/BENCHMARKING.md](docs/BENCHMARKING.md) for a repeatable test plan.

## Rust migration status

A standard-library Rust policy/runtime scaffold is being prepared under `native/rust`. It is not yet the active memory-control helper. The existing Node.js helper remains the only supported implementation until the Rust version has equivalent process discovery, audio-process protection, crash-safe restoration, a secured local API, and Windows 10/11 integration tests.
## Open source, safety, and antivirus notices

- Source code and release packaging are public for inspection under GPL-3.0.
- No remote telemetry or analytics are implemented.
- The companion does not read playlists, track names, listening history, or Spotify credentials.
- The installer does not request elevation or disable Defender, SmartScreen, or other security controls.
- The companion must run separately because native process-memory calls cannot safely be provided by a regular Spicetify JavaScript app.
- **No unsigned first release can guarantee zero SmartScreen or antivirus warnings.** New download hashes and unknown publisher reputation may trigger warnings even for legitimate software. We publish release checksums and CI validation; signing can be added when a verifiable signing identity is available. Do not bypass security warnings unless you have independently verified the source and checksum.

## License

Memory Sentry is distributed under the GNU General Public License v3.0. See [LICENSE](LICENSE). Koffi is a separate third-party dependency under its own MIT license.
