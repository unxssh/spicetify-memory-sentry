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

## GitHub publishing

Use your normal authenticated Git client. Do not commit a local publishing helper script; repository credentials and publishing commands should remain outside the packaged application.

For a new local checkout:

```powershell
git clone https://github.com/yanlvl99/spicetify-memory-sentry.git
cd spicetify-memory-sentry
git status --short
```

For the existing repository, verify the local-only helper is ignored and not staged:

```powershell
git check-ignore -v PUSH-TO-GITHUB.bat
git status --short
```

If the helper was tracked previously, remove it from the Git index while keeping the local copy, and commit the updated ignore rules and test suite:

```powershell
git rm --cached --ignore-unmatch PUSH-TO-GITHUB.bat
git add .gitignore tests/validate-package.js docs/DEVELOPMENT.md
git commit -m "chore: exclude local publishing helper and update CI checks"
```

Configure the remote only if needed, then push explicitly:

```powershell
git remote -v
git push -u origin main
```

Authenticate with Git Credential Manager or GitHub CLI when prompted. Never store tokens in scripts, bypass authentication, or commit machine-specific publishing helpers. Check the GitHub Actions workflow results before creating a release tag.
