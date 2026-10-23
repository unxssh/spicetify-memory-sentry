#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$UsePortuguese = [System.Globalization.CultureInfo]::CurrentUICulture.Name -match '^pt(?:-|$)'
function Say([string]$English, [string]$Portuguese) {
    if ($UsePortuguese) { Write-Host $Portuguese } else { Write-Host $English }
}

$OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
if ($OperatingSystem.ProductType -ne 1 -or $OperatingSystem.Caption -notmatch '\bWindows 10\b|\bWindows 11\b') {
    throw 'Memory Sentry supports Windows 10 and Windows 11 desktop editions only. No files were changed.'
}

$PackageRoot = Split-Path -Parent $PSScriptRoot
$SourceExe = Join-Path $PackageRoot 'MemorySentry.exe'
$AppSource = Join-Path $PackageRoot 'app'
$InstallDir = Join-Path $env:LOCALAPPDATA 'SpicetifyMemorySentry'
$AppTarget = Join-Path (Join-Path (Join-Path $env:APPDATA 'spicetify') 'CustomApps') 'SpicetifyMemorySentry'

Say '' ''
Say 'Memory Sentry — per-user setup' 'Memory Sentry — instalação por usuário'
Say 'Supported systems: Windows 10 and Windows 11 desktop editions.' 'Sistemas compatíveis: Windows 10 e Windows 11 (desktop).'
Say 'No administrator access is requested. Spicetify may restart Spotify automatically during setup.' 'Não é necessário usar administrador. O Spicetify pode reiniciar o Spotify automaticamente durante a instalação.'

if (-not (Test-Path -LiteralPath $SourceExe -PathType Leaf) -or -not (Test-Path -LiteralPath $AppSource -PathType Container)) {
    throw 'This is not a complete release package. Download the official MemorySentrySetup.exe or release ZIP from https://github.com/yanlvl99/spicetify-memory-sentry/releases.'
}
$TransactionRoot = Join-Path $env:TEMP ('MemorySentry-Setup-' + [guid]::NewGuid().ToString('N'))
$Stage = Join-Path $TransactionRoot 'stage'
$PreviousInstall = Join-Path $TransactionRoot 'previous-install'
$PreviousApp = Join-Path $TransactionRoot 'previous-app'
$InstallWasMoved = $false
$AppWasMoved = $false
$RollbackOk = $true
$Succeeded = $false

try {
    New-Item -ItemType Directory -Path (Join-Path $Stage 'app') -Force | Out-Null
    Copy-Item -LiteralPath $SourceExe -Destination (Join-Path $Stage 'MemorySentry.exe')
    Copy-Item -Path (Join-Path $AppSource '*') -Destination (Join-Path $Stage 'app') -Recurse -Force

    # Give the user a precise prerequisite error before any installed files are moved.
    & (Join-Path $Stage 'MemorySentry.exe') '--check-spicetify'
    if ($LASTEXITCODE -ne 0) {
        throw 'Spicetify CLI was not found for this Windows user. Install Spicetify first, reopen the terminal/session if PATH changed, and retry. No installed files were replaced.'
    }
    & (Join-Path $Stage 'MemorySentry.exe') '--check-install'
    if ($LASTEXITCODE -ne 0) {
        throw 'Setup preflight failed. Read the diagnostic printed above. No installed files were replaced.'
    }

    # Recover old sessions before moving or replacing any installed files.
    & (Join-Path $Stage 'MemorySentry.exe') '--prepare-upgrade'
    if ($LASTEXITCODE -ne 0) {
        throw 'The previous installation could not confirm recovery. Existing files and recovery records were left untouched.'
    }

    if (Test-Path -LiteralPath $InstallDir -PathType Container) {
        Move-Item -LiteralPath $InstallDir -Destination $PreviousInstall
        $InstallWasMoved = $true
    }
    if (Test-Path -LiteralPath $AppTarget -PathType Container) {
        Move-Item -LiteralPath $AppTarget -Destination $PreviousApp
        $AppWasMoved = $true
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    New-Item -ItemType Directory -Path $AppTarget -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $Stage 'MemorySentry.exe') -Destination (Join-Path $InstallDir 'MemorySentry.exe') -Force
    Copy-Item -Path (Join-Path (Join-Path $Stage 'app') '*') -Destination $AppTarget -Recurse -Force

    # Preserve the user's token and settings across upgrades; first installs get a new token.
    $OldSettings = Join-Path $PreviousInstall 'settings.json'
    if (Test-Path -LiteralPath $OldSettings -PathType Leaf) {
        Copy-Item -LiteralPath $OldSettings -Destination (Join-Path $InstallDir 'settings.json') -Force
    }

    & (Join-Path $InstallDir 'MemorySentry.exe') '--configure' $AppTarget
    if ($LASTEXITCODE -ne 0) {
        throw 'Memory Sentry could not register its Custom App. Setup will roll back the previous files.'
    }

    # Keep diagnostics from the previous version outside the recovery-critical paths.
    $OldLogs = Join-Path $PreviousInstall 'logs'
    if (Test-Path -LiteralPath $OldLogs -PathType Container) {
        $NewLogs = Join-Path $InstallDir 'logs'
        New-Item -ItemType Directory -Path $NewLogs -Force | Out-Null
        Copy-Item -Path (Join-Path $OldLogs '*') -Destination $NewLogs -Force -ErrorAction SilentlyContinue
    }

    & (Join-Path $InstallDir 'MemorySentry.exe') '--launch'
    if ($LASTEXITCODE -ne 0) {
        throw 'The companion was installed but could not be started. Setup will roll back the previous files.'
    }

    $Succeeded = $true
    Say 'Installation completed. Reopen Spotify and select Memory Sentry from the sidebar.' 'Instalação concluída. Reabra o Spotify e selecione Memory Sentry na barra lateral.'
    Write-Host "Installed companion: $InstallDir"
    Write-Host "Custom App: $AppTarget"
}
catch {
    Write-Error $_
    try {
        if (Test-Path -LiteralPath $AppTarget) { Remove-Item -LiteralPath $AppTarget -Recurse -Force -ErrorAction Stop }
        if (Test-Path -LiteralPath $InstallDir) { Remove-Item -LiteralPath $InstallDir -Recurse -Force -ErrorAction Stop }
        if ($AppWasMoved -and (Test-Path -LiteralPath $PreviousApp)) { Move-Item -LiteralPath $PreviousApp -Destination $AppTarget -ErrorAction Stop }
        if ($InstallWasMoved -and (Test-Path -LiteralPath $PreviousInstall)) { Move-Item -LiteralPath $PreviousInstall -Destination $InstallDir -ErrorAction Stop }
        if (Test-Path -LiteralPath (Join-Path $InstallDir 'MemorySentry.exe')) {
            & (Join-Path $InstallDir 'MemorySentry.exe') '--launch' | Out-Null
        }
    }
    catch {
        $RollbackOk = $false
        Write-Warning "Rollback could not finish automatically. Previous files were preserved at: $TransactionRoot"
        Write-Warning $_
    }
    throw
}
finally {
    if ($Succeeded -or $RollbackOk) {
        Remove-Item -LiteralPath $TransactionRoot -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Warning "Do not delete this folder until the previous installation has been recovered: $TransactionRoot"
    }
}
