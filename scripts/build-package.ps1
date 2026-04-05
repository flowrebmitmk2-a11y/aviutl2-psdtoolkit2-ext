param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$releaseRoot = Join-Path $repoRoot "release"
$packageRoot = Join-Path $releaseRoot "package"
$scriptRoot = Join-Path $packageRoot "Script"
$zipPath = Join-Path $releaseRoot "aviutl2-psdtoolkit2-ext-v$Version.au2pkg.zip"
$sourceRoot = Join-Path $repoRoot "data\\Script"

if (-not (Test-Path $sourceRoot)) {
    throw "Source directory not found: $sourceRoot"
}

if (Test-Path $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $scriptRoot | Out-Null

Copy-Item -LiteralPath (Join-Path $sourceRoot "@PSDToolKitExt.anm2") -Destination (Join-Path $scriptRoot "@PSDToolKitExt.anm2") -Force
Copy-Item -LiteralPath (Join-Path $sourceRoot "@PSDToolKitExt.obj2") -Destination (Join-Path $scriptRoot "@PSDToolKitExt.obj2") -Force
Copy-Item -LiteralPath (Join-Path $sourceRoot "PSDToolKitExt.lua") -Destination (Join-Path $scriptRoot "PSDToolKitExt.lua") -Force

$releaseNotesTemplate = Get-Content -LiteralPath (Join-Path $repoRoot "release.md") -Raw
$releaseNotes = $releaseNotesTemplate.Replace("{{version}}", $Version)
$releaseNotesPath = Join-Path $releaseRoot "README.md"
Set-Content -LiteralPath $releaseNotesPath -Value $releaseNotes -Encoding utf8

if (Test-Path $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $zipPath -Force
Write-Host "Created package: $zipPath"
