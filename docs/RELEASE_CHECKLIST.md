# Release checklist

Do not publish a stable release until the following checks are complete.

## Required Windows validation

- [ ] Install on a clean Windows 10/11 account with Spotify and Spicetify already installed.
- [ ] Confirm Node.js 22+ and npm are detected; confirm missing prerequisites lead to official project pages.
- [ ] Confirm the installer does not request elevation or change antivirus, SmartScreen, firewall, or execution-policy settings.
- [ ] Confirm the local API binds only to `127.0.0.1` and rejects missing/wrong tokens and non-Spotify origins.
- [ ] Confirm each target's original working-set limits are persisted before modification.
- [ ] Confirm the dedicated audio-service process is always excluded.
- [ ] Confirm adaptive CPU estimates and ceiling adjustments under sustained high CPU and idle workloads.
- [ ] Confirm limits are restored on focus return, automatic optimization disable, normal shutdown, and uninstallation.
- [ ] Test recovery after force-closing the helper and after restarting Windows.
- [ ] Run at least five restore-to-interaction samples per workload and compare medians.
- [ ] Confirm the UI switches between English and Brazilian Portuguese based on `navigator.language`.
- [ ] Confirm no network telemetry is emitted by the helper.

## Publishing

1. Ensure the GitHub Actions validation workflow passes on the final commit.
2. Add the `spicetify-apps` topic to the public repository.
3. Review the current Spicetify Marketplace Custom App publishing rules and submit the listing only after the native-companion requirement is clear in the README and listing metadata.
4. Publish a version tag such as `v0.2.0` only after Windows runtime testing. The release workflow packages the source installer and publishes a SHA-256 checksum.
5. Verify the downloaded ZIP against its checksum. A checksum validates file integrity but does not prove publisher identity.
6. Add a trusted code-signing certificate and provenance attestations when the project has the required signing identity and CI secrets. Never disable or bypass Windows security controls to suppress warnings.
