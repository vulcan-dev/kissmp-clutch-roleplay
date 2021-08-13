require('Addons.VK.globals')

-- Local Variables --
local M = {}
local nextUpdate = 0

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    Moderation = require('Addons.VK.Server.Extensions.VK_Moderation.Moderation'),
    TimedEvents = require('Addons.VK.TimedEvents'),
    Server = require('Addons.VK.Server'),

    CommandModeration = require('Addons.VK.Server.Extensions.VK_Moderation.Commands.CommandModeration'),
    CommandUtilities = require('Addons.VK.Server.Extensions.VK_Moderation.Commands.CommandUtilities'),
    CommandFun = require('Addons.VK.Server.Extensions.VK_Moderation.Commands.CommandFun'),

    cl_environment = require('Addons.VK.ClientLua.cl_environment')
    -- cl_menu = require('Addons.VK.ClientLua.cl_menu')
}

M.Callbacks = {
    ['VK_PlayerConnect'] = function(client_id)
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
        local ban = Modules.Moderation.IsBanned(client.user:getSecret())
        if ban.time ~= nil and ban.time > 0 then -- User is banned
            if ban.time <= os.time() then -- Unban the mf
                GDLog('You have been unbanned')
                Modules.Moderation.removeBan(client.user:getSecret(), ban.name)
            else
                client.user:kick(string.format('You are banned from this Server. Unban date: %s', os.date('%Y-%m-%d %H:%M:%S', ban.time)))
                GDLog('You are banned from this Server. Unban date: %s', os.date('%Y-%m-%d %H:%M:%S', ban.time))
            end
        end

        --[[ Tell them to read the rules if they're new to the server ]]--
        if client.getKey('playtime') <= 0 then
            Modules.Server.SendChatMessage(client.user:getID(), 'Make sure to read the rules at /discord before continuing', Modules.Server.ColourSuccess)
        end
    end,

    ['VK_PlayerDisconnect'] = function(client)
        GILog('[Player] %s has Disconnected', client.user:getName())
    end,

    ['VK_VehicleSpawn'] = function(vehicle_id, client_id)
        local vehicle = vehicles[vehicle_id]

        local can_drive = true
        local blacklist = Modules.Utilities.GetKey(G_BlacklistLocation)
        for k, v in pairs(blacklist) do
            if k == vehicle:getData():getName() then
                if type(v) == 'boolean' then
                    Modules.Server.DisplayDialogError(G_Clients[client_id], G_ErrorVehicleBlacklisted)
                    vehicle:remove()

                    G_Clients[client_id].vehicleCount = G_Clients[client_id].vehicleCount - 1
                    G_Clients[client_id].user:sendLua('commands.setFreeCamera()')
                    return
                elseif type(v) == 'table' then
                    for _, role in pairs(v) do
                        if not Modules.Moderation.HasRole(G_Clients[client_id], role) then
                            can_drive = false
                        else
                            can_drive = true
                        end
                    end
                end
            end
        end

        if can_drive then
            G_Clients[client_id].user:sendLua(Modules.cl_environment.setWind({x = G_Environment.wind.x, y = G_Environment.wind.y, z = G_Environment.wind.z}))

            if (vehicle:getData():getName() ~= 'unicycle') then
                Modules.Server.SendChatMessage(string.format('[Vulcan-Moderation] %s has spawned a %s', G_Clients[client_id].user:getName(), vehicle:getData():getName()), Modules.Server.ColourWarning)
            end
        else
            Modules.Server.DisplayDialogError(G_Clients[client_id], G_ErrorInvalidVehiclePermissions)
            vehicle:remove()

            G_Clients[client_id].vehicleCount = G_Clients[client_id].vehicleCount - 1
            G_Clients[client_id].user:sendLua('commands.setFreeCamera()')
        end
    end,

    ['VK_VehicleReset'] = function(vehicle_id, client_id)
        G_Clients[client_id].user:sendLua(Modules.cl_environment.setWind({x = G_Environment.wind.x, y = G_Environment.wind.y, z = G_Environment.wind.z}))
        return ""
    end,

    ['VK_OnStdIn'] = function(message)
        if string.sub(message, 1, 1) == '/' then
            local args = Modules.Utilities.ParseCommand(message, ' ')
            args[1] = args[1]:sub(2)

            local command = G_Commands[args[1]]

            if command then
                table.remove(args, 1)
                command.exec(Modules.Server.GetUser(1337).data, args)
            end
        end
    end,

    ['VK_Tick'] = function()
        if os.time() >= nextUpdate then
            nextUpdate = os.time() + 5

            for _, client in pairs(G_Clients) do
                if client.connected then
                    if client.user:getID() ~= 1337 then
                        --[[ Update Playtime ]]
                        client.editKey('playtime', client.getKey('playtime') + 5)
                        if client.getKey('playtime') >= 240 * 60 then
                            if client.rank() == Modules.Moderation.RankUser then
                                client.editKey('rank', Modules.Moderation.RankTrusted)
                                Modules.Server.SendChatMessage(string.format('%s is now a trusted member, thanks for playing.', client.user:getName()), Modules.Server.ColourSuccess)
                            end
                        end
                    end
                end
            end
        end
    end,

    ['[VK_Moderation] ReloadModules'] = function()
        Modules = G_ReloadModules(Modules, 'VK_Moderation.lua')
        for _, module in pairs(Modules) do
            if module.ReloadModules then
                module.ReloadModules()
            end
        end

        G_AddCommandTable(Modules.CommandModeration.Commands)
        G_AddCommandTable(Modules.CommandUtilities.Commands)
        G_AddCommandTable(Modules.CommandFun.Commands)
    end
}

return M