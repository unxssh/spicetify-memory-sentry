# Marketplace publishing and support model

Memory Sentry supports **Windows 10 and Windows 11 desktop editions only**.

## Two supported discovery paths

### A. Standalone package

The complete installer is distributed through the GitHub Releases page:

https://github.com/yanlvl99/spicetify-memory-sentry/releases

The release ZIP must include the Custom App, the supported native companion, installer/uninstaller, license, privacy/security documentation, and a SHA-256 checksum. A release must not be published until a clean Windows 10/11 install, update, restoration, and uninstall test has passed.

### B. Marketplace Custom App

The Marketplace listing is a discovery path, not a general-purpose native software installer. Users can install the Custom App from Marketplace, but the app alone cannot perform native Win32 working-set management. If the companion is missing, the app provides two next steps: the official releases page and this installation guide. The current 0.2.0 beta also links to Node.js 22+ because its active helper still uses Node.js.

The UI must say clearly that Marketplace-only installation does not enable optimization. It must not attempt to silently download or execute a helper. The user downloads the official release ZIP and runs the installer themselves.

## Listing requirements

The public repository needs the `spicetify-apps` topic and a valid root `manifest.json` with `name`, `description`, `preview`, and `readme`. The Custom App's executable manifest is separate at `app/manifest.json`.

Official publishing guide: https://github.com/spicetify/marketplace/wiki/Publishing-to-Marketplace

## Release readiness gates

- Add the repository topic `spicetify-apps`.
- Publish a real GitHub Release with the full package and checksum.
- Confirm both standalone installation and Marketplace-with-missing-companion guidance on Windows 10 and 11.
- Verify that the installer refuses unsupported operating systems before changing files.
- Verify the companion missing/unavailable screen and official links.
- Complete the Rust companion parity milestone before making it the default installer payload.
- Run install, update, restore, restart, and uninstall integration tests on Windows 10 and Windows 11.
- Do not call the Marketplace listing production-ready before a downloadable release exists.

Marketplace does not provide a supported mechanism for silently installing an arbitrary native Windows companion from a Custom App.
