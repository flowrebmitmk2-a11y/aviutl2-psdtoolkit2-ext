param(
    [string]$UpstreamUrl = $env:UPSTREAM_PSDTOOLKIT_URL,
    [string]$Target = "src/PSDToolKit.lua"
)

$ErrorActionPreference = "Stop"

if (-not $UpstreamUrl) {
    Write-Host "UPSTREAM_PSDTOOLKIT_URL is not set. Skipping upstream check."
    exit 0
}

$tmpRoot = Join-Path (Split-Path -Parent $PSScriptRoot) "_tmp"
$tmpFile = Join-Path $tmpRoot "PSDToolKit.lua"
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
Invoke-WebRequest -Uri $UpstreamUrl -OutFile $tmpFile

if (Compare-Object (Get-Content $Target) (Get-Content $tmpFile)) {
    Write-Host "Upstream PSDToolKit.lua differs from the tracked copy."
    exit 1
}
