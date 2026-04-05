param(
    [string]$Target = "src/PSDToolKit.lua"
)

$ErrorActionPreference = "Stop"

$candidates = @(
    "luac",
    "luac54",
    "luac53",
    "luac52",
    "luac51",
    "luac5.4",
    "luac5.3",
    "luac5.2",
    "luac5.1"
)

$compiler = $null
foreach ($candidate in $candidates) {
    $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($cmd) {
        $compiler = $cmd.Source
        break
    }
}

if (-not $compiler) {
    throw "Lua compiler not found. Tried: $($candidates -join ', ')"
}

Write-Host "Using Lua compiler: $compiler"
& $compiler -p $Target
if ($LASTEXITCODE -ne 0) {
    throw "Lua syntax check failed: $Target"
}
