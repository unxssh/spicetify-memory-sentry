# Privacy

Memory Sentry is designed to operate locally.

## Data collected

No information is uploaded by Memory Sentry. There is no telemetry endpoint, analytics SDK, crash-reporting service, or remote logging service in this project.

The companion temporarily reads Windows process metadata needed to locate Spotify's process tree, estimate per-process CPU use, measure resident working sets, and verify process identity. Local dashboard metrics include process IDs, roles, working-set estimates, private-memory estimates, CPU estimates, page-fault counters, state transitions, adaptive policy decisions, and error messages.

## Local storage

Settings, a random local API token, a recovery file containing original working-set limits, and diagnostic logs are stored under `%LOCALAPPDATA%\SpicetifyMemorySentry`. Logs are capped/rotated by the companion, and the uninstaller preserves logs to aid troubleshooting. No Spotify account credentials, track names, playlist data, or listening history are intentionally read or stored.

## Local API

The helper binds only to `127.0.0.1`, checks the request host and Spotify HTTPS origin, and requires a random per-install bearer token. The API is not designed to be exposed to a network interface.

## Dependencies and installation

The installer retrieves the pinned Koffi dependency from the npm registry. Koffi uses native binaries to make Windows API calls. The source and installer are public so the behavior can be audited. The installer does not ask for administrator privileges and does not disable operating-system security controls.

## User control

Automatic optimization can be switched off in the dashboard. When disabled or when Spotify becomes visible, the companion attempts to restore saved original working-set limits. The package includes an uninstaller and recovery procedure. A forced process termination or system crash can interrupt cleanup, so original settings are persisted before applying changes and recovery is attempted on the next launch.
