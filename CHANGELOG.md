# Changelog

## Unreleased

- Clarify standalone and Marketplace install paths, supported Windows versions, and native companion requirements.
- Add the first Rust migration scaffold and dedicated cross-platform policy tests.



## 0.2.0 — Adaptive policy preview

- Replaced the user-selected fixed per-process cap with a role-based adaptive policy.
- Raised a process ceiling by 8 MB after sustained CPU usage at or above 10% of total logical CPU capacity for six seconds.
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
