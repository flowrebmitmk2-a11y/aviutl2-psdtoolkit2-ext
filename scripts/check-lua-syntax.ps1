param(
    [string]$Target = "data/Script/PSDToolKitExt.lua"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$resolvedTarget = Join-Path $repoRoot $Target

$compilerCandidates = @(
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

$interpreterCandidates = @(
    "lua",
    "lua54",
    "lua53",
    "lua52",
    "lua51",
    "lua5.4",
    "lua5.3",
    "lua5.2",
    "lua5.1"
)

$compiler = $null
foreach ($candidate in $compilerCandidates) {
    $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($cmd) {
        $compiler = $cmd.Source
        break
    }
}

$interpreter = $null
if (-not $compiler) {
    foreach ($candidate in $interpreterCandidates) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd) {
            $interpreter = $cmd.Source
            break
        }
    }
}

if (-not (Test-Path $resolvedTarget)) {
    throw "Lua file not found: $resolvedTarget"
}

if ($compiler) {
    Write-Host "Using Lua compiler: $compiler"
    Write-Host "Checking $resolvedTarget"
    & $compiler -p $resolvedTarget
    if ($LASTEXITCODE -ne 0) {
        throw "Lua syntax check failed: $resolvedTarget"
    }
    exit 0
}

if ($interpreter) {
    Write-Host "Using Lua interpreter: $interpreter"
    Write-Host "Checking $resolvedTarget"
    & $interpreter -e "local f, err = loadfile(arg[1]); if not f then io.stderr:write(err .. '\n'); os.exit(1) end" $resolvedTarget
    if ($LASTEXITCODE -ne 0) {
        throw "Lua syntax check failed: $resolvedTarget"
    }
    exit 0
}

throw "Lua compiler or interpreter not found. Tried compilers: $($compilerCandidates -join ', ') / interpreters: $($interpreterCandidates -join ', ')"
