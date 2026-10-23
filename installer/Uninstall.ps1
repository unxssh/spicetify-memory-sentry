#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$UsePortuguese = [System.Globalization.CultureInfo]::CurrentUICulture.Name -match '^pt(?:-|$)'
function Say([string]$English, [string]$Portuguese) {
    if ($UsePortuguese) { Write-Host $Portuguese } else { Write-Host $English }
}

$InstallDir = Join-Path $env:LOCALAPPDATA 'SpicetifyMemorySentry'
$HelperPath = Join-Path $InstallDir 'MemorySentry.exe'
$AppTarget = Join-Path (Join-Path (Join-Path $env:APPDATA 'spicetify') 'CustomApps') 'SpicetifyMemorySentry'
$BackupTsv = Join-Path $InstallDir 'working-set-backup.tsv'
$BackupJson = Join-Path $InstallDir 'working-set-backup.json'
$StartupDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'

Say '' ''
Say 'Memory Sentry — uninstaller' 'Memory Sentry — desinstalador'
Say 'Spicetify may restart Spotify while removing the Custom App. Recovery failures intentionally stop removal.' 'O Spicetify pode reiniciar o Spotify ao remover o Custom App. Falhas de recuperação interrompem a remoção.'

if (Test-Path -LiteralPath $HelperPath -PathType Leaf) {
    & $HelperPath '--pre-uninstall'
    if ($LASTEXITCODE -ne 0) {
        throw 'Recovery or unregistering failed. The installer stopped and kept recovery data and program files.'
    }
}
else {
    # Legacy recovery fallback for older Node-based versions.
    if (Test-Path -LiteralPath $BackupTsv -PathType Leaf) {
        $records = @(Get-Content -LiteralPath $BackupTsv -ErrorAction Stop | Where-Object { $_.Trim() -and $_ -notmatch '^#' })
        if ($records.Count -gt 0) {
            throw 'Native recovery records exist but MemorySentry.exe is missing. Files were preserved; reinstall the matching version to recover safely.'
        }
    }
    if (Test-Path -LiteralPath $BackupJson -PathType Leaf) {
        $LegacyHelper = Join-Path $InstallDir 'helper.js'
        $Node = Get-Command node.exe -ErrorAction SilentlyContinue
        if (-not $Node -or -not (Test-Path -LiteralPath $LegacyHelper)) {
            throw 'A legacy Node recovery backup exists but its helper or Node.js is missing. Files were preserved.'
        }
        & $Node.Source $LegacyHelper '--restore-limits'
        if ($LASTEXITCODE -ne 0) { throw 'Legacy recovery failed. Files were preserved.' }
    }
}

# Preserve logs outside the removable install directory.
$Logs = Join-Path $InstallDir 'logs'
if (Test-Path -LiteralPath $Logs -PathType Container) {
    $LogDestination = Join-Path $env:LOCALAPPDATA 'MemorySentry\logs'
    New-Item -ItemType Directory -Path $LogDestination -Force | Out-Null
    Copy-Item -Path (Join-Path $Logs '*') -Destination $LogDestination -Force -ErrorAction SilentlyContinue
}

Remove-Item -LiteralPath (Join-Path $StartupDir 'Spicetify Memory Sentry.vbs') -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $StartupDir 'Spicetify Memory Sentry.lnk') -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $AppTarget -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $InstallDir -Recurse -Force -ErrorAction SilentlyContinue

Say 'Memory Sentry was removed. Logs (if any) were preserved under %LOCALAPPDATA%\MemorySentry\logs.' 'Memory Sentry foi removido. Os logs (se existirem) foram preservados em %LOCALAPPDATA%\MemorySentry\logs.'
