# Release checklist

Do not call the release stable until all required real-desktop tests are complete.

## Build and package

- [ ] cargo test for native/rust/Cargo.toml passes.
- [ ] Windows x64 build succeeds for x86_64-pc-windows-msvc.
- [ ] Inno Setup compiles the per-user setup executable in CI.
- [ ] Release ZIP, setup EXE and each SHA-256 file are uploaded and independently verified.
- [ ] Setup version, README and changelog agree.
- [ ] Marketplace manifest and preview exist, root README is valid and repository topic spicetify-apps is set.
- [ ] No Node.js requirement remains for new Rust installs. Any remaining Node dependency is clearly documented as legacy recovery only.

## Required Windows 10 and Windows 11 desktop validation

- [ ] Install on a clean user account with Spotify Desktop and Spicetify already installed.
- [ ] Verify setup rejects unsupported OS editions before modifying files.
- [ ] Confirm setup is per-user, does not ask for admin and does not alter antivirus/SmartScreen/firewall settings.
- [ ] Confirm original process limits are durably saved before each initial cap.
- [ ] Confirm audio-service processes remain excluded.
- [ ] Confirm high sustained CPU raises the per-process ceiling and idle/headroom lowers it without oscillation.
- [ ] Confirm limits are restored on focus return, disable, shutdown, restart recovery and uninstall.
- [ ] Confirm an unresponsive recovery path leaves backups and blocks file removal.
- [ ] Test legacy Node migration with and without Node.js 22+ and with successful and failed recovery.
- [ ] Run at least five restore-to-interaction samples for the same workload and compare medians.
- [ ] Verify English/Portuguese UI language selection.
- [ ] Verify no network telemetry is emitted by the helper.
- [ ] Verify uninstall removes only the Memory Sentry Custom App and install directory while preserving logs outside the app folder.

## Public release

- [ ] CI passes on the exact release commit.
- [ ] Setup EXE and SHA-256 files are attached to the correct release.
- [ ] Use a prerelease flag for preview tags (for example, v0.3.0-pre.2).
- [ ] Never state the release has no antivirus warnings; the current executable is unsigned.
- [ ] Submit to the Spicetify Marketplace only after the companion installer exists and both install paths have been tested.
