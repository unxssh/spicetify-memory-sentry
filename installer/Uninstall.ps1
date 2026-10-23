#requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$UsePortuguese = [System.Globalization.CultureInfo]::CurrentUICulture.Name -match '^pt(?:-|$)'
function Get-LocalizedText([string]$English, [string]$Portuguese) {
    if ($UsePortuguese) { return $Portuguese }
    return $English
}
$SpicetifyRoot = Join-Path $env:APPDATA 'spicetify'
$AppName = 'SpicetifyMemorySentry'
$AppTarget = Join-Path (Join-Path $SpicetifyRoot 'CustomApps') $AppName
$LegacyExtension = Join-Path (Join-Path $SpicetifyRoot 'Extensions') 'SpicetifyMemorySentry.js'
$InstallDir = Join-Path $env:LOCALAPPDATA 'SpicetifyMemorySentry'
$StartupDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
$StartupVbs = Join-Path $StartupDir 'Spicetify Memory Sentry.vbs'
$LegacyStartup = Join-Path $StartupDir 'Spicetify Memory Sentry.lnk'

Write-Host ''
Write-Host 'Memory Sentry — Uninstaller' -ForegroundColor Cyan

# Stop only the matching helper, never all Node.js processes.
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

# Restore native working-set limits before removing the helper and its recovery file.
$HelperPath = Join-Path $InstallDir 'helper.js'
$BackupFile = Join-Path $InstallDir 'working-set-backup.json'
$NodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $BackupFile) {
    if (-not $NodeCommand -or -not (Test-Path -LiteralPath $HelperPath)) {
        throw (Get-LocalizedText 'Memory limits need restoration, but Node.js/helper.js were not found. Cleanup stopped to preserve the recovery file.' 'Há limites de memória para restaurar, mas Node.js/helper.js não foram encontrados. A limpeza foi interrompida para preservar o arquivo de recuperação.')
    }
    Write-Host (Get-LocalizedText 'Restoring original working-set limits for Spotify processes...' 'Restaurando os limites originais de working set dos processos Spotify...') -ForegroundColor Cyan
    & $NodeCommand.Source $HelperPath '--restore-limits'
    if ($LASTEXITCODE -ne 0) {
        throw (Get-LocalizedText 'Not all limits could be restored. Uninstall stopped to preserve the companion and backup; open Spotify, retry restoration, then run Uninstall.bat again.' 'Não foi possível restaurar todos os limites. A desinstalação foi interrompida para preservar o auxiliar e o backup; abra o Spotify, tente restaurar e rode Uninstall.bat novamente.')
    }
}

$spicetify = Get-Command spicetify -ErrorAction SilentlyContinue
if ($spicetify) {
    try { & $spicetify.Source config custom_apps "$AppName-" | Out-Null } catch { }
    try {
        $existingExtensions = (& $spicetify.Source config extensions 2>$null | Out-String)
        if ($existingExtensions -match '(?i)SpicetifyMemorySentry\.js') {
            & $spicetify.Source config extensions 'SpicetifyMemorySentry.js-' | Out-Null
        }
    } catch { }
    try {
        if (-not (Get-Process -Name Spotify -ErrorAction SilentlyContinue)) {
            & $spicetify.Source apply | Out-Null
        } else {
            Write-Warning (Get-LocalizedText 'Close Spotify and run `spicetify apply` to remove its sidebar entry.' 'Feche o Spotify e rode `spicetify apply` para remover a entrada da barra lateral.')
        }
    } catch { }
}

Remove-Item -LiteralPath $AppTarget -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $LegacyExtension -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $StartupVbs -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $LegacyStartup -Force -ErrorAction SilentlyContinue

# Preserve logs for comparison; remove helper code/dependencies/settings.
foreach ($name in @('helper.js', 'adaptive-policy.js', 'package.json', 'package-lock.json', 'settings.json', 'working-set-backup.json', 'working-set-backup.json.tmp', 'node_modules')) {
    Remove-Item -LiteralPath (Join-Path $InstallDir $name) -Recurse -Force -ErrorAction SilentlyContinue
}
if ((Test-Path -LiteralPath $InstallDir) -and -not (Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue)) {
    Remove-Item -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue
}
Write-Host (Get-LocalizedText 'Uninstallation complete. Logs were preserved in %LOCALAPPDATA%\SpicetifyMemorySentry\logs.' 'Desinstalação concluída. Os logs foram preservados em %LOCALAPPDATA%\SpicetifyMemorySentry\logs.') -ForegroundColor Green
