'use strict';
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const policy = require('../helper/adaptive-policy');
const root = path.resolve(__dirname, '..');
let failures = 0;
function check(name, condition) {
  if (condition) console.log(`PASS ${name}`);
  else { console.error(`FAIL ${name}`); failures++; }
}
function read(relative) { return fs.readFileSync(path.join(root, relative), 'utf8'); }

const requiredFiles = [
  'app/index.js', 'app/manifest.json', 'helper/helper.js', 'helper/adaptive-policy.js',
  'helper/package.json', 'installer/Install.ps1', 'installer/Uninstall.ps1', 'Install.bat',
  'Uninstall.bat', '.gitignore', 'manifest.json', 'README.md', 'LICENSE', 'PRIVACY.md', 'SECURITY.md',
  'CHANGELOG.md', 'docs/BENCHMARKING.md', 'docs/MARKETPLACE.md', 'docs/INSTALLATION.md', 'docs/RUST-MIGRATION.md', 'docs/RELEASE_CHECKLIST.md', 'docs/DEVELOPMENT.md', 'docs/TROUBLESHOOTING.md', 'installer/inno/MemorySentry.iss', 'scripts/build-package.ps1', 'native/rust/src/main.rs', 'native/rust/src/lib.rs', 'native/rust/src/runtime.rs', 'native/rust/src/platform/windows.rs', 'preview.png',
  '.github/workflows/validate.yml', '.github/workflows/release.yml'
];
for (const file of requiredFiles) check(`exists: ${file}`, fs.existsSync(path.join(root, file)));

let appManifest = {};
let marketplaceManifest = {};
let packageJson = {};
try { appManifest = JSON.parse(read('app/manifest.json')); } catch (_) { check('Custom App manifest JSON', false); }
try { marketplaceManifest = JSON.parse(read('manifest.json')); } catch (_) { check('Marketplace manifest JSON', false); }
try { packageJson = JSON.parse(read('helper/package.json')); } catch (_) { check('helper package JSON', false); }
check('Spicetify Custom App manifest is valid', Boolean(appManifest.name && appManifest.icon && appManifest['active-icon']));
check('root manifest is Marketplace metadata', marketplaceManifest.name === 'Memory Sentry' && marketplaceManifest.preview === 'preview.png' && marketplaceManifest.readme === 'README.md' && !marketplaceManifest.main);
check('Marketplace description discloses separate helper', /native companion installer/i.test(marketplaceManifest.description));
check('Marketplace listing explicitly limits support to Windows 10 and 11', /Windows 10 and Windows 11 only/i.test(marketplaceManifest.description));
check('installer enforces Windows 10/11 support before modifications', /Win32_OperatingSystem/.test(read('installer/Install.ps1')) && /Windows 10/.test(read('installer/Install.ps1')) && /Windows 11/.test(read('installer/Install.ps1')));
check('local publishing helper and generated archives are ignored', /\/PUSH-TO-GITHUB\.bat/.test(read('.gitignore')) && /\*\.bundle/.test(read('.gitignore')) && /\*\.zip/.test(read('.gitignore')));
check('development guide documents Rust build and package validation without local publishing scripts', /cargo test/.test(read('docs/DEVELOPMENT.md')) && /scripts\/build-package\.ps1/.test(read('docs/DEVELOPMENT.md')) && !/PUSH-TO-GITHUB\.bat/i.test(read('docs/DEVELOPMENT.md')));
check('README explains native companion requirement', /native companion/i.test(read('README.md')) && /separate per-user process/i.test(read('README.md')));
check('README documents adaptive CPU and headroom rules', /six seconds/i.test(read('README.md')) && /ten seconds/i.test(read('README.md')));
check('README documents unsigned SmartScreen limitations', /No unsigned release can guarantee zero SmartScreen/i.test(read('README.md')));
check('GPL-3.0 license is present', /GNU GENERAL PUBLIC LICENSE/i.test(read('LICENSE')) && /Version 3, 29 June 2007/i.test(read('LICENSE')));
check('privacy explicitly states no uploads', /No information is uploaded/i.test(read('PRIVACY.md')));
check('security notes never disable antivirus', /does not disable antivirus/i.test(read('SECURITY.md')));
check('Marketplace preview exists', fs.existsSync(path.join(root, marketplaceManifest.preview)));
check('release action publishes setup, package ZIP and SHA-256', /MemorySentrySetup/.test(read('.github/workflows/release.yml')) && /MemorySentry-.*windows-x64/.test(read('.github/workflows/release.yml')) && /action-gh-release/i.test(read('.github/workflows/release.yml')));
check('source package includes native Rust files', read('scripts/build-package.ps1').includes('native\\rust') && read('scripts/build-package.ps1').includes('NativeSourceDestination'));
check('portable package copies Rust sources only and excludes Cargo target artifacts', !read('scripts/build-package.ps1').includes('"app", "helper", "installer", "native"') && read('scripts/build-package.ps1').includes('Cargo.toml') && read('scripts/build-package.ps1').includes('src\\*'));

const app = read('app/index.js');
const helper = read('helper/helper.js');
const installer = read('installer/Install.ps1');
const setupScript = read('installer/inno/MemorySentry.iss');
const buildScript = read('scripts/build-package.ps1');
const uninstaller = read('installer/Uninstall.ps1');
const validation = read('.github/workflows/validate.yml');
const rustCargo = read('native/rust/Cargo.toml');
const rustLib = read('native/rust/src/lib.rs');
const rustMain = read('native/rust/src/main.rs');
const rustRuntime = read('native/rust/src/runtime.rs');
const rustPlatform = read('native/rust/src/platform/windows.rs');
check('dashboard supports automatic Portuguese and English', /navigator\.language/i.test(app) && /pt-BR/i.test(app) && /Auto language: English/i.test(app));
check('dashboard has a GitHub release button when helper is absent', /MSSOpenGitHub/i.test(app) && /github\.com\/yanlvl99\/spicetify-memory-sentry/i.test(app));
check('dashboard offers setup/help links without a Node.js button', /MSSOpenGitHub/.test(app) && /MSSOpenInstallGuide/.test(app) && !/MSSOpenNode|nodeButton|nodejs\.org/.test(app));
check('dashboard offers official releases and Marketplace setup guide', /MSS_RELEASES_URL/.test(app) && /MSS_INSTALL_GUIDE_URL/.test(app) && /installGuideButton/.test(app));
check('installation docs explain standalone and Marketplace paths', /Path A/.test(read('docs/INSTALLATION.md')) && /Path B/.test(read('docs/INSTALLATION.md')));
check('dashboard has no manual fixed RAM cap selector', !/workingSetLimitMB/.test(app) && !/Teto rígido de RAM por processo/.test(app));
check('dashboard shows per-process CPU and adaptive ceiling', /process\.cpuPercent/i.test(app) && /process\.limitMB/i.test(app));
check('dashboard explains local-only diagnostics', /No telemetry is uploaded/i.test(app));
check('Custom App replaces per-install token placeholder', app.includes('__MSS_TOKEN__'));
check('Custom App calls local status/config endpoints', app.includes('/api/status') && app.includes('/api/config'));
check('helper loads the testable adaptive policy module', helper.includes("require('./adaptive-policy')"));
check('helper uses native hard working-set API', helper.includes('SetProcessWorkingSetSizeEx') && helper.includes('GetProcessWorkingSetSizeEx'));
check('helper verifies process creation identity before changing limits', helper.includes('verifyProcessIdentity(opened.handle, target.creation)'));
check('helper persists original limits before applying them', helper.includes('persistBackups()') && helper.includes('makeBackupRecord'));
check('helper restores original limits when window becomes visible', helper.includes('restoreAllMeasured(`window ${state.windowState}`)'));
check('helper throttles repeated failed process-target attempts', helper.includes('TARGET_RETRY_DELAY_MS = 2500') && helper.includes('targetRetryAt.get(key)'));
check('helper refuses to apply new caps from a stale process snapshot', /if \(!state\.snapshotOk \|\| !state\.snapshotAtMs \|\| now - state\.snapshotAtMs > 6500\) return;/.test(helper));
check('helper excludes dedicated audio-service processes', helper.includes("if (p.role === 'Audio') return false") && !helper.includes('includeAudioProcess'));
check('helper polls focus at 100 ms', helper.includes('setInterval(tickSafe, 100)'));
check('helper discovers processes asynchronously on monitor path', helper.includes('refreshSnapshotAsync()') && helper.includes("execFile('powershell.exe'"));
check('helper keeps local API loopback-only and token-protected', helper.includes("server.listen(settings.port, '127.0.0.1'") && helper.includes('authorized(req)') && helper.includes('trustedOrigin(origin)'));
check('helper has read-only recovery and self-test commands', helper.includes('--restore-limits') && helper.includes('--self-test'));
check('helper does not use fixed manual cap configuration', !/settings\.workingSetLimitMB/.test(helper));
check('new installer uses the native Rust executable and fails closed on OS/prerequisites', /MemorySentry\.exe/.test(installer) && /--check-install/.test(installer) && /Windows 10/.test(installer) && /Windows 11/.test(installer));
check('Inno Setup packages the app and guards install/upgrade/uninstall', /PrivilegesRequired=lowest/.test(setupScript) && /--check-os/.test(setupScript) && /--prepare-upgrade/.test(setupScript) && /InitializeUninstall/.test(setupScript) && /--pre-uninstall/.test(setupScript));
check('build script compiles Inno setup and writes checksums', /ISCC\.exe/.test(buildScript) && /Get-FileHash/.test(buildScript) && /MemorySentrySetup-/.test(buildScript));
check('dashboard preserves detailed local API failures', app.includes('err && err.message') && app.includes("setError(tx('statusError') + ' [' + detail + ']')"));
check('dashboard renders actual connection diagnostics', app.includes("`${tx('helperMissingBody')} ${error}`"));
check('Rust uninstall allows Spotify to remain open and restores first', !/pub fn pre_uninstall\(\) -> Result<(), String> \{\s*ensure_spotify_closed/.test(rustRuntime) && rustRuntime.indexOf('pub fn pre_uninstall()') < rustRuntime.indexOf('unregister_startup()?;') && rustRuntime.indexOf('unregister_startup()?;') < rustRuntime.indexOf('unregister_spicetify()?;'));
check('single-instance mutex clears stale Win32 last-error state', rustPlatform.includes('SetLastError(0)'));
check('Rust launcher records early startup failures and verifies API readiness', rustRuntime.includes('startup.log') && rustRuntime.includes('request_status(settings.port, &settings.token)') && rustRuntime.includes('failed to become ready after 5 seconds'));
check('installer always launches the companion after setup', setupScript.includes('Flags: runhidden') && !setupScript.includes('Flags: postinstall nowait skipifsilent runhidden'));
check('installer avoids ExecutionPolicy Bypass', !/ExecutionPolicy\s+Bypass/i.test(read('Install.bat')) && !/ExecutionPolicy\s+Bypass/i.test(read('Uninstall.bat')));
check('installer has no elevation request', !/RunAs|Verb\s+RunAs/i.test(installer));
check('uninstaller invokes recovery-aware native pre-uninstall before removing files', /--pre-uninstall/.test(uninstaller) && uninstaller.indexOf('--pre-uninstall') < uninstaller.indexOf('Remove-Item -LiteralPath $AppTarget'));
check('source Inno installer preserves app recovery guard', /Recovery data exists but the companion executable is missing/.test(setupScript) && /No program files were removed/.test(setupScript));
check('package uses pinned Koffi and correct version', packageJson.version === '0.2.0' && packageJson.dependencies?.koffi === '3.3.3' && packageJson.engines?.node === '>=22');
check('CI runs package validation', validation.includes('node tests/validate-package.js'));
check('Rust scaffold uses a minimal standard-library dependency policy', rustCargo.includes('name = "memory-sentry-native"') && !rustCargo.includes('[dependencies]'));
check('Rust policy has pure, testable adaptive logic', rustLib.includes('decide_adjustment') && rustLib.includes('#[cfg(test)]'));
check('Rust binary exposes OS, install-preflight, upgrade, configure, monitor, and uninstall commands', ['--check-os', '--check-install', '--prepare-upgrade', '--configure', '--monitor', '--pre-uninstall', '--restore-limits'].every(command => rustMain.includes(command)));
check('Rust runtime implements the local dashboard API and adaptive working-set flow', rustRuntime.includes('/api/status') && rustRuntime.includes('/api/config') && rustRuntime.includes('/api/action') && rustRuntime.includes('platform::set_working_set_limits') && rustRuntime.includes('restore_all'));
check('Rust native layer protects process identity before each working-set mutation', rustPlatform.includes('set_working_set_limits') && rustPlatform.includes('creation != expected_creation') && rustPlatform.includes('restore_working_set_limits'));
check('Rust startup and instance locking are per-user and single-instance', rustPlatform.includes('acquire_single_instance') && rustRuntime.includes('register_startup') && rustRuntime.includes('127.0.0.1'));
check('Rust migration stops the legacy monitor before invoking its one-shot restore command', (rustRuntime.match(/stop_legacy_node_helper\(&base\)\?;/g) || []).length === 2);
check('Rust dashboard port remains consistent with the Custom App endpoint', /const MSS_API = 'http:\/\/127\.0\.0\.1:38472'/.test(app) && /port: DEFAULT_PORT/.test(rustRuntime));

// Exercise the pure adaptive policy without Windows APIs.
check('main process starts with its role baseline', policy.baseCapMB('Main') === 36);
check('CPU estimate is normalized to one logical processor', policy.estimateCpuPercent(1000, 1250, 1000) === 25);
check('CPU estimate rejects invalid sample intervals', policy.estimateCpuPercent(1000, 1250, 0) === null);
check('sustained high CPU increases the ceiling by 8 MB', policy.decideAdjustment({ role: 'Renderer', currentCapMB: 28, workingSetMB: 24, cpuPercent: 18, highCpuMs: 7000, lowCpuMs: 0, lastAdjustmentAt: 0, now: 20000 })?.nextCapMB === 36);
check('high CPU without enough duration does not increase ceiling', policy.decideAdjustment({ role: 'Renderer', currentCapMB: 28, workingSetMB: 24, cpuPercent: 18, highCpuMs: 3000, now: 20000 }) === null);
check('low CPU and headroom lowers the ceiling by 4 MB', policy.decideAdjustment({ role: 'Renderer', currentCapMB: 28, workingSetMB: 15, cpuPercent: 1, lowCpuMs: 12000, lastAdjustmentAt: 0, now: 20000 })?.nextCapMB === 24);
check('main process keeps a 24 MB floor to improve restore responsiveness', policy.minimumCapMB('Main') === 24 && policy.decideAdjustment({ role: 'Main', currentCapMB: 28, workingSetMB: 15, cpuPercent: 1, lowCpuMs: 12000, lastAdjustmentAt: 0, now: 20000 })?.nextCapMB === 24);
check('renderers can still shrink toward the 12 MB floor', policy.minimumCapMB('Renderer') === 12 && policy.decideAdjustment({ role: 'Renderer', currentCapMB: 16, workingSetMB: 7, cpuPercent: 1, lowCpuMs: 12000, lastAdjustmentAt: 0, now: 20000 })?.nextCapMB === 12);
check('low CPU near the ceiling does not reduce the limit', policy.decideAdjustment({ role: 'Renderer', currentCapMB: 28, workingSetMB: 25, cpuPercent: 1, lowCpuMs: 12000, lastAdjustmentAt: 0, now: 20000 }) === null);
check('adjustment cooldown prevents rapid oscillation', policy.decideAdjustment({ role: 'Renderer', currentCapMB: 28, workingSetMB: 15, cpuPercent: 1, lowCpuMs: 12000, lastAdjustmentAt: 17000, now: 20000 }) === null);
check('adaptive floor is 12 MB and global ceiling is 64 MB', policy.MIN_CAP_MB === 12 && policy.MAX_CAP_MB === 64);
check('per-role upper bounds remain below the global safety limit', policy.maximumCapMB('Main') === 60 && policy.maximumCapMB('Renderer') === 52);
check('a process at its role maximum cannot grow further', policy.decideAdjustment({ role: 'Main', currentCapMB: 60, workingSetMB: 50, cpuPercent: 90, highCpuMs: 12000, lastAdjustmentAt: 0, now: 20000 }) === null);
check('CPU estimate is capped at one logical processor', policy.estimateCpuPercent(0, 4000, 1000) === 100);

for (const [name, source] of [['app/index.js', app], ['helper/helper.js', helper], ['helper/adaptive-policy.js', read('helper/adaptive-policy.js')]]) {
  try { new vm.Script(source, { filename: name }); check(`JavaScript syntax: ${name}`, true); }
  catch (error) { check(`JavaScript syntax: ${name} (${error.message})`, false); }
}
if (failures) process.exitCode = 1;
else console.log('\nAll static checks and pure policy tests passed. Native Win32 behavior still requires a Windows runtime test.');
