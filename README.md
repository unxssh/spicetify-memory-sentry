# Memory Sentry for Spotify Desktop

**Adaptive, open-source working-set management for Windows and Spicetify.** Memory Sentry reduces Spotify's resident memory while its window is minimized or hidden, then restores the original Windows working-set limits when Spotify becomes visible again.

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

## Requirements

- Windows 10 or 11.
- Spotify Desktop with Spicetify CLI installed.
- Node.js 22 or newer, including npm. Get a supported release from [nodejs.org](https://nodejs.org/en/download).
- Internet access during setup to retrieve the pinned Koffi dependency from the npm registry.

## Install or update

1. Download the release ZIP from [GitHub Releases](https://github.com/yanlvl99/spicetify-memory-sentry/releases/latest).
2. Close Spotify completely.
3. Extract the ZIP. If Windows has marked the downloaded ZIP as blocked, open its Properties and review the publisher/source before deciding whether to unblock it.
4. Run `Install.bat` without administrator privileges.
5. Reopen Spotify and select **Memory Sentry** from the sidebar.

The installer places the Custom App under `%APPDATA%\spicetify\CustomApps\SpicetifyMemorySentry`, the companion under `%LOCALAPPDATA%\SpicetifyMemorySentry`, and a current-user startup launcher under the user's Startup folder. It stages dependencies before replacing an existing install and attempts to restore any saved limits first.

To uninstall, close Spotify and run `Uninstall.bat`. The uninstaller attempts to restore saved Windows limits before removing the companion. Logs are preserved for troubleshooting.

## Diagnostics

The dashboard shows the current Spotify working-set estimate, process CPU estimates, current adaptive ceilings, page-fault deltas, and adjustment counts. These diagnostics are local only. A page-fault count includes soft and hard faults and is not equivalent to disk reads. Summed process working sets can double-count shared pages. The time required to restore Windows limits is not the same as the time required for Spotify's UI to become responsive.

See [docs/BENCHMARKING.md](docs/BENCHMARKING.md) for a repeatable test plan.

## Open source, safety, and antivirus notices

- Source code and release packaging are public for inspection under GPL-3.0.
- No remote telemetry or analytics are implemented.
- The companion does not read playlists, track names, listening history, or Spotify credentials.
- The installer does not request elevation or disable Defender, SmartScreen, or other security controls.
- The companion must run separately because native process-memory calls cannot safely be provided by a regular Spicetify JavaScript app.
- **No unsigned first release can guarantee zero SmartScreen or antivirus warnings.** New download hashes and unknown publisher reputation may trigger warnings even for legitimate software. We publish release checksums and CI validation; signing can be added when a verifiable signing identity is available. Do not bypass security warnings unless you have independently verified the source and checksum.

## License

Memory Sentry is distributed under the GNU General Public License v3.0. See [LICENSE](LICENSE). Koffi is a separate third-party dependency under its own MIT license.
