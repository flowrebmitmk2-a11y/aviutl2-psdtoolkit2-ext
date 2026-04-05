param(
    [string]$UpstreamUrl = $env:UPSTREAM_PSDTOOLKIT_URL,
    [string]$ExpectedHashFile = "upstream/PSDToolKit.lua.sha256"
)

$ErrorActionPreference = "Stop"

if (-not $UpstreamUrl) {
    Write-Host "UPSTREAM_PSDTOOLKIT_URL is not set. Skipping upstream check."
    exit 0
}

if (-not (Test-Path $ExpectedHashFile)) {
    throw "Expected hash file not found: $ExpectedHashFile"
}

$tmpRoot = Join-Path (Split-Path -Parent $PSScriptRoot) "_tmp"
$tmpFile = Join-Path $tmpRoot "PSDToolKit.lua"
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
Invoke-WebRequest -Uri $UpstreamUrl -OutFile $tmpFile

$expectedHash = (Get-Content $ExpectedHashFile -Raw).Trim().ToUpperInvariant()
$actualHash = (Get-FileHash $tmpFile -Algorithm SHA256).Hash.ToUpperInvariant()

if ($expectedHash -ne $actualHash) {
    Write-Host "Upstream PSDToolKit.lua has changed."
    Write-Host "Expected: $expectedHash"
    Write-Host "Actual:   $actualHash"
    exit 1
}
