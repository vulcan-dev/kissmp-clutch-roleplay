--[[
    Created by Daniel W (Vitex#1248)
]]--

package.path = ';?.lua;./Addons/VK/?.lua;' .. package.path
package.path = ';?.lua;./Addons/VK/Server/?.lua;' .. package.path
package.path = './Addons/VK/Server/Extensions/VK_Moderation/?.lua;./Addons/VK/Server/Extensions/VK_Moderation/Commands/?.lua;' .. package.path
package.path = './Addons/VK/Client/?.lua;' .. package.path
package.path = './Addons/VK/Server/Extensions/VK_Roleplay/?.lua;./Addons/VK/Server/Extensions/VK_Roleplay/Commands/?.lua;' .. package.path
package.path = './Addons/VK/Server/Extensions/VK_Debug/?.lua;' .. package.path

--[[ Clients and Player Count ]]--
G_Clients = {}
G_CurrentPlayers = 0

--[[ Logging Levels ]]--
G_Level = 0
G_LevelInfo = 1
G_LevelDebug = 2
G_LevelError = 3
G_LevelFatal = 4

G_Uptime = 0
G_Cooldown = 0

G_TimedEvents = {}
G_Commands = {}

_Extensions = {}

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

--[[ Logging Utilities ]]--
-- function GLog(message, ...)
--     local Utilities = require('Addons.VK.Utilities')

--     if type(message) == 'string' then
--         print('['..Utilities.GetDateTime()..'] ' .. tostring(string.format(message, ...)))
--     else
--         print('['..Utilities.GetDateTime()..'] [Error] Invalid Message {type: ' .. tostring(type(message)) .. ', data: ' .. tostring(message) .. '}')
--         for k, v in pairs(message) do
--             print('-> ' .. k .. ' : ' .. tostring(v))
--         end
--     end
-- end

-- function GDLog(debug, ...) if G_Level == G_LevelDebug then GLog('[DEBUG]: ' .. tostring(debug), ...) end end -- Debug Log
-- function GILog(info, ...) GLog('[INFO]: ' .. tostring(info), ...) end -- Information Log
-- function GELog(error, ...) GLog('[ERRO]: ' .. tostring(error), ...) end -- Error Log
-- function GWLog(warning, ...) GLog('[WARN]: ' .. tostring(warning), ...) end -- Warning Log
-- function GFLog(fatal, ...) GLog('[FATAL]: ' .. tostring(fatal), ...) os.execute('pause') os.exit(1) end -- Fatal Log

function DateTime(format, time)
    format = format or '%Y-%m-%d %H:%M:%S'
    return os.date(format, time)
end

function GLog(message, ...)  if type(message) == 'table' then for k, v in pairs(message) do print(k .. ' ' .. tostring(v)) end end print(string.format('[%s]  [kissmp_server:vk] %s', DateTime('%H:%M:%S'), string.format(message, ...))) end
function GDLog(message, ...) message = tostring(string.format('[ DEBUG]: %s', message)) if G_Level == G_LevelDebug then GLog(message, ...) end end
function GILog(message, ...) message = tostring(string.format('[ INFO]: %s', message)) GLog(message, ...) end
function GWLog(message, ...) message = tostring(string.format('[ WARN]: %s', message)) GLog(message, ...) end
function GELog(message, ...) message = tostring(string.format('[ ERROR]: %s', message)) GLog(message, ...) end
function GFLog(message, ...) message = tostring(string.format('[ FATAL]: %s', message)) GLog(message, ...) os.execute('pause') os.exit(1) end