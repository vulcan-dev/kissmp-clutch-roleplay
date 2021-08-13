require('Addons.VK.globals')

local M = {}

local Modules = {
    Moderation = require('Addons.VK.Server.Extensions.VK_Moderation.Moderation'),
    Utilities = require('Addons.VK.Utilities')
}

local function GetCommands()
    local output = ''

    for commandName, commandTable in pairs(G_Commands) do
output = output .. string.format([[

[ %s ] Command: %s
Usage: %s
Rank: %s

]], commandTable.category, commandName, commandTable.usage, Modules.Moderation.StrRanks[commandTable.rank])
    end

    GDLog(output)
end

local function GetMemoryUsage()
    GDLog('Memory Usage: %.3f KB', collectgarbage('count'))
end

local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'debug.lua')
end

--[[ Return ]]
M.GetCommands = GetCommands
M.GetMemoryUsage = GetMemoryUsage

M.ReloadModules = ReloadModules

return M