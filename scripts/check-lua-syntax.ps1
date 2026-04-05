param(
    [string]$LuaCommand = "lua",
    [string]$Target = "src/PSDToolKit.lua"
)

$ErrorActionPreference = "Stop"

& $LuaCommand -p $Target
