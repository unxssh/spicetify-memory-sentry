# Changelog

## Unreleased

## 0.3.1 — Companion startup diagnostics (experimental)

- Make the installer launch the native companion automatically instead of relying on an optional post-install checkbox.
- Verify the authenticated local status API before the launcher reports success.
- Capture detached monitor startup errors in a local startup log.
- Show specific HTTP/API failure details in the dashboard instead of hiding them behind a generic connection message.
- Keep the release experimental until real Windows 10/11 audio, recovery, and restore-latency tests are complete.

## 0.3.0 — Native Windows companion (experimental)

- Add a native Rust companion and per-user Inno Setup installer for Windows 10/11 x64.
- Add guarded install, upgrade, recovery and uninstall flows that preserve recovery data if limits cannot be restored safely.
- Build a Windows Setup EXE and portable x64 ZIP with SHA-256 checksums in GitHub Actions.
- Keep adaptive per-process working-set policy, audio-service exclusions, loopback-only dashboard API and no-telemetry behavior.
- Align native runtime and Cargo lockfile versions with 0.3.0, and derive validation package versions from Cargo metadata.
- Publish as an experimental prerelease: the complete real-desktop Windows 10/11 behavior and restore-latency test matrix remains outstanding.

## 0.2.0 — Adaptive policy preview

- Replaced the user-selected fixed per-process cap with a role-based adaptive policy.
- Raised a process ceiling by 8 MB after sustained CPU usage at or above 10% of one logical processor for six seconds.
- Lowered a ceiling by 4 MB after sustained CPU usage at or below 3% and at least 6 MB of working-set headroom for ten seconds.
- Added hysteresis, per-role bounds, and an adjustment cooldown to prevent rapid oscillation.
- Added local CPU estimates and per-process adaptive ceilings to the dashboard.
- Added automatic English/Portuguese (Brazil) UI localization based on the system/browser language.
- Added a GitHub Releases action when the Windows companion cannot be reached.
- Switched the project license to GPL-3.0 to require redistributions of covered derivative works to retain the copyleft terms.
- Kept a 24 MB minimum ceiling for the main process while allowing low-activity background renderers to shrink to 12 MB, balancing savings with window restoration.
- Added adaptive policy unit tests and release checksum workflow.
- Prevented new limits from being applied using stale process snapshots after discovery failures, and throttled retries for inaccessible targets.
- Clarified the unsigned-installer/SmartScreen limitations and the reason for the separate native companion.

## 0.1.4

- Reduced window-state polling to 100 ms and moved recurring process discovery off the synchronous focus path.
- Added process-creation identity checks, page-fault metrics, and restore-operation timing.
