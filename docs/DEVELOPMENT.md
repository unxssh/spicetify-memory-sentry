# Development workflow

## Local validation

Use Node.js 22 or newer. From the repository root, run:

```powershell
node --check app/index.js
node --check helper/helper.js
node --check helper/adaptive-policy.js
node tests/validate-package.js
```

The policy tests run on any OS because `helper/adaptive-policy.js` contains only pure decision logic. The Windows companion itself is intentionally guarded to Windows and calls native APIs through Koffi. Static tests are not a substitute for a real Windows integration test.

## Architecture

- `app/index.js`: Spicetify Custom App dashboard, automatic English/Brazilian Portuguese localization, local diagnostics, and prerequisite links.
- `helper/helper.js`: Windows process discovery, local API, native working-set control, recovery backups, and CPU-snapshot sampling.
- `helper/adaptive-policy.js`: platform-independent adaptive ceiling policy and pure unit-testable CPU estimation.
- `installer/`: current-user installer and uninstaller.
- `docs/BENCHMARKING.md`: repeatable memory/latency A/B test.
- `docs/RELEASE_CHECKLIST.md`: Windows runtime and publication gates.

## GitHub publishing from the prepared bundle

1. Clone `MemorySentry-0.2.0.bundle` into a local folder using `git clone MemorySentry-0.2.0.bundle MemorySentry`.
2. Run `PUSH-TO-GITHUB.bat` from that clone. It sets the remote to the project repository and runs `git push -u origin main`.
3. Authenticate with Git Credential Manager or GitHub CLI when prompted. The script does not store credentials or bypass authentication.
4. Check the GitHub Actions workflow results before creating a release tag.

The GitHub connector may be able to read repository metadata while write endpoints remain unavailable. In that case, pushing through the user's authenticated Git client is the intended fallback.
