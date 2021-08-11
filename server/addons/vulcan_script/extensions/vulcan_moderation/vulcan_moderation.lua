--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

-- Local Variables --
local M = {}
local nextUpdate = 0

local modules = {
    utilities = require('addons.vulcan_script.utilities'),
    moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation'),
    timed_events = require('addons.vulcan_script.timed_events'),
    server = require('addons.vulcan_script.server'),

    cmd_moderation = require('addons.vulcan_script.extensions.vulcan_moderation.commands.cmd_moderation'),
    cmd_utilities = require('addons.vulcan_script.extensions.vulcan_moderation.commands.cmd_utilities'),
    cmd_fun = require('addons.vulcan_script.extensions.vulcan_moderation.commands.cmd_fun'),

    cl_environment = require('addons.vulcan_script.client_lua.cl_environment')
    -- cl_menu = require('addons.vulcan_script.client_lua.cl_menu')
}

M.callbacks = {
    VK_PlayerConnect = function(client_id)
        local client = G_Clients[client_id]

        -- Check for new alias
        local alias_found = false
        local aliases = {}

        for name, alias in pairs(client.getKey('alias')) do
            aliases[name] = alias
            if alias == client.user:getName() then
                alias_found = true
            end
        end

        if not alias_found then
            table.insert( aliases, client.user:getName() )
            client.editKey('alias', aliases)
        end

        -- Check if banned
        local ban = modules.moderation.IsBanned(client.user:getSecret())
        if ban.time ~= nil and ban.time > 0 then -- User is banned
            if ban.time <= os.time() then -- Unban the mf
                GDLog('You have been unbanned')
                modules.moderation.removeBan(client.user:getSecret(), ban.name)
            else
                client.user:kick(string.format('You are banned from this server. Unban date: %s', os.date('%Y-%m-%d %H:%M:%S', ban.time)))
                GDLog('You are banned from this server. Unban date: %s', os.date('%Y-%m-%d %H:%M:%S', ban.time))
            end
        end

        --[[ Tell them to read the rules if they're new to the server ]]--
        if client.getKey('playtime') <= 0 then
            modules.server.SendChatMessage(client.user:getID(), 'Make sure to read the rules at /discord before continuing', modules.server.ColourSuccess)
        end
    end,

    VK_PlayerDisconnect = function(client)
        GILog('[Player] %s has Disconnected', client.user:getName())
    end,

    VK_VehicleSpawn = function(vehicle_id, client_id)
        local vehicle = vehicles[vehicle_id]

        local can_drive = true
        local blacklist = modules.utilities.GetKey(G_BlacklistLocation)
        for k, v in pairs(blacklist) do
            if k == vehicle:getData():getName() then
                if type(v) == 'boolean' then
                    modules.server.DisplayDialogError(G_Clients[client_id], G_ErrorVehicleBlacklisted)
                    vehicle:remove()

                    G_Clients[client_id].vehicleCount = G_Clients[client_id].vehicleCount - 1
                    G_Clients[client_id].user:sendLua('commands.setFreeCamera()')
                    return
                elseif type(v) == 'table' then
                    for _, role in pairs(v) do
                        if not modules.moderation.HasRole(G_Clients[client_id], role) then
                            can_drive = false
                        else
                            can_drive = true
                        end
                    end
                end
            end
        end

        if can_drive then
            G_Clients[client_id].user:sendLua(modules.cl_environment.setWind({x = G_Environment.wind.x, y = G_Environment.wind.y, z = G_Environment.wind.z}))

            if (vehicle:getData():getName() ~= 'unicycle') then
                modules.server.SendChatMessage(string.format('[Vulcan-Moderation] %s has spawned a %s', G_Clients[client_id].user:getName(), vehicle:getData():getName()), modules.server.ColourWarning)
            end
        else
            modules.server.DisplayDialogError(G_Clients[client_id], G_ErrorInvalidVehiclePermissions)
            vehicle:remove()

            G_Clients[client_id].vehicleCount = G_Clients[client_id].vehicleCount - 1
            G_Clients[client_id].user:sendLua('commands.setFreeCamera()')
        end
    end,

    VK_VehicleReset = function(vehicle_id, client_id)
        G_Clients[client_id].user:sendLua(modules.cl_environment.setWind({x = G_Environment.wind.x, y = G_Environment.wind.y, z = G_Environment.wind.z}))
        return ""
    end,

    VK_OnStdIn = function(message)
        if string.sub(message, 1, 1) == '/' then
            G_CommandExecuted = true
            local args = modules.utilities.ParseCommand(message, ' ')
            args[1] = args[1]:sub(2)

            local command = G_Commands[args[1]]

            if command then
                table.remove(args, 1)
                command.exec(modules.server.GetUser(1337).data, args)
            end
            G_CommandExecuted = false
        end
    end,
    
    VK_Tick = function()
        if os.time() >= nextUpdate then
            nextUpdate = os.time() + 5
            
            for _, client in pairs(G_Clients) do
                if client.connected then
                    if client.user:getID() ~= 1337 then
                        --[[ Update Playtime ]]
                        client.editKey('playtime', client.getKey('playtime') + 5)
                        if client.getKey('playtime') >= 240 * 60 then
                            if client.rank() == modules.moderation.RankUser then
                                client.editKey('rank', modules.moderation.RankTrusted)
                                modules.server.SendChatMessage(string.format('%s is now a trusted member, thanks for playing.', client.user:getName()), modules.server.ColourSuccess)
                            end
                        end
                    end
                end
            end
        end
    end
}

local function ReloadModules()
    modules = G_ReloadModules(modules, 'vulcan_moderation.lua')
    for _, module in pairs(modules) do
        if module.ReloadModules then
            module.ReloadModules()
        end
    end

    G_AddCommandTable(modules.cmd_moderation.commands)
    G_AddCommandTable(modules.cmd_utilities.commands)
    G_AddCommandTable(modules.cmd_fun.commands)

end

M.callbacks = M.callbacks
M.ReloadModules = ReloadModules

return M