require('addons.vulcan_script.globals')

local M = {}

local modules = {
    moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation'),
    utilities = require('addons.vulcan_script.utilities')
}

local function GetCommands()
    local output = ''

    for commandName, commandTable in pairs(G_Commands) do
output = output .. string.format([[

[ %s ] Command: %s
Usage: %s
Rank: %s

]], commandTable.category, commandName, commandTable.usage, modules.moderation.StrRanks[commandTable.rank])
    end

    modules.utilities.LogDebug(output)
end

local function GetMemoryUsage()
    modules.utilities.LogDebug('Memory Usage: %.3f KB', collectgarbage('count'))
end

local function ReloadModules()
    modules = G_ReloadModules(modules, 'debug.lua')
end

--[[ Return ]]
M.GetCommands = GetCommands
M.GetMemoryUsage = GetMemoryUsage

M.ReloadModules = ReloadModules

return M