[CmdletBinding()]
param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

if (-not $Version) {
    $cargo = Get-Content -LiteralPath (Join-Path $Root "native\rust\Cargo.toml") -Raw
    if ($cargo -notmatch '(?m)^version\s*=\s*"([^"]+)"') { throw "Could not read native companion version from Cargo.toml." }
    $Version = $Matches[1]
}
if ($Version -notmatch '^[0-9A-Za-z][0-9A-Za-z.+-]*$') { throw "Invalid release version: $Version" }

$Binary = Join-Path $Root "target\x86_64-pc-windows-msvc\release\memory-sentry-native.exe"
if (-not (Test-Path -LiteralPath $Binary -PathType Leaf)) {
    throw "Compiled Windows companion not found at $Binary. Run cargo build --release for x86_64-pc-windows-msvc first."
}

$VersionOutput = & $Binary "--version" 2>&1
if ($LASTEXITCODE -ne 0 -or ($VersionOutput -join " ") -notmatch [regex]::Escape($Version)) {
    throw "Compiled binary version does not match requested package version $Version."
}
& $Binary "--self-test"
if ($LASTEXITCODE -ne 0) { throw "The binary self-test failed." }

$Dist = Join-Path $Root "dist"
$Stage = Join-Path $Dist "stage"
$Portable = Join-Path $Dist "portable"
New-Item -ItemType Directory -Path $Dist -Force | Out-Null
if (Test-Path -LiteralPath $Stage) { Remove-Item -LiteralPath $Stage -Recurse -Force }
if (Test-Path -LiteralPath $Portable) { Remove-Item -LiteralPath $Portable -Recurse -Force }
New-Item -ItemType Directory -Path (Join-Path $Stage "app") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Stage "docs") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $Portable "app") -Force | Out-Null

Copy-Item -LiteralPath $Binary -Destination (Join-Path $Stage "MemorySentry.exe") -Force
Copy-Item -Path (Join-Path $Root "app\*") -Destination (Join-Path $Stage "app") -Recurse -Force
foreach ($name in @("README.md", "LICENSE", "PRIVACY.md", "SECURITY.md")) {
    Copy-Item -LiteralPath (Join-Path $Root $name) -Destination $Stage -Force
}
foreach ($name in @("INSTALLATION.md", "TROUBLESHOOTING.md")) {
    Copy-Item -LiteralPath (Join-Path $Root ("docs\" + $name)) -Destination (Join-Path $Stage "docs") -Force
}

# Portable installer ZIP: built EXE at the root plus the source/project layout.
Copy-Item -LiteralPath (Join-Path $Stage "MemorySentry.exe") -Destination (Join-Path $Portable "MemorySentry.exe") -Force
foreach ($name in @(
    "README.md", "LICENSE", "PRIVACY.md", "SECURITY.md", "CHANGELOG.md",
    "manifest.json", "preview.png", ".gitignore", "Install.bat", "Uninstall.bat"
)) {
    Copy-Item -LiteralPath (Join-Path $Root $name) -Destination $Portable -Force
}
foreach ($directory in @("app", "helper", "installer", "native", "docs", "tests", "scripts", ".github")) {
    $destination = Join-Path $Portable $directory
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path (Join-Path $Root ($directory + "\*")) -Destination $destination -Recurse -Force
}
$PortableZip = Join-Path $Dist ("MemorySentry-" + $Version + "-windows-x64.zip")
if (Test-Path -LiteralPath $PortableZip) { Remove-Item -LiteralPath $PortableZip -Force }
Compress-Archive -Path (Join-Path $Portable "*") -DestinationPath $PortableZip -CompressionLevel Optimal

$InnoCandidates = @(
    (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe"),
    (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe")
)
$ISCC = $InnoCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $ISCC) {
    $command = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
    if ($command) { $ISCC = $command.Source }
}
if (-not $ISCC) { throw "Inno Setup 6 compiler (ISCC.exe) was not found. Install Inno Setup 6 before packaging." }

$Iss = Join-Path $Root "installer\inno\MemorySentry.iss"
& $ISCC ("/DAppVersion=" + $Version) ("/DStageDir=" + $Stage) $Iss
if ($LASTEXITCODE -ne 0) { throw "Inno Setup compilation failed with exit code $LASTEXITCODE." }

$SetupExe = Join-Path $Dist ("MemorySentrySetup-" + $Version + ".exe")
if (-not (Test-Path -LiteralPath $SetupExe -PathType Leaf)) { throw "Inno Setup completed without producing $SetupExe." }

foreach ($asset in @($SetupExe, $PortableZip)) {
    $hash = (Get-FileHash -LiteralPath $asset -Algorithm SHA256).Hash.ToLowerInvariant()
    $hashPath = $asset + ".sha256"
    Set-Content -LiteralPath $hashPath -Value ($hash + "  " + [IO.Path]::GetFileName($asset)) -Encoding ASCII
    Write-Host ("SHA-256 " + [IO.Path]::GetFileName($asset) + ": " + $hash)
}

Write-Host "Setup: $SetupExe"
Write-Host "Portable package: $PortableZip"
