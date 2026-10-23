# Memory Sentry Rust companion

**Status: experimental.** The Windows x64 companion implements the local API, adaptive working-set policy, process-identity checks, audio-service exclusions, recovery persistence, and per-user startup/uninstall flow. It is designed to substantially reduce Spotify's resident working set while minimized or hidden on supported Windows 10/11 x64 desktop PCs; actual savings vary. On very low-end PCs, a temporary black screen may appear during restore without necessarily indicating a page reload if the previous UI state returns. The project is not considered stable until the broader Windows 10/11 desktop test matrix passes.

## Build and test

Install the stable Rust toolchain. From the repository root:

\`\`\`powershell
cargo test --manifest-path native/rust/Cargo.toml --locked
cargo build --release --manifest-path native/rust/Cargo.toml --target x86_64-pc-windows-msvc --locked
\`\`\`

The \`--version\` and \`--self-test\` commands do not change process memory. The launcher verifies the authenticated local status endpoint before returning and records early monitor startup output in \`%LOCALAPPDATA%\\SpicetifyMemorySentry\\logs\\startup.log\`.

Uninstall attempts recovery while Spotify is running: it requests a graceful companion shutdown, waits for the process to exit, unregisters startup, then unregisters the Custom App and applies the Spicetify configuration. It preserves recovery data and stops removal when restoration cannot be confirmed.

The runtime still requires real-desktop validation for playback continuity, startup/recovery behavior, and the time it takes Spotify's UI to become responsive after restore. See [../../docs/RUST-MIGRATION.md](../../docs/RUST-MIGRATION.md) and [../../docs/RELEASE_CHECKLIST.md](../../docs/RELEASE_CHECKLIST.md).
