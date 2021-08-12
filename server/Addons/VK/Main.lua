--[[
    Created by Daniel W (Vitex#1248)
]]

require('Addons.VK.globals')

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    TimedEvents = require('Addons.VK.TimedEvents'),
    Server = require('Addons.VK.Server'),

    cl_environment = require('Addons.VK.ClientLua.cl_environment'),
    cl_player_join = require('Addons.VK.ClientLua.cl_player_join'),
}

local extensions = {}
local nextUpdate = 0
local prefix = '/'

-- [[ ==================== Hooking Start ==================== ]] --
hooks.register('OnPlayerConnected', 'VK_PLAYER_CONNECT', function(client_id)
    --[[ Create new User Object if it doesn't exist ]]--
    if not Modules.Utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'rank', G_LevelError, true, true) then
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'rank', 0)
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'warns', {})
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'alias', {connections[client_id]:getName()})
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'bans', {})
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'vehicleLimit', 2)
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'mute_time', 0)
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'playtime', 0)
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'blockList', {})
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'home', {x=709.3377075195312, y=-0.7625573873519897, z=52.24008560180664, xr=-0.006330838892608881, yr=-0.00027202203636989, zr=-0.25916287302970886, w=0.9658128619194032})

        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'roles', {})
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'money', 240)
        Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'onduty', false)

        GILog('Creating new user object for %s', connections[client_id]:getName())
    end

    --[[ Add Client to Table ]]--
    Modules.Server.AddClient(client_id)
    local client = G_Clients[client_id]

    GILog('%s is connecting [ %s ]', client.user:getName(), connections[client_id]:getSecret())

    Modules.Server.IsConnected(client, client.user:getName(), function()
        --[[ Connected ]]--
        GILog("%s has connected", client.user:getName())
        Modules.Server.DisplayDialog(client, string.format('%s has joined!', client.user:getName()), 3)

        --[[ Send Webhook ]]--
        Modules.Utilities.SendAPI({
            client = {
                name = client.user:getName()
            },

            data = 'Connected',
            type = 'user_join_leave'
        })

        --[[ Kick if Unknown (Specified in Server.json) ]]
        if Modules.Utilities.GetKey(G_ServerLocation, 'options', 'kick_unknown') and client.user:getName() == 'Unknown' then
            client.user:kick('Please join back with a different name')
        end

        --[[ Set Client Global Variables ]]--
        client.user:sendLua(Modules.cl_player_join.SetGlobals())

        --[[ Set Time of Day ]]--
        client.user:sendLua(string.format('extensions.core_environment.setTimeOfDay({dayscale=%s,nightScale=%s,azimuthOverride=%s,dayLength=%s,time=%s,play=%s})',
            G_Environment.time.dayscale,
            G_Environment.time.nightScale,
            G_Environment.time.azimuthOverride,
            G_Environment.time.dayLength,
            G_Environment.time.time,
            G_Environment.time.play
        ))

        GDLog('rainAmount = ' .. tostring(G_Environment.weather.rain))
        if G_Environment.weather.rain ~= 0 then
            client.user:sendLua(Modules.cl_environment.setPrecipitation(G_Environment.weather.rain))
        end

        --[[ Create Waypoints ]]--
        Modules.Server.InitializeMarkers(client)

        client.user:sendLua('kissui.force_disable_nametags = true')

        --[[ User Help ]]--
        Modules.Server.SendChatMessage(client.user:getID(), 'Use /help for a list of commands (only show for your rank)', Modules.Server.ColourSuccess)
        Modules.Server.SendChatMessage(client.user:getID(), 'KissMP 0.4.5 is currently buggy, please download the fixed version from /discord or KissMP\'s Github', Modules.Server.ColourSuccess)

        --[[ Load Extension Hook VK_PlayerConnect ]]--
        for _, extension in pairs(extensions) do
            if extension.callbacks and extension.callbacks.VK_PlayerConnect then
                extension.callbacks.VK_PlayerConnect(client_id)
            end
        end
    end)
end)

hooks.register('OnPlayerDisconnected', 'VK_PLAYER_DISCONNECT', function(client_id)
    local oldClient = G_Clients[client_id]
    G_Clients[client_id].connected = false
    Modules.Server.RemoveClient(client_id)

    GILog("%s has Disconnected [ %s ]", oldClient.user:getName(), oldClient.user:getSecret())

    Modules.Utilities.SendAPI({
        client = {
            name = oldClient.user:getName()
        },

        data = 'Disconnected',
        type = 'user_join_leave'
    })

    --[[ Load Extension Hook VK_PlayerDisconnect ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_PlayerDisconnect then
            extension.callbacks.VK_PlayerDisconnect(oldClient)
        end
    end

    oldClient = nil
end)

hooks.register('OnVehicleSpawned', 'VK_PLAYER_VEHICLE_SPAWN', function(vehicle_id, client_id)
    local client = G_Clients[client_id]
    if vehicles[vehicle_id]:getData():getName() ~= 'unicycle' then
        client.vehicles.count = client.vehicles.count + 1
        Modules.Utilities.SendAPI({
            client = {
                name = G_Clients[client_id].user:getName()
            },

            data = 'Spawned a ' .. vehicles[vehicle_id]:getData():getName(),
            type = 'vehicle_log'
        })

        client.vehicles.add(client, vehicle_id)
    end


    --[[ Load Extension Hook VK_VehicleSpawn ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_VehicleSpawn then
            extension.callbacks.VK_VehicleSpawn(vehicle_id, client_id)
        end
    end
end) -- Vehicle Spawned

hooks.register('OnVehicleRemoved', 'VK_PLAYER_VEHICLE_REMOVED', function(vehicle_id, client_id)
    if vehicles[vehicle_id] and vehicles[vehicle_id]:getData():getName() ~= 'unicycle' then
        G_Try(function()
            G_Clients[client_id].vehicles.count = G_Clients[client_id].vehicles.count - 1
        end)
    end

    --[[ Load Extension Hook VK_VehicleRemoved ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_VehicleRemoved then
            extension.callbacks.VK_VehicleRemoved(vehicle_id, client_id)
        end
    end
end)

hooks.register('OnVehicleResetted', 'VK_PLAYER_VEHICLE_RESET', function(vehicle_id, client_id)
    --[[ Load Extension Hook VK_VehicleReset ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_VehicleReset then
            extension.callbacks.VK_VehicleReset(vehicle_id, client_id)
        end
    end
end)

hooks.register('OnChat', 'VK_PLAYER_CHAT', function(client_id, message)
    local executor = G_Clients[client_id]

    --[[ Check if the Client is Muted ]]--
    local mute_time = G_Clients[client_id].getKey('mute_time')
    if mute_time ~= nil and mute_time > 0 then
        if mute_time <= os.time() then
            executor.editKey('mute_time', 0)
        else
            Modules.Server.SendChatMessage(executor.user:getID(), 'You are muted', Modules.Server.ColourError)
            return ""
        end
    end

    --[[ Check if Command ]]
    if string.sub(message, 1, 1) == '@' then
        local args = Modules.Utilities.ParseCommand(message, ' ')
        args[1] = string.lower(args[1]:sub(2))
        string.gsub(args[1], '@', '')

        local client = Modules.Server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        local message = Modules.Utilities.GetMessage(args)

        -- Check if message is valid
        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        Modules.Server.SendChatMessage(string.format('%s @%s: %s', executor.user:getName(), client.user:getName(), message), Modules.Server.ColourMention)
    else if string.sub(message, 1, 1) == prefix then
        G_CommandExecuted = true
        local args = Modules.Utilities.ParseCommand(message, ' ')
        args[1] = string.lower(args[1]:sub(2))

        local command = G_Commands[args[1]]
        if not command then
            for _, cmd in pairs(G_Commands) do
                if args[1] == cmd.alias then
                    command = cmd
                    break
                end
            end
        end

        local canExecuteWithRole = false
        if command and command.roles then
            for _, role in pairs(command.roles) do
                if Modules.Roleplay.HasRole(executor, role) then
                    canExecuteWithRole = true
                end
            end
        end

        if command and command.roles and canExecuteWithRole or command and not command.roles and not canExecuteWithRole then
            if executor.rank() >= command.rank then
                --[[ Check current vehicle ]]--
                table.remove(args, 1)
                G_Try(function ()
                    command.exec(executor, args)
                end, function(err)
                    Modules.Server.SendChatMessage(executor.user:getID(), string.format('[ %s Failed. Please post it in bug-reports in /discord ] Message: %s', message, err), Modules.Server.ColourError)
                    GELog('Command failed! User: %s\n  Message: %s', executor.user:getName(), err)
                    G_CommandExecuted = false
                    return ""
                end)
            end
        else
            if command and command.roles and not canExecuteWithRole then
                Modules.Server.DisplayDialogError(executor, G_ErrorInsufficentPermissions)
            else
                Modules.Server.SendChatMessage(executor.user:getID(), 'Invalid Command, please use /help', Modules.Server.ColourWarning)
            end
        end
    else
        Modules.Utilities.SendAPI({
            client = {
                name = executor.user:getName()
            },

            data = message,
            type = 'user_message'
        })

        Modules.Moderation.SendUserMessage(executor, 'OOC', message, true)
    end end

    --[[ Load Extension Hook VK_OnMessageReceive ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_OnMessageReceive then
            extension.callbacks.VK_OnMessageReceive(client_id, message)
        end
    end

    return ""
end) -- OnChat

hooks.register('OnStdIn', 'VK_PLAYER_STDIN', function(input);
    --[[ Reload all Modules ]]--
    if input == '!rl' then
        G_ServerLocation = './addons/VK/Settings/Server.json'

        G_PlayersLocation = './addons/VK/Settings/Players.json'
        G_ColoursLocation = './addons/VK/Settings/Colours.json'

        --[[ Load all Extensions ]]--
        Modules.Moderation = require('Addons.VK.Extensions.VK_Moderation.Moderation')
        Modules.Roleplay = require('Addons.VK.Extensions.VK_Roleplay.Roleplay')
        extensions = G_ReloadExtensions(extensions, 'Main.lua')
        Modules = G_ReloadModules(Modules, 'Main.lua')

        -- for _, client in pairs(G_Clients) do
        --     if client.rank() >= Modules.Moderation.RankModerator then
        --         if client.renderMenu then
        --             client.user:sendLua(Modules.cl_menu.ToggleMenu(client))
        --         end
        --     end
        -- end

        --[[ Load all Extension Modules ]]--
        for _, v in pairs(extensions) do
            v.ReloadModules()
        end
    end

    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_OnStdIn then
            extension.callbacks.VK_OnStdIn(input)
        end
    end
end)

hooks.register("Tick", "VK_TICK", function()
    Modules.TimedEvents.Update()

    --[[ Garbage Debugging ]]--
    if os.time() > nextUpdate then
        nextUpdate = os.time() + 4
        collectgarbage("collect")
    end

    -- Server uptime
    G_Uptime = G_Uptime + 1

    -- Update extension hook
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_Tick then
            extension.callbacks.VK_Tick(1 - 60)
        end
    end
end)
-- [[ ==================== Hooking End ==================== ]] --

local function Initialize()
    if G_FirstLoad then
        --[[ Make sure to change the log level if you don't want console spam :) ]]--
        G_Level = G_LevelDebug
        GILog('[Server] Initialized')

        Modules = G_ReloadModules(Modules, 'main.lua')

        --[[ Load all Extensions ]]--
        extensions = G_ReloadExtensions(extensions, 'main.lua')

        --[[ Load all Extension Modules ]]--
        for _, v in pairs(extensions) do
            v.ReloadModules()
        end

        G_Verbose = Modules.Utilities.GetKey(G_ServerLocation, 'log', 'verbose')
        G_LogFile = Modules.Utilities.GetKey(G_ServerLocation, 'log', 'file')

        G_DiscordLink = Modules.Utilities.GetKey(G_ServerLocation, 'options', 'discord_link')
        G_PatreonLink = Modules.Utilities.GetKey(G_ServerLocation, 'options', 'patreon_link')

        prefix = Modules.Utilities.GetKey(G_ServerLocation, 'options', 'command_prefix')

        -- Modules.Utilities.SendAPI({
        --     Executor = {
        --         Name = "executor",
        --         ID = 1,
        --         MID = 2,
        --         Secret = "Secret"
        --     },
        --     Client = {
        --         Name = "client",
        --         ID = 4,
        --         MID = 3,
        --         Secret = "Secret2"
        --     },
        --     Data = "test data",
        --     Type = "user_kick"
        -- })

        --[[ Create Console ]]--
        G_Clients[1337] = Modules.Server.consolePlayer

        -- Modules.VK_Debug = require('Addons.VK.Extensions.VK_Debug.VK_Debug')
        Modules.Moderation = require('Addons.VK.Extensions.VK_Moderation.Moderation')
        Modules.Roleplay = require('Addons.VK.Extensions.VK_Roleplay.Roleplay')

        G_FirstLoad = false
    end
end

Initialize()