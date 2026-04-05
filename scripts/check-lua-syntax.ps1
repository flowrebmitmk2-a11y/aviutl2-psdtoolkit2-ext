param(
    [string]$LuaCompiler = "luac",
    [string]$Target = "src/PSDToolKit.lua"
)

$ErrorActionPreference = "Stop"

& $LuaCompiler -p $Target
if ($LASTEXITCODE -ne 0) {
    throw "Lua syntax check failed: $Target"
}
