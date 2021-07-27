--[[
    Created by Daniel W (Vitex#1248)
]]

package.path = ';?.lua;./addons/vulcan_script/?.lua;./addons/vulcan_script/extensions/vulcan_moderation/?.lua;./addons/vulcan_script/extensions/vulcan_moderation/commands/?.lua;' .. package.path
package.path = './addons/vulcan_script/extensions/vulcan_rp/?.lua;./addons/vulcan_script/extensions/vulcan_rp/commands/?.lua;' .. package.path
package.path = './addons/vulcan_script/extensions/vulcan_debug/?.lua;' .. package.path

--[[ Clients and Player Count ]]--
G_Clients = {}
G_CurrentPlayers = 0

--[[ Logging Levels ]]--
G_LevelInfo = 1
G_LevelDebug = 2
G_LevelError = 3
G_LevelFatal = 4

G_Level = G_LevelDebug

--[[ Verbose & Log File ]]--
G_Verbose = nil
G_LogFile = nil

--[[ Links ]]--
G_DiscordLink = 'https://discord.gg/mrsxbNFSRp'
G_PatreonLink = ''

G_Uptime = 0
G_Cooldown = 0
G_API = true

G_TimedEvents = {}
G_Commands = {}
G_CommandExecuted = false

G_FirstLoad = true

--[[ Utility Functions ]]--
function G_Try(f, catch_f)
    local result, exception = pcall(f)
    if not result then
        if catch_f then catch_f(exception) end
    end

    return exception
end

function G_ReloadModules(modules, filename)
    local utilities = require('addons.vulcan_script.utilities')
    filename = filename or ''

    for module_name, _ in pairs(modules) do
        if package.loaded[module_name] then
            package.loaded[module_name] = nil
            utilities.LogDebug('[Module] [%s] Reloaded %s', filename, module_name)
        else
            utilities.LogDebug('[Module] [%s] Loaded %s', filename, module_name)
        end

        modules[module_name] = require(module_name)
    end

    return modules
end

function G_ReloadExtensions(extensions, filename)
    local utilities = require('addons.vulcan_script.utilities')
    filename = filename or ''

    for _, ext in pairs(utilities.GetKey(G_ServerLocation, 'options', 'extensions')) do
        if package.loaded[string.format('addons.vulcan_script.extensions.%s.%s', ext, ext)] then
            package.loaded[string.format('addons.vulcan_script.extensions.%s.%s', ext, ext)] = nil
            utilities.LogDebug('[Extension] [%s] Reloaded %s', filename, ext)
        else
            utilities.LogDebug('[Extension] [%s] Loaded %s', filename, ext)
        end

        extensions[string.format('addons.vulcan_script.extensions.%s.%s', ext, ext)] = require(string.format('addons.vulcan_script.extensions.%s.%s', ext, ext))
    end

    return extensions
end

--[[ G_DisplayDialog Errors ]]--
G_ErrorInvalidUser = 0
G_ErrorInvalidArguments = 1
G_ErrorInvalidMessage = 2
G_ErrorVehicleBlacklisted = 3
G_ErrorInvalidVehiclePermissions = 4
G_ErrorInsufficentPermissions = 5
G_ErrorCannotPerformUser = 6
G_ErrorNotInVehicle = 7

G_Errors = {
    [G_ErrorInvalidUser] = 'Invalid user specified',
    [G_ErrorInvalidArguments] = 'Invalid arguments',
    [G_ErrorInvalidMessage] = 'Invalid message specified',
    [G_ErrorVehicleBlacklisted] = 'This vehicle is blacklisted',
    [G_ErrorInvalidVehiclePermissions] = 'You do not have the required permissions to drive this vehicle',
    [G_ErrorInsufficentPermissions] = 'You do not have the required permissions to perform this action',
    [G_ErrorCannotPerformUser] = 'You do not have the required permissions to perform this action on this user',
    [G_ErrorNotInVehicle] = 'User is not in a vehicle'
}

--[[ Command Utilites ]]--
function G_AddCommandTable(table)
    for key, value in pairs(table) do
        G_Commands[key] = value
    end
end

function G_RemoveCommandTable(table)
    for key, _ in pairs(table) do
        G_Commands[key] = nil
    end
end