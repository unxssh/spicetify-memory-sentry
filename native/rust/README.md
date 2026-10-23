# Memory Sentry Rust companion (migration scaffold)

**Status: experimental; not a replacement for the supported Node.js helper.**

This directory starts the Rust migration with the testable adaptive policy and a Windows 10/11 desktop-edition gate. It deliberately does not change any other process's working-set limits yet.

## Why the port is staged

Memory Sentry must identify Spotify processes conservatively, protect audio-related processes, persist original limits before applying changes, recover after crashes, and expose a local-only authenticated API to the Spicetify dashboard. A native binary is not safe to ship until these behaviours have parity with the existing helper and pass Windows 10/11 runtime tests.

## Build and test

Install the stable Rust toolchain. From the repository root:

```powershell
cargo test --manifest-path native/rust/Cargo.toml --locked
cargo check --manifest-path native/rust/Cargo.toml --target x86_64-pc-windows-msvc --locked
```

On non-Windows systems, the executable refuses to run the monitoring function. On Windows it detects the client OS and explicitly exits without changing working-set limits. The `--self-test` and `--version` commands are safe and do not apply memory limits.

## Next milestones

See [../../docs/RUST-MIGRATION.md](../../docs/RUST-MIGRATION.md). The release installer must continue using the existing tested helper until the migration's acceptance checklist passes.
