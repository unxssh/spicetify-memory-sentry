# Marketplace publishing notes

The root `manifest.json` is the Spicetify Marketplace listing metadata for the **Custom Apps** category. The public GitHub repository must use the `spicetify-apps` topic and include the manifest, preview image, and README. See the [official publishing guide](https://github.com/spicetify/marketplace/wiki/Publishing-to-Marketplace).

Marketplace listing is not a native-helper installer. The Custom App provides the dashboard; the Windows companion is a separate Node.js process because Win32 process working-set APIs cannot be called directly from Spicetify JavaScript. The dashboard shows a button to the official GitHub Releases page when it cannot connect to the companion.

Before submitting a Marketplace listing, verify the latest rules, add the `spicetify-apps` topic, check the preview image, and test a clean install/update/uninstall on Windows. Do not claim one-click native installation until the Marketplace has a documented supported path for trusted native companions.
