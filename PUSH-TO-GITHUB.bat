@echo off
setlocal
cd /d "%~dp0"
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo This script must be run from a Git clone, not a plain source ZIP.
  echo Clone the provided .bundle file first, then copy this script into that clone if needed.
  pause
  exit /b 2
)
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  git remote add origin https://github.com/yanlvl99/spicetify-memory-sentry.git
) else (
  git remote set-url origin https://github.com/yanlvl99/spicetify-memory-sentry.git
)
echo Pushing the prepared main branch to the empty Memory Sentry repository.
echo GitHub authentication must already be configured with Git Credential Manager or GitHub CLI.
git push -u origin main
if errorlevel 1 (
  echo Push failed. Check GitHub authentication, repository access, and whether main is still empty.
  pause
  exit /b 1
)
echo Push completed. Check the GitHub Actions tab for validation results.
pause
