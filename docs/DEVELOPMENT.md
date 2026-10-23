# Development workflow

## Current supported implementation

The 0.2.0 beta uses the Node.js companion. Do not replace its installer payload with the Rust scaffold until [the Rust migration gates](RUST-MIGRATION.md) pass. The Rust binary currently only checks its mode/OS and runs a platform-independent policy; it does not adjust Spotify's working sets.

## JavaScript package validation

Use Node.js 22 or newer. From the repository root:

```powershell
node --check app/index.js
node --check helper/helper.js
node --check helper/adaptive-policy.js
node tests/validate-package.js
```

## Rust policy and target validation

Install stable Rust, then run:

```powershell
cargo test --manifest-path native/rust/Cargo.toml --locked
cargo check --manifest-path native/rust/Cargo.toml --target x86_64-pc-windows-msvc --locked
```

The policy tests run on any operating system. The Windows target check verifies that the Windows-specific OS gate builds; it is not an integration test for native memory control.

## Architecture

- `app/index.js`: Spicetify Custom App dashboard, automatic English/Brazilian Portuguese localization, companion status, and help links.
- `helper/helper.js`: currently supported Node.js implementation with process discovery, local API, working-set management, backup/recovery, and adaptive sampling.
- `helper/adaptive-policy.js`: current JavaScript adaptive policy and tests.
- `native/rust/src/lib.rs`: platform-independent Rust adaptive policy, kept in parity with JavaScript.
- `native/rust/src/platform/windows.rs`: Windows 10/11 desktop-edition gate for the Rust prototype.
- `installer/`: current-user installer/uninstaller. It still installs the Node.js helper in 0.2.0.
- `docs/INSTALLATION.md`: standalone and Marketplace installation paths.
- `docs/BENCHMARKING.md`: repeatable memory/latency A/B test.
- `docs/RUST-MIGRATION.md`: migration plan and release gate.

## Publishing

Commit messages should use English Conventional Commit style. Run all local checks before pushing:

```powershell
node tests/validate-package.js
cargo test --manifest-path native/rust/Cargo.toml --locked
git status --short
git diff --check
```

Then review the exact staged diff, create a signed commit, and push through your authenticated Git client. Never include local publishing scripts, release ZIPs, bundles, checksums, credentials, or machine-specific logs in a source commit. The GitHub workflow must pass before a release is created.
