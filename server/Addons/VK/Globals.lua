--[[
    Created by Daniel W (Vitex#1248)
]]--

package.path = ';?.lua;./Addons/VK/?.lua;' .. package.path
package.path = ';?.lua;./Addons/VK/Server/?.lua;' .. package.path
package.path = './Addons/VK/Server/Extensions/VK_Moderation/?.lua;./Addons/VK/Server/Extensions/VK_Moderation/Commands/?.lua;' .. package.path
package.path = './Addons/VK/ClientLua/?.lua;' .. package.path
package.path = './Addons/VK/Server/Extensions/VK_Roleplay/?.lua;./Addons/VK/Server/Extensions/VK_Roleplay/Commands/?.lua;' .. package.path
package.path = './Addons/VK/Server/Extensions/VK_Debug/?.lua;' .. package.path

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

_Extensions = {}

G_Environment = {
    time = {
        dayscale = 0.5,
        nightScale = 0.5,
        azimuthOverride = 0,
        dayLength = 1800,
        time = 0.80599999427795,
        play = false
    },

    wind = {
        x = 0,
        y = 0,
        z = 0
    },

    weather = {
        rain = 0
    }
}

function G_LuaFormat(str)
    local lua = string.gsub(str, '    ', ' ')
    lua = string.gsub(lua, '\n', ' ')
    return lua
end

--[[ Utility Functions ]]--
function G_Try(f, catch_f)
    local result, exception = pcall(f)
    if not result then
        if catch_f then catch_f(exception) end
    end

    return exception
end

function G_ReloadModules(modules, filename)
    filename = filename or ''

    for module_name, _ in pairs(modules) do
        if package.loaded[module_name] then
            package.loaded[module_name] = nil
            GDLog('[Module] [%s] Reloaded %s', filename, module_name)
        else
            GDLog('[Module] [%s] Loaded %s', filename, module_name)
        end

        modules[module_name] = require(module_name)
    end

    return modules
end

function G_ReloadExtensions(extensions, filename)
    local Utilities = require('Addons.VK.Utilities')
    filename = filename or ''

    for _, ext in pairs(Utilities.GetKey('Addons\\VK\\Settings\\Extensions.json', 'Extensions')) do
        if package.loaded[string.format('Addons.VK.Server.Extensions.%s.%s', ext, ext)] then
            package.loaded[string.format('Addons.VK.Server.Extensions.%s.%s', ext, ext)] = nil
            GDLog('[Extension] [%s] Reloaded %s', filename, ext)
        else
            GDLog('[Extension] [%s] Loaded %s', filename, ext)
        end

        extensions[string.format('Addons.VK.Server.Extensions.%s.%s', ext, ext)] = require(string.format('Addons.VK.Server.Extensions.%s.%s', ext, ext))
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

--[[ Logging Utilities ]]--
function GLog(message, ...)
    local Utilities = require('Addons.VK.Utilities')

    if type(message) == 'string' then
        print('['..Utilities.GetDateTime()..'] ' .. tostring(string.format(message, ...)))
    else
        print('['..Utilities.GetDateTime()..'] [Error] Invalid Message {type: ' .. tostring(type(message)) .. ', data: ' .. tostring(message) .. '}')
        for k, v in pairs(message) do
            print('-> ' .. k .. ' : ' .. tostring(v))
        end
    end
end

function GDLog(debug, ...) if G_Level == G_LevelDebug then GLog('[DEBUG]: ' .. tostring(debug), ...) end end -- Debug Log
function GILog(info, ...) GLog('[INFO]: ' .. tostring(info), ...) end -- Information Log
function GELog(error, ...) GLog('[ERRO]: ' .. tostring(error), ...) end -- Error Log
function GWLog(warning, ...) GLog('[WARN]: ' .. tostring(warning), ...) end -- Warning Log
function GFLog(fatal, ...) GLog('[FATAL]: ' .. tostring(fatal), ...) os.execute('pause') os.exit(1) end -- Fatal Log