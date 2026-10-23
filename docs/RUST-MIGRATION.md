# Rust companion migration plan

## Why Rust

A native Rust helper can remove the global Node.js prerequisite, reduce runtime packaging complexity, and use Win32 APIs directly. It does not inherently avoid SmartScreen or antivirus warnings. The first Rust files in this branch are a **scaffold**, not an operational replacement for the 0.2.0 Node.js helper.

## Current scaffold

- Standard-library-only adaptive policy port with unit tests.
- Windows 10/11 client-edition detection through RtlGetVersion; Windows Server editions are rejected.
- Safe CLI self-test/version commands.
- CI test on Linux and Windows-target compile check.
- No process enumeration, HTTP API, or working-set changes are enabled in the Rust binary yet.

## Migration milestones

1. **Policy parity.** Keep thresholds, per-role bounds, cooldown logic, and audio exclusion covered by unit tests. Add property tests for invalid samples and cap boundaries.
2. **Native process discovery.** Enumerate Spotify process identities without a blocking shell command. Treat unknown process role or command line as ineligible, never guess.
3. **Process classification.** Confirm parent/child, command line, image path, and process creation identity. Protect audio-service processes and test against current Spotify process layouts.
4. **Working-set operations.** Implement GetProcessWorkingSetSizeEx/SetProcessWorkingSetSizeEx with strict access rights. Save original limits and identity atomically before modifying anything. Never apply a backup to a reused PID.
5. **Recovery.** Restore limits on foreground/visible window transitions, controlled shutdown, startup recovery, uninstall, and all partial-error paths. Preserve recovery state whenever restoration fails.
6. **Local API.** Bind only to 127.0.0.1, require a per-install random token, validate Origin and Host, cap request sizes, and expose only the required status/config/action endpoints.
7. **Installer migration.** Bundle the compiled helper in the full release ZIP, remove the Node.js and npm requirement only after parity is verified, and keep Marketplace instructions explicit that the Custom App alone cannot install it.
8. **Windows validation.** Build and test on actual Windows 10 and Windows 11 machines. Measure working set, private committed bytes, page faults, audio continuity, restore latency, installer rollback, upgrades, and uninstall. Use several Spotify/game/browser workloads.
9. **Release cutover.** Update the installer, dashboard status text, README, Marketplace metadata, and release checksum flow together. Keep a fallback build for the old helper until a stable Rust release has survived real-world use.

## Release gate

Do not make the Rust binary the installer default unless all of these are true:

- Windows 10 and Windows 11 runtime integration tests pass.
- Audio-service processes are excluded by verified process classification.
- Process identity is revalidated immediately before every memory operation.
- Original limits survive helper crash/restart and failed updates.
- The dashboard's API works with the Rust helper and remains loopback-only.
- The installer does not require global Node.js/npm or use ExecutionPolicy bypass.
- The user can uninstall while preserving recovery state when an operation fails.
- README, privacy, security, changelog, and Marketplace description match actual behaviour.

## Code signing and SmartScreen

The binary remains open source under GPL-3.0. Unsigned builds can still trigger SmartScreen, and signed builds can also warn until publisher/file reputation accumulates. Do not use self-signed certificates for public trust, disable Windows security, or promise that Rust avoids detections. Investigate reputable open-source signing programs (such as SignPath Foundation) only after verifying current eligibility and project requirements.
