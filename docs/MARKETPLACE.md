# Marketplace publishing and support model

Memory Sentry supports Windows 10 and Windows 11 desktop editions only (x64 desktop).

## Two installation paths

### A. Standalone setup

The official per-user setup program is published on:

https://github.com/yanlvl99/spicetify-memory-sentry/releases

The release needs the compiled Rust companion, Spicetify Custom App, setup/uninstall registration, GPL-3.0 license, privacy/security documentation, and SHA-256 files. A release must not be labelled stable before clean Windows 10 and Windows 11 desktop tests cover install, upgrade, audio continuity, working-set restoration and uninstall.

### B. Marketplace Custom App

Marketplace is the discovery route. It installs the dashboard, not an arbitrary native Windows program. If the companion is missing, the UI clearly explains the gap and offers links to the official releases and this installation guide. The user downloads and runs the standalone setup program themselves; the Custom App must not silently download or execute a helper.

The Rust companion calls native Win32 APIs outside the Spotify UI and therefore runs as a separate per-user process. It needs to bind only to loopback, require a random token, verify Spotify's Origin/Host, save original limits before any change, exclude audio-service processes and refuse removal when recovery is incomplete.

## Marketplace listing

1. The repository must be public.
2. Add the exact repository topic spicetify-apps.
3. Keep a valid root manifest.json, preview image and README.
4. Keep app/manifest.json for the Custom App runtime separate from Marketplace listing metadata.
5. Publish a real GitHub release with the official Setup executable and checksum before asking users to install the native companion.
6. Test the missing-helper screen by opening the Custom App before the native companion is installed.
7. Run clean install, upgrade and uninstall tests on both supported Windows desktop versions.

Official publishing guide: https://github.com/spicetify/marketplace/wiki/Publishing-to-Marketplace

Marketplace listing readiness is not the same as product release readiness. The setup program and Windows 10/11 integration validation are required before public launch.
