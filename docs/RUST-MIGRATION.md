# Rust companion migration and release gate

## Current preview status

The Rust source now contains an adaptive policy, Win32 process discovery and working-set calls, a loopback-only dashboard API, a per-install token, Windows 10/11 validation, legacy recovery hooks, per-user startup, and a recovery-aware uninstall command. It is wired for CI build testing, but it has not yet had end-to-end testing with a real Spotify installation on Windows 10 and 11.

The Rust helper is the intended native companion for the preview installer. It uses no third-party Rust crates in the current core, so there is no global Node.js/Koffi requirement for new installs. Legacy Node recovery is retained to help previous users restore old limits safely.

## Important safety model

1. The dedicated Spotify audio-service process is excluded from working-set changes.
2. Every native memory mutation verifies the target process creation timestamp before changing or restoring limits.
3. Original working-set limits are written to recovery storage before an initial cap is applied.
4. Recovery records survive failed restoration and block upgrade/uninstall when the running helper or recovery state cannot be verified.
5. The helper API binds only to 127.0.0.1, requires a random token and checks both the Host header and Spotify HTTPS Origin.
6. The Custom App itself does not download or execute a native helper.
7. Setup is per-user and does not request elevation or turn off Windows security tools.
8. Logs stay local and are preserved outside the install directory on uninstall.

## Release milestones

- [x] Port the adaptive decision policy with unit tests.
- [x] Add Win32 working-set, window-state, process-identity and token primitives.
- [x] Add a Rust runtime implementation matching the dashboard API.
- [x] Add setup/uninstall registration and legacy Node recovery workflow.
- [x] Add CI policy tests and a Windows x64 compile/build job.
- [ ] Verify Inno Setup compiles the per-user setup executable in CI.
- [ ] Run the setup binary's safe CLI checks on the Windows runner and package the release artifacts.
- [ ] Test on a real Windows 10 desktop with Spotify and Spicetify installed.
- [ ] Test on a real Windows 11 desktop with Spotify and Spicetify installed.
- [ ] Measure audio continuity, RAM reduction, UI restore latency, failed process operations, restart recovery and uninstall.
- [ ] Verify the Marketplace missing-companion screen and both installation paths.
- [ ] Add the spicetify-apps topic and publish a release before submitting the listing for public discovery.

## Why the MSI is not the first installer

The current setup uses Inno Setup as a per-user EXE installer. It supports custom pre-install and pre-uninstall recovery checks without requiring Windows Installer custom actions or administrator privileges. An MSI can be considered later, after the per-user registration and rollback flow is validated; making an MSI before that would add packaging complexity without improving the memory-control engine.

## Antivirus and signing

Rust does not automatically prevent SmartScreen or antivirus warnings. The preview is unsigned and can receive reputation-based warnings. Keep source and build workflows public, publish SHA-256 files, never disable antivirus, and investigate an open-source signing program only after checking its current eligibility and trust model.
