#requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$UsePortuguese = [System.Globalization.CultureInfo]::CurrentUICulture.Name -match '^pt(?:-|$)'
function Get-LocalizedText([string]$English, [string]$Portuguese) {
    if ($UsePortuguese) { return $Portuguese }
    return $English
}

$PackageRoot = Split-Path -Parent $PSScriptRoot
$AppSource = Join-Path $PackageRoot 'app'
$HelperSource = Join-Path $PackageRoot 'helper'
$SpicetifyRoot = Join-Path $env:APPDATA 'spicetify'
$CustomAppsRoot = Join-Path $SpicetifyRoot 'CustomApps'
$AppName = 'SpicetifyMemorySentry'
$AppTarget = Join-Path $CustomAppsRoot $AppName
$InstallDir = Join-Path $env:LOCALAPPDATA 'SpicetifyMemorySentry'
$StartupDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
$StartupVbs = Join-Path $StartupDir 'Spicetify Memory Sentry.vbs'
$LegacyStartup = Join-Path $StartupDir 'Spicetify Memory Sentry.lnk'
$LegacyExtension = Join-Path (Join-Path $SpicetifyRoot 'Extensions') 'SpicetifyMemorySentry.js'
$HelperPath = Join-Path $InstallDir 'helper.js'
$ReleaseUrl = 'https://github.com/yanlvl99/spicetify-memory-sentry'
$NodeUrl = 'https://nodejs.org/en/download'
$NodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
$NpmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue

Write-Host ''
Write-Host 'Memory Sentry 0.2.0 — installer' -ForegroundColor Cyan
Write-Host 'Installs the Spicetify dashboard and adaptive Windows companion.'
Write-Host 'Open-source GPL-3.0 project. No administrator privileges are requested; audio-service processes are excluded.'
Write-Host 'Source and releases: https://github.com/yanlvl99/spicetify-memory-sentry'
Write-Host ''

if (-not $NodeCommand -or -not $NpmCommand) {
    Write-Host 'Node.js 22+ and npm are required. The dashboard includes a GitHub button for this installer if the companion is missing.' -ForegroundColor Yellow
    Write-Host "Install a supported Node.js release from: $NodeUrl"
    Write-Host "Download this open-source companion from: $ReleaseUrl"
    Start-Process $NodeUrl
    throw 'Node.js 22+ with npm was not found. Install it, reopen your terminal, and run Install.bat again.'
}
$nodeVersionText = (& $NodeCommand.Source --version | Out-String).Trim()
if ($nodeVersionText -notmatch '^v?(\d+)\.') { throw "Could not parse the Node.js version: $nodeVersionText" }
if ([int]$Matches[1] -lt 22) { Write-Host "Detected $nodeVersionText; Node.js 22+ is required." -ForegroundColor Yellow; Start-Process $NodeUrl; throw 'Please install Node.js 22+ and rerun Install.bat.' }

if (Get-Process -Name Spotify -ErrorAction SilentlyContinue) {
    throw 'Close Spotify completely before installing and run Install.bat again. This avoids replacing the Custom App during an active session.'
}

foreach ($required in @(
    (Join-Path $AppSource 'index.js'),
    (Join-Path $AppSource 'manifest.json'),
    (Join-Path $HelperSource 'helper.js'),
    (Join-Path $HelperSource 'adaptive-policy.js'),
    (Join-Path $HelperSource 'package.json')
)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required package file is missing: $required" }
}

# Prepare the new dependency tree in a staging directory first. If npm fails,
# the currently installed version is left intact.
$StageDir = Join-Path $env:TEMP ('SpicetifyMemorySentry-stage-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $StageDir -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $HelperSource 'package.json') -Destination (Join-Path $StageDir 'package.json') -Force
Write-Host (Get-LocalizedText 'Staging clean dependencies in a temporary directory...' 'Preparando dependências limpas em uma pasta temporária...') -ForegroundColor Cyan
try {
    Push-Location $StageDir
    try {
        & $NpmCommand.Source install --omit=dev --no-audit --no-fund --save-exact
        if ($LASTEXITCODE -ne 0) { throw (Get-LocalizedText "npm install failed (exit code $LASTEXITCODE). The previous installation was preserved." "O npm install falhou (código $LASTEXITCODE). A instalação anterior foi preservada.") }
    } finally { Pop-Location }
} catch {
    Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction SilentlyContinue
    throw
}

# Stop only older Memory Sentry helper processes before replacing loaded files.
try {
    Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains('SpicetifyMemorySentry') -and $_.CommandLine.Contains('helper.js') } |
        ForEach-Object { try { Stop-Process -Id ([int]$_.ProcessId) -Force -ErrorAction SilentlyContinue } catch { } }
} catch { }
try {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^(powershell|pwsh)\.exe$' -and $_.CommandLine -and $_.CommandLine.Contains('MemorySentry.Helper.ps1') } |
        ForEach-Object { try { Stop-Process -Id ([int]$_.ProcessId) -Force -ErrorAction SilentlyContinue } catch { } }
} catch { }
Remove-Item -LiteralPath $LegacyStartup -Force -ErrorAction SilentlyContinue

# If an earlier 0.1.3+ build left active hard working-set caps, ask that exact installed
# helper to restore the originals after its monitor process has stopped, before cleanup.
$BackupFile = Join-Path $InstallDir 'working-set-backup.json'
$OldSettingsFile = Join-Path $InstallDir 'settings.json'
$OldHelperFile = Join-Path $InstallDir 'helper.js'
if ((Test-Path -LiteralPath $BackupFile) -and (Test-Path -LiteralPath $OldSettingsFile) -and (Test-Path -LiteralPath $OldHelperFile)) {
    try {
        $oldSettings = Get-Content -LiteralPath $OldSettingsFile -Raw | ConvertFrom-Json
        $oldVersion = [version]'0.0.0'
        if ($oldSettings.version) { try { $oldVersion = [version]$oldSettings.version } catch { } }
        if ($oldVersion -ge [version]'0.1.3') {
            Write-Host (Get-LocalizedText 'Restoring native limits from the previous installation...' 'Restaurando os limites nativos da instalação anterior...') -ForegroundColor Cyan
            & $NodeCommand.Source $OldHelperFile '--restore-limits'
            if ($LASTEXITCODE -ne 0) { throw (Get-LocalizedText 'The previous version could not restore every limit. Upgrade stopped to preserve the recovery backup.' 'A versão anterior não conseguiu restaurar todos os limites. A atualização foi interrompida para preservar o backup.') }
        }
    } catch {
        Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction SilentlyContinue
        throw
    }
}

# Upgrade cleanup: replace the installed Custom App and helper, but preserve logs.
if (Test-Path -LiteralPath $AppTarget) {
    Remove-Item -LiteralPath $AppTarget -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path -LiteralPath $InstallDir) {
    foreach ($item in Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue) {
        if ($item.Name -ne 'logs') {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
New-Item -ItemType Directory -Path $CustomAppsRoot -Force | Out-Null
New-Item -ItemType Directory -Path $AppTarget -Force | Out-Null
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
New-Item -ItemType Directory -Path $StartupDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $InstallDir 'logs') -Force | Out-Null

# Copy only fresh files from this release. Old Custom App files and node_modules
# were removed above; logs are the only persistent data retained from old builds.
$token = ([guid]::NewGuid().ToString('N') + [guid]::NewGuid().ToString('N'))
$appJsSource = Get-Content -LiteralPath (Join-Path $AppSource 'index.js') -Raw -Encoding UTF8
if (-not $appJsSource.Contains('__MSS_TOKEN__')) { throw (Get-LocalizedText 'Token placeholder was not found in app/index.js.' 'O marcador de token não foi encontrado em app/index.js.') }
$appJs = $appJsSource.Replace('__MSS_TOKEN__', $token)
Set-Content -LiteralPath (Join-Path $AppTarget 'index.js') -Value $appJs -Encoding UTF8
Copy-Item -LiteralPath (Join-Path $AppSource 'manifest.json') -Destination (Join-Path $AppTarget 'manifest.json') -Force
Copy-Item -LiteralPath (Join-Path $HelperSource 'helper.js') -Destination $HelperPath -Force
Copy-Item -LiteralPath (Join-Path $HelperSource 'adaptive-policy.js') -Destination (Join-Path $InstallDir 'adaptive-policy.js') -Force
Copy-Item -LiteralPath (Join-Path $HelperSource 'package.json') -Destination (Join-Path $InstallDir 'package.json') -Force
Copy-Item -LiteralPath (Join-Path $StageDir 'node_modules') -Destination (Join-Path $InstallDir 'node_modules') -Recurse -Force
if (Test-Path -LiteralPath (Join-Path $StageDir 'package-lock.json')) {
    Copy-Item -LiteralPath (Join-Path $StageDir 'package-lock.json') -Destination (Join-Path $InstallDir 'package-lock.json') -Force
}
Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction SilentlyContinue
$settings = [ordered]@{
    port = 38472
    token = $token
    autoOptimize = $true
    hiddenDelaySeconds = 2
    version = '0.2.0'
}
$settings | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $InstallDir 'settings.json') -Encoding UTF8

# Remove legacy extension registration from the first prototype, without touching other extensions.
$spicetify = Get-Command spicetify -ErrorAction SilentlyContinue
if ($spicetify) {
    try {
        $existingExtensions = (& $spicetify.Source config extensions 2>$null | Out-String)
        if ($existingExtensions -match '(?i)SpicetifyMemorySentry\.js') {
            & $spicetify.Source config extensions 'SpicetifyMemorySentry.js-' | Out-Null
        }
    } catch { }
    try { Remove-Item -LiteralPath $LegacyExtension -Force -ErrorAction SilentlyContinue } catch { }

    $existingApps = ''
    try { $existingApps = (& $spicetify.Source config custom_apps 2>$null | Out-String) } catch { }
    if ($existingApps -notmatch '(?i)(^|[|\s=])SpicetifyMemorySentry([|\s]|$)') {
        & $spicetify.Source config custom_apps $AppName | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Could not register the Custom App with Spicetify.' }
    }
    & $spicetify.Source apply
    if ($LASTEXITCODE -ne 0) { throw 'Spicetify could not apply the Custom App. Check your Spicetify installation and try `spicetify backup apply`.' }
} else {
    Write-Warning (Get-LocalizedText 'Spicetify CLI was not found on PATH. The Custom App was copied but must be registered manually.' 'O Spicetify CLI não foi encontrado no PATH. O Custom App foi copiado, mas precisa ser registrado manualmente.')
    Write-Host (Get-LocalizedText "Run: spicetify config custom_apps $AppName" "Execute: spicetify config custom_apps $AppName")
    Write-Host (Get-LocalizedText 'Then run: spicetify apply' 'Depois execute: spicetify apply')
}

# Startup launcher: VBScript starts node.exe without showing a console window.
$command = '"' + $NodeCommand.Source + '" "' + $HelperPath + '"'
$vbsContent = 'Set shell = CreateObject("WScript.Shell")' + "`r`n" + 'shell.Run "' + $command.Replace('"', '""') + '", 0, False' + "`r`n" + 'Set shell = Nothing' + "`r`n"
[System.IO.File]::WriteAllText($StartupVbs, $vbsContent, [System.Text.Encoding]::Unicode)

# Start the monitor now. It can wait quietly while Spotify is closed.
Start-Process -FilePath $NodeCommand.Source -ArgumentList @('"' + $HelperPath + '"') -WindowStyle Hidden

Write-Host ''
Write-Host (Get-LocalizedText 'Installation complete.' 'Instalação concluída.') -ForegroundColor Green
Write-Host "Custom App: $AppTarget"
Write-Host (Get-LocalizedText "Node companion: $HelperPath" "Auxiliar Node: $HelperPath")
Write-Host "Logs: $(Join-Path $InstallDir 'logs\helper.log')"
Write-Host (Get-LocalizedText 'Open Spotify. Memory Sentry should appear in the sidebar after the client restarts.' 'Abra o Spotify. O Memory Sentry deverá aparecer na barra lateral após reiniciar o cliente.')
Write-Host 'Adaptive policy: after the configured delay, process ceilings respond to sustained CPU activity and available working-set headroom. Dedicated audio processes are always excluded.'
Write-Host 'Original limits are persisted before changes and restored when Spotify is visible or during recovery. Lower resident RAM can still increase page faults and delay UI recovery.'
Write-Host 'Logs are preserved across upgrades. Source and release checksums are available on GitHub; no security-warning bypass is installed or configured.'
Write-Host ''
